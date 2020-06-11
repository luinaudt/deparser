import json
from collections import OrderedDict
from GraphGen import deparserGraph


class jsonP4Parser(object):
    def __init__(self, jsonFile):
        with open(jsonFile, 'r') as f:
            self.graph = json.load(f)
        self._header_types = False
        self._headers = False
        self.Gd = False
        self._deparserTuples = False
        self._parserTuples = False

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
        if not self._parserTuples:
            self._genParserTuples()
        return self._parserTuples

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

    def _genParserTuples(self):
        """
        set the list of independant header
        """
        self._parserTuples = []
        parser = self.graph["parsers"][0]
        etat = {}
        initState = parser["init_state"]
        for i in parser['parse_states']:
            etat[i['name']] = [i['parser_ops'], i['transitions']]
        self._parserTuples = self.extract_states(etat, initState)

    def _genDeparserTuples(self):
        """
        Gen all possible Deparser Tuples
        This list contains all possibilities
        """
        self._deparserTuples = []
        self.Gd = deparserGraph(self.getDeparserHeaderList())
        self._deparserTuples = self.Gd.getAllPathClosed()

    def _genTuple(self, liste):
        listeTuple = []
        for i, j in enumerate(liste[:]):
            listeTuple.append(tuple([j]))
            tmpListe = []
            if len(liste[(i+1):]) > 0:
                tmpListe.extend(self._genTuple(liste[(i+1):]))
            for k in tmpListe:
                tmp = [j]
                tmp.extend(k)
                listeTuple.append(tuple(tmp))
        return listeTuple
