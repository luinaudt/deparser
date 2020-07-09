from collections import OrderedDict
import networkx as nx
from warnings import warn
from vhdl_gen import exportDeparserToVHDL


class deparserGraph(object):
    def __init__(self, init, Headers=None):
        """
        Header : OrderedDict of Headers
        """
        self.initState = init
        self.lastState = "lastState"
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
            self.G.add_edge(ori, i, label=i)
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
        """ Return a generator for graph between start and end
        With Ini to keep init and last state
        """
        paths = nx.all_simple_paths(graph, start, end)
        for i in paths:
            if not withInit:
                if self.initState in i:
                    i = i[1:]
                if self.lastState in i:
                    i = i[:-1]
            if i != []:
                yield i

    def getClosedGraph(self):
        Gc = nx.transitive_closure(self.G)
        for u, v in Gc.edges:
            if v != self.lastState:
                Gc.edges[u, v]["label"] = v
        return Gc

    def getOptimizedGraph(self, headers_tuples):
        Gc = self.getClosedGraph()
        GMin = nx.DiGraph()
        for n, i in enumerate(headers_tuples):
            if n % 1000 == 999:
                print("Optimized Graph Header tuple {}".format(n))
            i.append(self.initState)
            i.append(self.lastState)
            tmp = Gc.subgraph(i)
            tmp = nx.transitive_reduction(tmp)
            GMin = nx.compose(GMin, tmp)
        GMin = Gc.edge_subgraph(GMin.edges)
        return GMin

    def exportToDot(self, fileName, headers_tuples=None):
        """ export to dot
        if no header tuples then export closed graph
        """
        if headers_tuples is None:
            nx.nx_pydot.write_dot(self.getClosedGraph(), fileName)
        else:
            nx.nx_pydot.write_dot(self.getOptimizedGraph(headers_tuples),
                                  fileName)

    def exportToPng(self, fileName, headers_tuples=None):
        tmp = []
        if headers_tuples is None:
            tmp = nx.nx_pydot.to_pydot(self.getClosedGraph())
        else:
            tmp = nx.nx_pydot.to_pydot(self.getOptimizedGraph(headers_tuples))
        tmp.write_png(fileName)


class deparserStateMachines(object):
    def __init__(self, depGraph, tuples, busSize):
        """ init for deparserStateMachines
        depGraph : class deparserGraph, the deparser graph considered
        tuples : list of possible active headers,
                 ex : jsonP4Parser.GetParserTuples()
        busSize, size of the output bus in bits
        """
        self.depG = depGraph.getOptimizedGraph(tuples)
        self.headers = depGraph.headers
        self.init = depGraph.initState
        self.last = depGraph.lastState
        self.busSize = busSize
        self.nbStateMachine = int(busSize/8)
        self.stateMachines = []
        for i in range(self.nbStateMachine):
            tmp = nx.DiGraph()
            tmp.add_node(self.init)
            tmp.add_node(self.last)
            self.stateMachines.append(tmp)
        self.genStateMachines()

    def genStateMachines(self):
        paths = nx.all_simple_paths(self.depG, self.init, self.last)
        for n, p in enumerate(paths):
            if n % 1000 == 999:
                print("gen stateMachine path: {}".format(n))
            st = 0
            prev_hdr = []
            for i in self.stateMachines:
                prev_hdr.append(p[0])
            for h in p:
                if h in self.headers:
                    for i in range(int(self.headers[h]/8)):
                        new_node = "{}_{}".format(h, i*8)
                        self.stateMachines[st].add_node(new_node,
                                                        header=h,
                                                        pos=(i*8, (i+1)*8-1))
                        if i < len(self.stateMachines):
                            self.stateMachines[st].add_edge(prev_hdr[st],
                                                            new_node,
                                                            label=h)
                        else:
                            self.stateMachines[st].add_edge(prev_hdr[st],
                                                            new_node)
                        prev_hdr[st] = new_node
                        st = (st + 1) % len(self.stateMachines)
            for i, m in enumerate(self.stateMachines):
                m.add_edge(prev_hdr[i], p[-1])

    def exportToDot(self, names):
        """ export all states machines to dot file
        for each state machine the dotfile correspond to names
        if list are not same lenght, exit"""
        if len(names) != len(self.stateMachines):
            Warning("not same list lenght, exit")
        else:
            for i, st in enumerate(self.getStateMachines()):
                nx.nx_pydot.write_dot(st, names[i])

    def exportToPng(self, names):
        """ export all states machines to dot file
        for each state machine the dotfile correspond to names
        if list are not same lenght, exit"""
        if len(names) != len(self.stateMachines):
            Warning("not same list lenght, exit")
        else:
            for i, st in enumerate(self.getStateMachines()):
                tmp = nx.nx_pydot.to_pydot(st)
                tmp.write_png(names[i])

    def exportToVHDL(self, outputFolder, baseName, phvBus):
        return exportDeparserToVHDL(self, outputFolder, phvBus, baseName)

    def printStPathsCount(self):
        for i, st in enumerate(self.getStateMachines()):
            nb = 0
            for j in nx.all_simple_paths(st, self.init, self.last):
                nb += 1
            print("state machine {} posseses {} path".format(
                i, nb))

    def getStateMachine(self, num):
        if num >= len(self.stateMachines):
            print("not a valid number")
            return None
        return self.stateMachines[num]

    def getStateMachines(self):
        return self.stateMachines


