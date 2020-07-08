#!/bin/python

from jsonParser import jsonP4Parser
from GraphGen import deparserGraph, deparserStateMachines
import networkx as nx
import os
from math import factorial
from gen_vivado import gen_vivado, export_sim


def nx_to_png(machine, outputFile):
    tmp = nx.nx_pydot.to_pydot(machine)
    tmp.write_png(outputFile)


codeNames = ["t0", "t4"]  # , "open_switch"]
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
    parsed.exportStatesToDot(os.path.join(outputFolder, "ParserStates.dot"))
    nx_to_png(parsed.G, os.path.join(outputFolder, "ParserStates.png"))

    print("exporting parser header graph")
    parsed.exportHeaderToDot(os.path.join(outputFolder, "ParserHeader.dot"))
    nx_to_png(parsed.headerGraph,
              os.path.join(outputFolder, "ParserHeader.png"))

    depG = deparserGraph(P4Code.graphInit, headers)
    hT = []
    hT.append([])
    hT[0] = list(P4Code.getDeparserHeaderList().keys())
    print("exporting simple deparser base")
    depG.exportToDot(os.path.join(outputFolder, "deparserBase.dot"),
                     hT)
    depG.exportToPng(os.path.join(outputFolder, "deparserBase.png"),
                     hT)
    if len(P4Code.getDeparserHeaderList()) < 10:
        print("exporting deparser closed graph (not optimized)")
        depG.exportToDot(os.path.join(outputFolder, "deparserClosed.dot"))
        depG.exportToPng(os.path.join(outputFolder, "deparserClosed.png"))
    else:
        print("skip exporting deparser closed graph not optmized")

    print("exporting deparser graph parser optimized")
    depG.exportToDot(os.path.join(outputFolder, "deparserParser.dot"),
                     P4Code.getParserTuples())
    depG.exportToPng(os.path.join(outputFolder, "deparserParser.png"),
                     P4Code.getParserTuples())

    # deparser Graph generation for state Machine
    print("exporting deparser stateMachines optimized")
    deparser = deparserStateMachines(depG, P4Code.getParserTuples(), 64)
    dotNames = []
    pngNames = []
    for i, st in enumerate(deparser.getStateMachines()):
        dotNames.append(os.path.join(outputFolder,
                                     "machine{}_opt.dot".format(i)))
        pngNames.append(os.path.join(outputFolder,
                                     "machine_mux{}_opt.png".format(i)))
    deparser.exportToDot(dotNames)
    deparser.exportToPng(pngNames)
    deparser.printStPathsCount()

    rtlDir = os.path.join(outputFolder, "rtl")
    deparser.exportToVHDL(rtlDir, "deparser", parsed.getHeadersAssoc())
    gen_vivado(codeName, rtlDir, os.path.join(outputFolder, "vivado_Opt"))
    export_sim("deparser", rtlDir, os.path.join(outputFolder, "sim_opt"),
               parsed.getHeadersAssoc())
    print("nb headers : {}".format(len(P4Code.getDeparserHeaderList())))

    if len(P4Code.getDeparserHeaderList()) < 10:
        print("exporting deparser stateMachines not optimized")
        P4Code = jsonP4Parser("../p4/{}.json".format(codeName))
        deparser = deparserStateMachines(depG, P4Code.getDeparserTuples(), 64)
        dotNames = []
        pngNames = []
        for i, st in enumerate(deparser.getStateMachines()):
            dotNames.append(os.path.join(outputFolder,
                                         "machine{}_no_opt.dot".format(i)))
            pngNames.append(os.path.join(outputFolder,
                                         "machine_mux{}_no_opt.png".format(i)))

        deparser.exportToDot(dotNames)
        deparser.exportToPng(pngNames)
        deparser.printStPathsCount()
        deparser.exportToVHDL(os.path.join(outputFolder, "rtlNoOpt"),
                              "deparser", parsed.getHeadersAssoc())
        gen_vivado(codeName, os.path.join(outputFolder, "rtlNoOpt"),
                   os.path.join(outputFolder, "vivado_noOpt"))
        
    else:
        print("skip exporting deparser state machine not optimized, "
              "too many possible path : {}"
              .format(factorial(len(P4Code.getDeparserHeaderList()))))
