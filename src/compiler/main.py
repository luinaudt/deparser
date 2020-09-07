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


def comp(codeName, outputFolder,
         busWidth=64, exportGraph=False):
    projectParam = {"projectName": codeName,
                    "busWidth": busWidth,
                    "deparserName": "deparser",
                    "boardDir": os.path.join(os.getcwd(), "board", "base")}
    deparserName = projectParam["deparserName"]
    print("processing : {} width {}".format(codeName, busWidth))
    P4Code = jsonP4Parser("../p4/{}.json".format(codeName))

    headers = P4Code.getDeparserHeaderList()
    parsed = P4Code.getParserGraph()
    depG = deparserGraph(P4Code.graphInit, headers)
    print("generating deparser optimized")
    deparser = deparserStateMachines(depG, P4Code.getParserTuples(), busWidth)
    rtlDir = os.path.join(outputFolder, "rtl")
    depVHDL = deparser.exportToVHDL(rtlDir, deparserName,
                                    parsed.getHeadersAssoc())
    depParam = depVHDL.getVHDLParam()
    projectParam["phvBusWidth"] = depParam["phvBusWidth"]
    projectParam["phvValidityWidth"] = depParam["phvValidityWidth"]
    projectParam["phvValidityDep"] = depParam["phvValidity"]
    projectParam["phvBusDep"] = depParam["phvBus"]

    gen_vivado(projectParam, rtlDir, os.path.join(outputFolder, "vivado_opt"))
    export_sim(deparserName, rtlDir, os.path.join(outputFolder, "sim_opt"))
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
        rtlDir = os.path.join(outputFolder, "rtlNoOpt")
        print("generating deparser Not optimized")
        deparser = deparserStateMachines(depG, P4Code.getDeparserTuples(),
                                         busWidth)
        print("end generation not optimized")
        deparser.exportToVHDL(rtlDir,
                              deparserName, parsed.getHeadersAssoc())
        gen_vivado(projectParam, rtlDir,
                   os.path.join(outputFolder, "vivado_noOpt"))
        export_sim(deparserName, rtlDir,
                   os.path.join(outputFolder, "sim_no_opt"))

        if exportGraph:
            print("exporting deparser stateMachines not optimized Graph")
            exportDeparserSt(deparser, outputFolder, "no_opt")
    else:
        print("skip exporting deparser state machine not optimized, "
              "too many possible path : {}"
              .format(factorial(len(P4Code.getDeparserHeaderList()))))


def main(argv):
    codeNames = argv
    exportGraph = False
    output = os.path.join(os.getcwd(), "output")
    busWidth = []
    try:
        opts, codeNames = getopt.getopt(argv, "ho:w:",
                                        ["exportGraph", "outputDir",
                                         "busWidth", "help"])
    except getopt.GetoptError:
        print("main.py [-o outputDir] [--exportGraph] jsons")
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print("main.py [-o outputDir] [--exportGraph]"
                  "[-w width1,width2,..."
                  "] jsons")
            sys.exit(0)
        elif opt in ("-o", "--outputDir"):
            output = os.path.join(os.getcwd(), arg)
        elif opt == "--exportGraph":
            exportGraph = True
        elif opt in ("-w", "--busWidth"):
            w = arg.split(',')
            for i in w:
                busWidth.append(int(i))
    if len(codeNames) == 0:
        print("please give json Name")
        print("main.py [-o outputDir] [--exportGraph] jsons")
        sys.exit(1)
        
    if not os.path.exists(output):
        os.mkdir(output)
    if len(busWidth) == 0:
        busWidth.append(64)

    for codeName in codeNames:
        for w in busWidth:
            if len(busWidth) == 1:
                outputFolder = os.path.join(output, codeName)
            else:
                outputFolder = os.path.join(output,
                                            "{}_{}".format(codeName, w))
            if not os.path.exists(outputFolder):
                os.mkdir(outputFolder)
            comp(codeName, outputFolder, w, exportGraph)


if __name__ == "__main__":
    # execute only if run as a script
    main(sys.argv[1:])
    exit()
