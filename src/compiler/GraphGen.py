from collections import OrderedDict
import networkx as nx
from networkx.drawing import nx_agraph


class deparserGraph(object):
    def __init__(self, Headers=None):
        """
        Header : OrderedDict of Headers
        """
        self.initState = "init"
        self.G = nx.DiGraph()
        self.listHeaders = []
        self.headers = OrderedDict()
        self.headers.keys
        if Headers is not None:
            self.listHeaders = list(Headers.keys())
            self.headers = Headers
            self.genBaseGraph()

    def genBaseGraph(self):
        ori = self.initState
        for i in self.listHeaders:
            self.G.add_edge(ori, i)
            ori = i

    def genOptimizedGraph(self, headers_tuples, genIntGraph=False):
        Gc = nx.transitive_closure(self.G)
        GMin = nx.DiGraph()
        for i in headers_tuples:
            i = list(i)
            i.append(self.initState)
            tmp = nx.subgraph(Gc, i)
            tmp = nx.transitive_reduction(tmp)
            GMin = nx.compose(GMin, tmp)
        if genIntGraph:
            nx_agraph.write_dot(self.G, "./OriginalGraph.dot")
            nx_agraph.write_dot(Gc, "./ClosedGraph.dot")
            nx_agraph.write_dot(GMin, "./FinalGraph.dot")
        return GMin
