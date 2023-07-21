#!/usr/bin/env python
# -*- coding: utf-8 -*-
""" Tests the Daggen library """

import unittest
import daggen as dg
import networkx as nx
import igraph as ig

class TestDAG(unittest.TestCase):

    def test_dag_creation(self):
        d = dg.DAG(seed=42, num_tasks=10)
        dot_str = "digraph G {\n" \
                  "  1 [computation=68719476736, alpha=0.06]\n" \
                  "  2 [computation=8589934592, alpha=0.06]\n" \
                  "  2 -> 3 [data=33554432]\n" \
                  "  2 -> 4 [data=33554432]\n" \
                  "  3 [computation=24450842215, alpha=0.02]\n" \
                  "  3 -> 5 [data=75497472]\n" \
                  "  3 -> 7 [data=75497472]\n" \
                  "  4 [computation=231928233984, alpha=0.20]\n" \
                  "  4 -> 6 [data=301989888]\n" \
                  "  5 [computation=28991029248, alpha=0.11]\n" \
                  "  5 -> 8 [data=75497472]\n" \
                  "  5 -> 9 [data=75497472]\n" \
                  "  6 [computation=370921150755, alpha=0.16]\n" \
                  "  7 [computation=9613001727, alpha=0.18]\n" \
                  "  7 -> 8 [data=411041792]\n" \
                  "  8 [computation=18552871712, alpha=0.04]\n" \
                  "  8 -> 10 [data=838860800]\n" \
                  "  9 [computation=1128959608590, alpha=0.18]\n" \
                  "  10 [computation=123125765851, alpha=0.10]\n" \
                  "}"
        self.assertEqual(str(d), dot_str)

    def test_seed(self):
        seed = 42
        d1 = dg.DAG(seed=seed, num_tasks=15)
        t1, e1 = d1.task_n_edge_dicts()
        d2 = dg.DAG(seed=seed, num_tasks=15)
        t2, e2 = d2.task_n_edge_dicts()
        self.assertEqual(e2, e2)
        self.assertEqual(t1, t2)
        seed = 43
        d3 = dg.DAG(seed=seed, num_tasks=15)
        t3, e3 = d3.task_n_edge_dicts()
        self.assertNotEqual(t1, t3)
        self.assertNotEqual(e1, e3)

    def test_tasks_and_edges(self):
        d = dg.DAG(seed=42, num_tasks=15)
        tasks, edges = d.task_n_edge_dicts()
        self.assertEqual(len(tasks), 15)
        self.assertEqual(len(edges), 13)

    def test_igraph(self):
        d = dg.DAG(seed=42, num_tasks=15)
        tasks, edges = d.task_n_edge_dicts()
        g = ig.Graph.DictList(vertices=tasks, edges=edges, directed=True)
        igraph_out = "IGRAPH DN-- 15 13 --\n" \
                     "+ attr: alpha (v), computation (v), name (v), data (e), source (e), target (e)\n" \
                     "+ edges (vertex names):\n" \
                     "1->4, 2->3, 3->5, 3->6, 4->7, 6->9, 7->8, 9->10, 9->11, 10->13, 11->12,\n" \
                     "12->15, 13->14"
        self.assertEqual(str(g), igraph_out)

    def test_networkx(self):
        d = dg.DAG(seed=46, num_tasks=15)
        tasks, edges = d.task_n_edge_tuples()
        net_dag = nx.DiGraph()
        net_dag.add_nodes_from(tasks)
        net_dag.add_edges_from(edges)
        task_degrees = [(1, 1), (2, 1), (3, 2), (4, 2), (5, 4), (6, 1),
                        (7, 3), (8, 3), (9, 2), (10, 1), (11, 3),
                        (12, 4), (13, 2), (14, 2), (15, 1)]
        self.assertEqual(task_degrees, list(net_dag.degree))

    def test_ccr(self):
        d = dg.DAG(seed=46, num_tasks=15, ccr=3)


if __name__ == '__main__':
    unittest.main()
