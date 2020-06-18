from jsonParser import jsonP4Parser
from GraphGen import deparserGraph, deparserStateMachines
import networkx as nx
import pydot

P4Code = jsonP4Parser("../p4/t4.json")
headers = P4Code.getDeparserHeaderList()

parsed = P4Code.getParserHeaderGraph()
parsed.exportToDot("testParserC.dot")

depG = deparserGraph(headers)

nx.nx_agraph.write_dot(depG.getOptimizedGraph(P4Code.getParserTuples()),
                       "./deparserParser.dot")

# deparser Graph generation for state Machine

deparserOpt = deparserStateMachines(depG, P4Code.getParserTuples(), 64)
deparserNoOpt = deparserStateMachines(depG, P4Code.getDeparserTuples(), 64)
for i, st in enumerate(deparserOpt.getStateMachines()):
    nx.nx_agraph.write_dot(st, "./stateMachines/machine{}_opt.dot".format(i))
    tmp = nx.nx_pydot.to_pydot(st)
    tmp.write_png("./stateMachines/machine_mux{}_opt.png".format(i))
for i, st in enumerate(deparserNoOpt.getStateMachines()):
    nx.nx_agraph.write_dot(st,
                           "./stateMachines/machine{}_no_opt.dot".format(i))
    tmp = nx.nx_pydot.to_pydot(st)
    tmp.write_png("./stateMachines/machine_mux{}_no_opt.png".format(i))
