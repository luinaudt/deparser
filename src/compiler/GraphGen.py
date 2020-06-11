from collections import OrderedDict
import networkx as nx
from networkx.drawing import nx_agraph


class deparserGraph(object):
    def __init__(self, Headers=None):
        """
        Header : OrderedDict of Headers
        """
        self.initState = "init"
        self.lastState = "end"
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
            self.G.add_edge(i, self.lastState)
            ori = i

    def getAllPathOptimized(self, headers_tuples):
        """
        return all possible tuples for the optimized Graph
        """
        return self._getPath(self.getOptimizedGraph(headers_tuples),
                             self.initState,
                             self.lastState)

    def getAllPathClosed(self):
        """
        return all possible tuples for the closed Graph
        """
        return self._getPath(self.getClosedGraph(),
                             self.initState,
                             self.lastState)

    def _getPath(self, graph, start, end, withInit=False):
        """ Return all tuples for graph between start and end
        With Ini to keep init and last state
        """
        listTuples = []
        paths = nx.all_simple_paths(graph, start, end)
        for i in paths:
            if not withInit:
                if self.initState in i:
                    i = i[1:]
                if self.lastState in i:
                    i = i[:-1]
            listTuples.append(tuple(i))
        return listTuples
    
    def getClosedGraph(self):
        Gc = nx.transitive_closure(self.G)
        return Gc

    def getOptimizedGraph(self, headers_tuples, genIntGraph=False):
        Gc = self.getClosedGraph()
        GMin = nx.DiGraph()
        for i in headers_tuples:
            i = list(i)
            i.append(self.initState)
            i.append(self.lastState)
            tmp = nx.subgraph(Gc, i)
            tmp = nx.transitive_reduction(tmp)
            GMin = nx.compose(GMin, tmp)
        if genIntGraph:
            nx_agraph.write_dot(self.G, "./OriginalGraph.dot")
            nx_agraph.write_dot(Gc, "./ClosedGraph.dot")
            nx_agraph.write_dot(GMin, "./FinalGraph.dot")
        return GMin


class parserGraph(object):
    def __init__(self, Headers):
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
