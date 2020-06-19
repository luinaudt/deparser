import json
from collections import OrderedDict
from GraphGen import deparserGraph, parserGraph


class jsonP4Parser(object):
    def __init__(self, jsonFile):
        with open(jsonFile, 'r') as f:
            self.graph = json.load(f)
        self._header_types = False
        self._headers = False
        self.Gd = None
        self.Gp = None
        self._deparserTuples = False
        self._parserTuples = False
        self.graphInit = self.graph["parsers"][0]["init_state"]

    def getHeaders(self):
        if not self._headers:
            self._genHeaderList()
        return self._headers

    def getDeparserComb(self, opt=False):
        if opt:
            return self.getOptimizeDeparserTuples()
        return self.getDeparserTuples()

    def getOptimizeDeparserTuples(self):
        tuples = self.getDeparserTuples()
        return tuples

    def getDeparserTuples(self):
        if not self._deparserTuples:
            self._genDeparserTuples()
        return self._deparserTuples

    def getParserTuples(self):
        if self.Gp is None:
            self._genParserHeaderGraph()
        return self.Gp.getAllPath()

    def getHeaderTypes(self):
        if not self._header_types:
            self._genHeaderTypes()
        return self._header_types

    def _genHeaderTypes(self):
        self._header_types = {}
        for i in self.graph["header_types"]:
            h_len = 0
            for j in i['fields']:
                h_len += j[1]
            self._header_types[i['name']] = h_len

    def _genHeaderList(self):
        self._headers = OrderedDict()
        header_types = self.getHeaderTypes()
        for i in self.graph["headers"]:
            self._headers[i['name']] = header_types[i['header_type']]

    def getDeparserHeaderList(self):
        """ Generate ordered dict of all
        deparser headers.
        """
        headers = OrderedDict()
        for i in self._getDeparserProtocols():
            headers[i] = self.getHeaders()[i]
        return headers

    def _getDeparserProtocols(self):
        return self.graph['deparsers'][0]['order']

    def extract_states(self, stateList, state):
        """ Extract active states
        """
        stateTuple = []
        curState = stateList[state]
        ActivatedProtocolList = []
        for i in curState[0]:
            if i['op'] == 'extract':
                for j in i['parameters']:
                    ActivatedProtocolList.append(j['value'])
        stateTuple.append(tuple(ActivatedProtocolList))
        for i in curState[1]:
            curList = []
            if i['next_state'] is not None:
                curList.extend(self.extract_states(stateList, i['next_state']))
            for j in curList:
                tmp = ActivatedProtocolList.copy()
                tmp.extend(j)
                stateTuple.append(tuple(tmp))
        return stateTuple

    def getParserHeaderGraph(self):
        if self.Gp is None:
            self._genParserHeaderGraph()
        return self.Gp

    def _genParserHeaderGraph(self):
        GpTmp = self.getParserGraph()
        self.Gp = parserGraph(self.graphInit)
        # add list of header with fix edges
        for i, data in GpTmp.G.nodes(data="assoc_graph"):
            if isinstance(data, list):
                for pos, j in enumerate(data):
                    self.Gp.append_state(j)
                    if pos > 0:
                        self.Gp.append_edge(data[pos-1], j)
        # set edges
        for i, j in GpTmp.G.edges:
            self.Gp.append_edge(GpTmp.G.nodes[i]["assoc_graph"][-1],
                                GpTmp.G.nodes[j]["assoc_graph"][0])

    def getParserGraph(self):
        parser = self.graph["parsers"][0]
        GpTmp = parserGraph(self.graphInit)
        lastState = GpTmp.lastState
        tmp = [GpTmp.initState]
        GpTmp.G.add_node(lastState, assoc_graph=[lastState])
        for i in parser["parse_states"]:
            # gen list of extracted headers
            for e in i["parser_ops"]:
                if e["op"] == "extract":
                    tmp.append(e["parameters"][0]["value"])
            if i["name"] not in GpTmp.G:
                GpTmp.G.add_node(i["name"])
            GpTmp.G.nodes[i["name"]]["assoc_graph"] = tmp
            tmp = []
            # associate next states
            for j in i["transitions"]:
                if j["next_state"] is None:
                    GpTmp.append_edge(i["name"], lastState)
                else:
                    GpTmp.append_edge(i["name"], j["next_state"])
        return GpTmp

    def _genDeparserTuples(self):
        """
        Gen all possible Deparser Tuples
        This list contains all possibilities
        """
        self._deparserTuples = []
        self.Gd = deparserGraph(self.graphInit, self.getDeparserHeaderList())
        self._deparserTuples = self.Gd.getAllPathClosed()
