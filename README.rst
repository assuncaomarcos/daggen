daggen
======

A Python port of the `daggen <https://github.com/frs69wq/daggen>`_ tool proposed by Suter & Hunold.

This library generates random, synthetic task graphs for simulation. You can easily convert the
generated task graphs into directed acyclic graphs (DAGs) in tools such as `NetworkX <https://networkx.org>`_ or
`igraph <https://python.igraph.org>`_, or export them to files. The library helps evaluate scheduling
algorithms using various application configurations.

Here is an example of how to generate a DAG of 15 tasks, accepting the default parameters,
and import it into igraph:

.. code-block:: python

   import daggen as dg
   import igraph as ig

   dag = dg.DAG(seed=42, num_tasks=15)
   tasks, edges = dag.task_n_edge_dicts()
   igraph_dag = ig.Graph.DictList(vertices=tasks, edges=edges, directed=True)

You can alternatively convert the task graph into a NetworkX' DiGraph:

.. code-block:: python

   import daggen as dg
   import networkx as nx

   dag = dag.DAG(seed=46, num_tasks=15)
   tasks, edges = dag.task_n_edge_tuples()
   net_dag = nx.DiGraph()
   net_dag.add_nodes_from(tasks)
   net_dag.add_edges_from(edges)

Task and edge attributes
------------------------

Each generated task has two attributes:

- **computation:** a sequential cost (in Flops).
- **alpha:** the alpha parameter of Amdahl's Law, used to encode the overhead of parallelizing tasks in parallel task graphs.

Each edge represents a communication from a parent task to a child task and has a **data** attribute
representing the amount of data transferred from parent to child.

DAG parameters
--------------

You can configure the characteristics of the generated DAGs by parametrizing the `DAG()` function.
Following the C implementation, one can set the following parameters:

- `seed`: used to seed the random number generator and ensure reproducibility.
- `num_tasks`: Number of computation nodes (application tasks) in the DAG.
- `min_data`: Minimum amount of data in bytes a task processes.
- `max_data`: Maximum amount of data in bytes a task processes.
- `min_alpha`: Minimum value for the extra parameter (e.g., Amdahl's law parameter).
- `max_alpha`:  Minimum value for the extra parameter.
- `fat`: Width of the DAG, the maximum number of tasks executed concurrently. A small value results in a thin DAG.
  (e.g., chain) with low task parallelism, while a large value creates a fat DAG (e.g., fork-join).
  with a high degree of parallelism.
- `density`: Determines the dependencies between tasks of two consecutive DAG levels.
- `regular`: Regularity of the task distribution between the different levels of the DAG.
- `ccr`:  Communication to computation ratio. It encodes the complexity of the computation of a task
  depending on the size `n` of the dataset it processes. The encoding is as follows:

  * 1 : `a * n` (`a` is a constant picked randomly between 26 and 29).
  * 2 : `a * n log n`
  * 3 : `n3/2`
  * 0 : Random choice among the three complexities.

- `jump_size`:   Maximum number of levels spanned by inter-task communications, which enables DAGs
  with execution paths of multiple lengths.

Examples on Google Colab
------------------------

A couple examples are available on this Colab notebook:

.. image:: https://colab.research.google.com/assets/colab-badge.svg
   :target: https://colab.research.google.com/github/assuncaomarcos/daggen/blob/main/notebooks/daggen_examples.ipynb
   :alt: Open in Colab