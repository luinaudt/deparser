from string import Template
from os import path, walk, mkdir


def gen_vivado(projectParameters, rtlDir, outputDir, tclFile="vivado.tcl"):
    boardDir = projectParameters["boardDir"]
    tmplTclDict = {"projectName": projectParameters["projectName"],
                   "dir": outputDir,
                   "boardDir": boardDir}

    tmplTopDict = {"outputSize": projectParameters["busWidth"],
                   "depName": projectParameters["deparserName"],
                   "phvBusWidth": projectParameters["phvBusWidth"],
                   "phvValidityWidth": projectParameters["phvValidityWidth"],
                   "phvValidityDep": projectParameters["phvValidityDep"],
                   "phvBusDep": projectParameters["phvBusDep"]}

    # write top
    with open(path.join(boardDir, "top.vhdl"), 'r') as f:
        topTmpl = Template(f.read())
    with open(path.join(rtlDir, "top.vhdl"), 'w') as f:
        f.write(topTmpl.substitute(tmplTopDict))
    baseElem = []
    for d, _, f in walk(rtlDir):
        for i in f:
            baseElem.append("{}/{}".format(d, i))

    tmplTclDict["files"] = " ".join(baseElem)
    if not path.exists(outputDir):
        mkdir(outputDir)
    # write script
    with open(path.join(boardDir, "top.tcl"), 'r') as f:
        tcl_vivado_tmpl = Template(f.read())
    with open(path.join(outputDir, tclFile), 'w') as f:
        f.write(tcl_vivado_tmpl.substitute(tmplTclDict))


def export_sim(mainName, rtlDir, outputDir):
    tmplDict = {"main": mainName,
                "rtl": rtlDir}
    tmpl = Template("make VHDL_SOURCES=${rtl}/*.vhdl "
                    "VHDL_SOURCES+=${rtl}/lib/*.vhdl TOPLEVEL=${main}_tb \n")
    if not path.exists(outputDir):
        mkdir(outputDir)
    with open(path.join(outputDir, "run.sh"), 'w') as f:
        f.write("#!/bin/bash \n")
        f.write(tmpl.substitute(tmplDict))
