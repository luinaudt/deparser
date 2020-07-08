from string import Template
from os import path, walk, mkdir


def gen_vivado(projectName, rtlDir, outputDir, tclFile="vivado.tcl"):
    tmplDict = {"projectName": projectName,
                "dir": outputDir}
    tcl_vivado_tmpl = Template(
        "create_project $projectName $dir -part xc7z010iclg225-1L \n"
        "set_property target_language VHDL [current_project] \n"
        "set_property simulator_language VHDL [current_project] \n"
        "add_files {${files}} \n"
        "update_compile_order -fileset sources_1 \n"
        "set_property elab_link_dcps false [current_fileset]\n"
        "set_property elab_load_timing_constraints false [current_fileset]\n")

    baseElem = []
    for d, _, f in walk(rtlDir):
        for i in f:
            baseElem.append("{}/{}".format(d, i))
    tmplDict["files"] = " ".join(baseElem)

    if not path.exists(outputDir):
        mkdir(outputDir)

    with open(path.join(outputDir, tclFile), 'w') as f:
        f.write(tcl_vivado_tmpl.substitute(tmplDict))


def export_sim(mainName, rtlDir, outputDir, headerAssoc):
    tmplDict = {"main": mainName,
                "rtl": rtlDir}
    tmpl = Template("make VHDL_SOURCES=${rtl}/${main}.vhdl"
                    "VHDL_SOURCES+=${rtl}/lib/*.vhdl \n")
    if not path.exists(outputDir):
        mkdir(outputDir)
    with open(path.join(outputDir, "run.sh"), 'w') as f:
        f.write("#!/usr/bash \n")
        f.write(tmpl.substitute(tmplDict))
    with open(path.join(outputDir, "variables.py"), 'w') as f:
        f.write(str(headerAssoc))
        f.write("\n")
