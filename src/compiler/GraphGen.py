from collections import OrderedDict
import networkx as nx
from networkx.drawing import nx_agraph


class deparserGraph(object):
    def __init__(self, init, Headers=None):
        """
        Header : OrderedDict of Headers
        """
        self.initState = init
        self.lastState = "end"
        self.G = nx.DiGraph()
        self.listHeaders = []
        self.headers = OrderedDict()
        if Headers is not None:
            self.listHeaders = list(Headers.keys())
            self.headers = Headers
            self.genBaseGraph()

    def genBaseGraph(self):
        ori = self.initState
        for i in self.listHeaders:
            self.G.add_edge(ori, i)
            self.G.nodes[i]['length'] = self.headers[i]
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
            if i != []:
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
            tmp = Gc.subgraph(i)
            tmp = nx.transitive_reduction(tmp)
            GMin = nx.compose(GMin, tmp)
        GMin = Gc.edge_subgraph(GMin.edges)
        if genIntGraph:
            nx.write_gexf(self.G, "./OriginalGraph.gexf")
            nx.write_gexf(GMin, "./FinalGraph.gexf")
            nx.write_gexf(Gc, "./ClosedGraph.gexf")
            nx_agraph.write_dot(self.G, "./OriginalGraph.dot")
            nx_agraph.write_dot(Gc, "./ClosedGraph.dot")
            nx_agraph.write_dot(GMin, "./FinalGraph.dot")

        return GMin


class deparserStateMachines(object):
    def __init__(self, depGraph, tuples, busSize):
        """ init for deparserStateMachines
        depGraph : class deparserGraph, the deparser graph considered
        tuples : list of possible active headers, ex : jsonP4Parser.GetParserTuples()
        busSize, size of the output bus in bits
        """
        self.depG = depGraph.getOptimizedGraph(tuples)
        self.headers = depGraph.headers
        self.init = depGraph.initState
        self.last = depGraph.lastState
        self.nbStateMachine = int(busSize/8)
        self.stateMachines = []
        for i in range(self.nbStateMachine):
            tmp = nx.DiGraph()
            tmp.add_node(self.init)
            tmp.add_node(self.last)
            self.stateMachines.append(tmp)
        self.genStateMachines()

    def genStateMachines(self):
        for p in nx.all_simple_paths(self.depG, self.init, self.last):
            st = 0
            prev_hdr = []
            for i in self.stateMachines:
                prev_hdr.append(p[0])
            for h in p:
                if h in self.headers:
                    for i in range(int(self.headers[h]/8)):
                        new_node = "{}_{}".format(h, i*8)
                        self.stateMachines[st].add_node(new_node, pos=i*8)
                        self.stateMachines[st].add_edge(prev_hdr[st], new_node)
                        prev_hdr[st] = new_node
                        st = (st + 1) % len(self.stateMachines)
            for i, m in enumerate(self.stateMachines):
                m.add_edge(prev_hdr[i], p[-1])

    def getStateMachines(self):
        return self.stateMachines


class parserGraph(object):
    def __init__(self, initState="init"):
        """
        Header : OrderedDict of Headers
        """
        self.initState = initState
        self.lastState = "end"
        self.G = nx.DiGraph()
        self.listHeaders = []

    def append_edge(self, start, end):
        self.G.add_edge(start, end)
        if start not in self.listHeaders:
            self.listHeaders.append(start)
        if end not in self.listHeaders:
            self.listHeaders.append(end)

    def append_state(self, name):
        self.G.add_node(name)

    def exportToDot(self, name):
        """export to dotfile name
        """
        nx_agraph.write_dot(self.G, name)

    def getAllPath(self):
        """
        return all possible tuples for the closed Graph
        """
        return self._getPath(self.G,
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
            if i != []:
                listTuples.append(tuple(i))
        return listTuples
