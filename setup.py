#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
A setuptools based setup module.

See:
https://packaging.python.org/guides/distributing-packages-using-setuptools/
https://github.com/pypa/sampleproject
"""

from setuptools import setup, Extension
try:
    from Cython.Build import cythonize
except (NameError, ModuleNotFoundError):
    def cythonize(*args, **kwargs):
        pass

extensions = [
        Extension('daggen.common', ['daggen/common.pyx']),
        Extension('daggen.dag', ['daggen/dag.pyx'], extra_compile_args=[])
    ]

setup(
    packages=['daggen'],
    name='daggen',
    ext_modules=cythonize(extensions, language_level=3)
)
