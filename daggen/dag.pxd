# distutils: language = c
#
from . cimport common

__all__ = [
    "DAG"
]

cdef extern from "daggen_commons.c":
    void outputDAG(common.DAG dag)
    void outputDOT(common.DAG dag)

cdef extern from "daggen.c":
    common.DAG generateDAG()
    void freeDAG(common.DAG dag)

cdef class DAG:
    cdef common.DAG _dag
    cdef common.ConfigPointer _conf
    cdef int _seed

    cdef void _generate_DAG(self)
    cdef void _release_DAG(self)
    cdef _init_params(self, int, double, double, int, double,
                      long, long, double, double, int)


