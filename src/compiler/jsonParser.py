import json


class jsonP4Parser(object):
    def __init__(self, jsonFile):
        with open(jsonFile, 'r') as f:
            self.graph = json.load(f)
        self._header_types = False
        self._headers = False
        self._parserTuple = False

    def getHeaders(self):
        if not self._headers:
            self._genHeaderList()
        return self._headers

    def getParserTuple(self):
        if not self._parserTuple:
            self._genParserTuple()
        return self._parserTuple
    
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
        self._headers = {}
        header_types = self.getHeaderTypes()
        for i in self.graph["headers"]:
            self._headers[i['name']] = header_types[i['header_type']]

    def extract_states(self, stateList, state):
        stateTuple = []
        curState = stateList[state]
        curList = []
        for i in curState[0]:
            if i['op'] == 'extract':
                for j in i['parameters']:
                    curList.append(j['value'])
        for i in curState[1]:
            if i['next_state'] is not None:
                curList.append(self.extract_states(stateList, i['next_state']))
            else:
                return curList
        return stateTuple

    def _genParserTuple(self):
        """
        set the list of independant header
        """
        self._parserTuple = []
        parser = self.graph["parsers"][0]
        etat = {}
        initState = parser["init_state"]
        for i in parser['parse_states']:
            etat[i['name']] = [i['parser_ops'], i['transitions']]
        self._parserTuple = self.extract_states(etat, initState)
