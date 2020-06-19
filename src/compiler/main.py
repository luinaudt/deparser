from jsonParser import jsonP4Parser
from GraphGen import deparserGraph, deparserStateMachines
import networkx as nx
import os

codeNames = ["t0", "t4", "open_switch"]
output = os.path.join(os.getcwd(), "output")
if not os.path.exists(output):
    os.mkdir(output)

for codeName in codeNames:
    print("processing : {}".format(codeName))
    P4Code = jsonP4Parser("../p4/{}.json".format(codeName))
    outputFolder = os.path.join(output, codeName)
    if not os.path.exists(outputFolder):
        os.mkdir(outputFolder)

    headers = P4Code.getDeparserHeaderList()
    parsed = P4Code.getParserGraph()
    print("exporting parser state graph")
    parsed.exportToDot(os.path.join(outputFolder, "ParserStates.dot"))

    parsed = P4Code.getParserHeaderGraph()
    print("exporting parser header graph")
    parsed.exportToDot(os.path.join(outputFolder, "ParserHeader.dot"))

    depG = deparserGraph(P4Code.graphInit, headers)
    print("exporting deparser closed graph (not optimized)")
    nx.nx_pydot.write_dot(depG.getClosedGraph(),
                          os.path.join(outputFolder, "./deparserClosed.dot"))

    print("exporting deparser graph parser optimized")
    nx.nx_pydot.write_dot(depG.getOptimizedGraph(P4Code.getParserTuples()),
                          os.path.join(outputFolder, "./deparserParser.dot"))

    # deparser Graph generation for state Machine
    #deparser = deparserStateMachines(depG, P4Code.getParserTuples(), 64)
    #print("exporting deparser stateMachines optimized")
    #for i, st in enumerate(deparser.getStateMachines()):
    #    nx.nx_pydot.write_dot(st, os.path.join(outputFolder,
    #                                           "machine{}_opt.dot".format(i)))
    #    tmp = nx.nx_pydot.to_pydot(st)
    #    tmp.write_png(os.path.join(outputFolder,
    #                               "machine_mux{}_opt.png".format(i)))

    deparser = deparserStateMachines(depG, P4Code.getDeparserTuples(), 64)
    print("exporting deparser stateMachines not optimized")
    for i, st in enumerate(deparser.getStateMachines()):
        nx.nx_agraph.write_dot(st,
                               os.path.join(outputFolder,
                                            "machine{}_no_opt.dot".format(i)))
        tmp = nx.nx_pydot.to_pydot(st)
        tmp.write_png(os.path.join(outputFolder,
                                   "machine_mux{}_no_opt.png".format(i)))
