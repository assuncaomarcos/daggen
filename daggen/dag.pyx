# distutils: language = c
#
from . cimport common
from libc.stdio cimport stdout
from typing import Tuple

# Default DAG values obtained from the C implementation
cdef int NUM_TASKS = 100
cdef float FAT = 0.5
cdef float REGULAR = 0.9
cdef float DENSITY = 0.5
cdef int MIN_DATA = 2048
cdef int MAX_DATA =  11264
cdef float MIN_ALPHA = 0.0
cdef float MAX_ALPHA = 0.2
cdef int JUMP_SIZE = 1
cdef int CCR = 0

cdef str TASK_SIZE_LABEL = "computation"
cdef str DATA_COMM_LABEL = "data"

cdef extern from "stdlib.h":
    void srand(int seed)

cdef extern from "daggen.c":
    common.DAG generateDAG()
    void freeDAG(common.DAG dag)
    common.Global config

cdef _validate_0_to_1_arg(double value, str name):
    if value < 0 or value > 1:
        raise ValueError(
            f"Unsupported {name} value {value:.2f}"
        )

cdef _validate_smaller_than(double smaller_v, double larger_v,
                            str name_smaller, str name_larger):
    if smaller_v > larger_v:
        raise ValueError(
            f"Value for {name_larger} ({larger_v}) must "
            f"be greater than {name_smaller} ({smaller_v})"
        )

cdef _validate_positive_arg(double value, str name):
    if value < 0:
        raise ValueError(
            f"Unsupported {name} value {value:.2f}"
        )

cdef _validate_ccr(int ccr):
    if ccr < 0 or ccr > 3:
        raise ValueError(
            f"Unsupported ccr value {ccr}"
        )

cdef class DAG:

    def __init__(self, seed: int,
                 num_tasks: int = NUM_TASKS,
                 min_data: int = MIN_DATA,
                 max_data: int = MAX_DATA,
                 min_alpha: float = MIN_ALPHA,
                 max_alpha: float = MAX_ALPHA,
                 fat: float = FAT,
                 density: float = DENSITY,
                 regular: float = REGULAR,
                 ccr: int = CCR,
                 jump_size: int = JUMP_SIZE
                 ):
        self._seed = seed
        srand(self._seed)
        self._init_params(num_tasks, fat, regular, ccr,
                          density, min_data, max_data,
                          min_alpha, max_alpha, jump_size)
        self._generate_DAG()

    def __cinit__(self):
        self._conf = &config
        self._dag = NULL
        self._init_params(NUM_TASKS, FAT, REGULAR, CCR,
                          DENSITY, MIN_DATA, MAX_DATA,
                          MIN_ALPHA, MAX_ALPHA, JUMP_SIZE)


    def __dealloc__(self):
        self._release_DAG()

    cdef void _generate_DAG(self):
        self._dag = generateDAG()

        # Tag all the nodes
        cdef int i, j
        cdef node_count = 1     # Tags start at 1

        for i in range(self._dag.nb_levels):
            for j in range(self._dag.nb_tasks_per_level[i]):
                self._dag.levels[i][j].tag = node_count
                node_count += 1

    cdef void _release_DAG(self):
        if self._dag is not NULL:
            freeDAG(self._dag)

    cdef _init_params(self, int num_tasks, double fat,
                      double regular, int ccr, double density,
                      long min_data, long max_data,
                      double min_alpha, double max_alpha, int jump_size):
        # Validate all argument values
        _validate_positive_arg(num_tasks, <str>"num_tasks")
        _validate_positive_arg(min_data, <str> "min_data")
        _validate_positive_arg(max_data, <str> "max_data")
        _validate_0_to_1_arg(min_alpha, <str> "min_alpha")
        _validate_0_to_1_arg(max_alpha, <str> "max_alpha")
        _validate_smaller_than(min_data, max_data, <str>"min_data", <str>"max_data")
        _validate_smaller_than(min_alpha, max_alpha, <str> "min_alpha", <str> "max_alpha")
        _validate_0_to_1_arg(fat, <str>"fat")
        _validate_0_to_1_arg(density, <str> "density")
        _validate_ccr(ccr)

        self._conf.n = num_tasks
        self._conf.fat = fat
        self._conf.regular = regular
        self._conf.ccr = ccr
        self._conf.density = density
        self._conf.mindata = min_data
        self._conf.maxdata = max_data
        self._conf.minalpha = min_alpha
        self._conf.maxalpha = max_alpha
        self._conf.jump = jump_size
        self._conf.output_file = stdout

    def __str__(self):
        result = "digraph G {\n"
        for i in range(self._dag.nb_levels):
            # obtain the vertices
            for j in range(self._dag.nb_tasks_per_level[i]):
                task = self._dag.levels[i][j]
                result += f"  {task.tag} [{TASK_SIZE_LABEL}={task.cost:.0f}, alpha={task.alpha:.2f}]\n"

                # Get the edges
                for k in range(task.nb_children):
                    result += f"  {task.tag} -> {task.children[k].tag} [{DATA_COMM_LABEL}={task.comm_costs[k]:.0f}]\n"

        result += "}"
        return result

    def task_n_edge_dicts(self) -> Tuple[list[dict], list[dict]]:
        tasks = []
        edges = []
        for i in range(self._dag.nb_levels):
            # obtain the vertices
            for j in range(self._dag.nb_tasks_per_level[i]):
                task = self._dag.levels[i][j]
                tasks.append({'name': task.tag,
                              TASK_SIZE_LABEL: int(task.cost),
                              'alpha': round(task.alpha, 2)})

                # Get the edges
                for k in range(task.nb_children):
                    edges.append({'source' : task.tag,
                                  'target': task.children[k].tag,
                                  DATA_COMM_LABEL: int(task.comm_costs[k])})

        return tasks, edges

    def task_n_edge_tuples(self) -> Tuple[list[Tuple], list[Tuple]]:
        tasks = []
        edges = []
        for i in range(self._dag.nb_levels):
            # obtain the vertices
            for j in range(self._dag.nb_tasks_per_level[i]):
                task = self._dag.levels[i][j]
                tasks.append((task.tag,
                              {TASK_SIZE_LABEL: int(task.cost), 'alpha': round(task.alpha, 2)}))

                # Get the edges
                for k in range(task.nb_children):
                    edges.append((task.tag, task.children[k].tag, {DATA_COMM_LABEL: int(task.comm_costs[k])}))
        return tasks, edges