from collections import OrderedDict
import networkx as nx
from networkx.drawing import nx_agraph


class deparserGraph(object):
    def __init__(self, Headers=None):
        """
        Header : OrderedDict of Headers
        """
        self.G = nx.DiGraph()
        self.listHeaders = []
        self.headers = OrderedDict()
        self.headers.keys
        if Headers is not None:
            self.listHeaders = list(Headers.keys())
            self.headers = Headers
            self.genBaseGraph()

    def genBaseGraph(self):
        ori = "init"
        for i in self.listHeaders:
            self.G.add_edge(ori, i)
            ori = i

    def genOptimizedGraph(self, headers_tuples, genIntGraph=False):
        Gc = nx.transitive_closure(self.G)
#        self.G.remove_node("start")
        GMin = nx.DiGraph()
        for i in headers_tuples:
            tmp = nx.subgraph(Gc, i)
            GMin = nx.compose(GMin, tmp)
        GMin = nx.transitive_reduction(GMin)

        if genIntGraph:
            nx_agraph.write_dot(self.G, "./OriginalGraph.dot")
            nx_agraph.write_dot(Gc, "./ClosedGraph.dot")
            nx_agraph.write_dot(GMin, "./FinalGraph.dot")
        return GMin
