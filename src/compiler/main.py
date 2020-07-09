#!/bin/python
from jsonParser import jsonP4Parser
from GraphGen import deparserGraph, deparserStateMachines
import os
import sys
import getopt
from math import factorial
from gen_vivado import gen_vivado, export_sim
from debug_util import exportParserGraph
from debug_util import exportDeparserSt, exportDepGraphs


def comp(codeName, outputFolder, exportGraph=False):
    print("processing : {}".format(codeName))
    P4Code = jsonP4Parser("../p4/{}.json".format(codeName))

    headers = P4Code.getDeparserHeaderList()
    parsed = P4Code.getParserGraph()
    depG = deparserGraph(P4Code.graphInit, headers)
    print("generating deparser optimized")
    deparser = deparserStateMachines(depG, P4Code.getParserTuples(), 64)
    rtlDir = os.path.join(outputFolder, "rtl")
    deparser.exportToVHDL(rtlDir, "deparser", parsed.getHeadersAssoc())
    gen_vivado(codeName, rtlDir, os.path.join(outputFolder, "vivado_Opt"))
    export_sim("deparser", rtlDir, os.path.join(outputFolder, "sim_opt"))
    print("end deparser Generation")
    
    if exportGraph:
        print("exporting Graphs")
        exportParserGraph(parsed, outputFolder)
        exportDepGraphs(P4Code, depG, outputFolder)
        # deparser Graph generation for state Machine
        print("exporting deparser stateMachines optimized")
        exportDeparserSt(deparser, outputFolder, "opt")
        print("nb headers : {}".format(len(P4Code.getDeparserHeaderList())))

    if len(P4Code.getDeparserHeaderList()) < 10:
        print("generating deparser Not optimized")
        deparser = deparserStateMachines(depG, P4Code.getDeparserTuples(), 64)
        print("end generation not optimized")
        deparser.exportToVHDL(os.path.join(outputFolder, "rtlNoOpt"),
                              "deparser", parsed.getHeadersAssoc())
        gen_vivado(codeName, os.path.join(outputFolder, "rtlNoOpt"),
                   os.path.join(outputFolder, "vivado_noOpt"))
        if exportGraph:
            print("exporting deparser stateMachines not optimized Graph")
            exportDeparserSt(deparser, outputFolder, "no_opt")
    else:
        print("skip exporting deparser state machine not optimized, "
              "too many possible path : {}"
              .format(factorial(len(P4Code.getDeparserHeaderList()))))


def main(argv):
    codeNames = argv
    exportGraph = True
    try:
        opts, codeNames = getopt.getopt(argv, "o:",
                                        ["noGraphExport", "outputDir"])
    except getopt.GetoptError:
        print("main.py [-o outputDir] [--noGraphExport] jsons")
        sys.exit(2)
    output = os.path.join(os.getcwd(), "output")
    for opt, arg in opts:
        if opt in ("-o", "--outputDir"):
            output = os.path.join(os.getcwd(), arg)
        elif opt == "--noGraphExport":
            exportGraph = False

    if not os.path.exists(output):
        os.mkdir(output)
    if len(codeNames) == 0:
        print("no argument given, please give json Name")
        sys.exit(1)

    for codeName in codeNames:
        outputFolder = os.path.join(output, codeName)
        if not os.path.exists(outputFolder):
            os.mkdir(outputFolder)
        comp(codeName, outputFolder, exportGraph)


if __name__ == "__main__":
    # execute only if run as a script
    main(sys.argv[1:])
    exit()
