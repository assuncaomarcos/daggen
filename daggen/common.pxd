# distutils: language = c

from libc.stdio cimport FILE

# cdef class CCRType:
#     cdef public int MIXED=0, N_2, N_LOG_N, N_3
#
#     def __init__(self, mixed, n_2, n_log_n, n_3):
#         self.MIXED = mixed
#         self.N_2 = n_2
#         self.N_LOG_N = n_log_n
#         self.N_3 = n_3

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

    # ctypedef class CCRType [object complexity_t]:
    #     cdef:
    #         int MIXED "MIXED"
    #         int N_2 "N_2"
    #         int N_LOG_N "N_LOG_N"
    #         int N_3 "N_3"

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