class parserGraph(object):
    def __init__(self, headers, initState="init"):
        """
        headerGraph : graph for parser in header
        G : parsing state graph
        """
        self.initState = initState
        self.lastState = "lastState"
        self.G = nx.DiGraph()
        self.headerGraph = None
        self.listHeaders = []
        self.headersSizes = headers
        self.headAssoc = None
        self.valAssoc = None

    def _genHeaderAssoc(self):
        headAssoc = {}
        valAssoc = {}
        phvWidth = 0
        i = 0
        self.headerGraph.nodes(data="width")
        for n, w in self.headerGraph.nodes(data="width"):
            if w is None:
                continue
            headAssoc[n] = (phvWidth, phvWidth + w - 1)
            phvWidth += w
            valAssoc[n] = i
            i += 1
        self.headAssoc = (headAssoc, phvWidth)
        self.valAssoc = (valAssoc, i)

    def getHeadersAssoc(self, baseName="phv_"):
        """
        return a tuple (bus, validity)
        with bus a tuple : (name, headerAssoc)
        and validity tuple : (name, validityAssoc)
        """
        if self.headAssoc is None or self.valAssoc is None:
            self._genHeaderAssoc()
        info = [{"name": "{}bus".format(baseName),
                 "width": self.headAssoc[1],
                 "data": self.headAssoc[0]},
                {"name": "{}val".format(baseName),
                 "width": self.valAssoc[1],
                 "data": self.valAssoc[0]}]
        return info

    def getHeaderGraph(self):
        if self.headerGraph is None:
            self._genHeaderGraph()
        return self.headerGraph

    def _genHeaderGraph(self):

        def add_header_node(name):
            if name not in self.headerGraph.nodes:
                self.headerGraph.add_node(name)
                if name in self.headersSizes:
                    width = self.headersSizes[name]
                    self.headerGraph.nodes[name]["width"] = width

        def append_header_edge(start, end):
            add_header_node(start)
            add_header_node(end)
            self.headerGraph.add_edge(start, end)
            if start not in self.listHeaders:
                self.listHeaders.append(start)
            if end not in self.listHeaders:
                self.listHeaders.append(end)

        self.headerGraph = nx.DiGraph()
        for p in self.getAllPath(True):
            lastH = p[0]
            for st in p:
                tmp = self.G.nodes(data="assoc_graph")[st]
                for nH in tmp:
                    append_header_edge(lastH, nH)
                    lastH = nH

    def append_edge(self, start, end):
        self.G.add_edge(start, end)
        if start not in self.listHeaders:
            self.listHeaders.append(start)
        if end not in self.listHeaders:
            self.listHeaders.append(end)

    def add_state_assoc_graph(self, name, data):
        if name in self.G.nodes:
            self.G.nodes[name]["assoc_graph"] = data
        else:
            self.append_state(name, data)

    def append_state(self, name, assocData):
        self.G.add_node(name, assoc_graph=assocData)

    def exportHeaderToDot(self, name):
        hG = self.getHeaderGraph()
        tmp = hG.copy()
        for k in tmp.nodes:
            tmp.nodes[k]["width"] = None
        nx.nx_pydot.write_dot(tmp, name)

    def exportStatesToDot(self, name):
        """export to dotfile name
        """
        nx.nx_pydot.write_dot(self.G, name)

    def getAllHeaderPath(self, withInit=False):
        """
        return all possible tuples for the closed Graph
        """
        hG = self.getHeaderGraph()
        return self._getPath(hG,
                             self.initState,
                             self.lastState,
                             withInit)

    def getAllPath(self, withInit=False):
        """
        return all possible tuples for the closed Graph
        """
        return self._getPath(self.G,
                             self.initState,
                             self.lastState,
                             withInit)

    def _getPath(self, graph, start, end, withInit=False):
        """ Return all tuples for graph between start and end
        With Ini to keep init and last state
        """
        paths = nx.all_simple_paths(graph, start, end)
        for i in paths:
            if not withInit:
                if self.initState in i:
                    i = i[1:]
                if self.lastState in i:
                    i = i[:-1]
            if i != []:
                yield i
