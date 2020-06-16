from jsonParser import jsonP4Parser
from GraphGen import deparserGraph, parserGraph
import networkx as nx

P4Code = jsonP4Parser("../p4/t4.json")
headers = P4Code.getDeparserHeaderList()

parsed = P4Code.getParserHeaderGraph()
parsed.exportToDot("testParserC.dot")

listeTuple = list(headers.keys())  # conversion de nom
Stmp = [(0, 3, 1), (0, 4, 1), (2, ), (0, 2, 4)]
S = []
for i in Stmp:
    tmp = []
    for j in i:
        tmp.append(listeTuple[j])
    S.append(tuple(tmp))

depG = deparserGraph(headers)
depG.getOptimizedGraph(S, True)

nx.write_gexf(depG.G, "./test.xml")
nx.write_gexf(depG.getOptimizedGraph(S), "./optmized.gexf")
nx.write_gexf(depG.getClosedGraph(), "./closed.gexf")
