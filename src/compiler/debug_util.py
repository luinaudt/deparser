from os import path
import networkx as nx
"""
Utility function for compiler debug
Graph generation and other
"""


def nx_to_png(machine, outputFile):
    tmp = nx.nx_pydot.to_pydot(machine)
    tmp.write_png(outputFile)


def exportParserGraph(parser, outputFolder,
                      state=True, headers=True,
                      dot=True, png=True):
    if state:
        print("exporting parser state graph")
        if dot:
            parser.exportStatesToDot(path.join(outputFolder,
                                               "ParserStates.dot"))
        if png:
            nx_to_png(parser.G, path.join(outputFolder,
                                          "ParserStates.png"))

    if headers:
        print("exporting parser header graph")
        if dot:
            parser.exportHeaderToDot(path.join(outputFolder,
                                               "ParserHeader.dot"))
        if png:
            nx_to_png(parser.headerGraph, path.join(outputFolder,
                                                    "ParserHeader.png"))


def exportDeparserGraph(deparser, headerTuples,
                        outputFolder, baseFileName,
                        dot=True, png=False):
    fileNamePng = path.join(outputFolder, baseFileName + ".png")
    fileNameDot = path.join(outputFolder, baseFileName + ".dot")
    if png:
        deparser.exportToPng(fileNamePng, headerTuples)
    if dot:
        deparser.exportToDot(fileNameDot, headerTuples)


def exportDeparserSt(deparser, outputFolder, extName,
                     dot=True, png=True, pathCount=True):
    dotNames = []
    pngNames = []
    for i, st in enumerate(deparser.getStateMachines()):
        dotNames.append(path.join(outputFolder,
                                  "machine{}_{}.dot".format(i, extName)))
        pngNames.append(path.join(outputFolder,
                                  "machine_mux{}_{}.png".format(i, extName)))
    if dot:
        deparser.exportToDot(dotNames)
    if png:
        deparser.exportToPng(pngNames)
    if pathCount:
        deparser.printStPathsCount()


def exportDepGraphs(P4Code, depG, outputFolder):
    hT = []
    hT.append([])
    hT[0] = list(P4Code.getDeparserHeaderList().keys())
    print("exporting simple deparser base")
    exportDeparserGraph(depG, hT, outputFolder, "deparserBase")

    if len(P4Code.getDeparserHeaderList()) < 15:
        print("exporting deparser closed graph (not optimized)")
        exportDeparserGraph(depG, None, outputFolder, "deparserClosed")
    else:
        print("skip exporting deparser closed graph not optmized")

    print("exporting deparser graph parser optimized")
    exportDeparserGraph(depG, P4Code.getParserTuples(),
                        outputFolder, "deparserParser")
