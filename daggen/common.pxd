# distutils: language = c

from libc.stdio cimport FILE


cdef extern from "daggen_commons.h":
    ctypedef struct Global:
        int n
        double fat
        double regular
        int ccr
        double density
        double mindata, maxdata
        double minalpha, maxalpha
        int jump
        FILE* output_file

    Global config
    ctypedef (_Task *) Task
    ctypedef (_DAG *) DAG

    cdef enum complexity_t:
        MIXED=0,
        N_2,
        N_LOG_N, # (n2 log(n2) indeed
        N_3

    cdef struct _Task:
        int tag
        double cost
        double data_size
        double alpha
        int nb_children
        Task * children
        double * comm_costs
        int * transfer_tags
        complexity_t complexity

    cdef struct _DAG:
        int nb_levels
        int * nb_tasks_per_level
        Task ** levels

    void outputDAG(DAG dag)
    void outputDOT(DAG dag)

ctypedef Global* ConfigPointer
