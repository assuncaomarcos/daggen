#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This package generates directed acyclic graphs (DAGs) that represent
a workflow of tasks that are executed on compute resources.
The generated DAGs can be imported into networkx or igraph.
"""

__version__ = '0.0.5'

from daggen.dag import *
