from string import Template
from os import path, walk


def gen_vivado(projectName, rtlDir, outputDir, tclFile="init.tcl"):
    tmplDict = {"projectName": projectName}
    tcl_vivado_tmpl = Template(
        "create_project $projectName $dir -part xc7z010iclg225-1L \n"
        "set_property target_language VHDL [current_project] \n"
        "set_property simulator_language VHDL [current_project] \n"
        "add_files {${files}} \n"
        "update_compile_order -fileset sources_1 \n")

    baseElem = []
    for d, _, f in walk(rtlDir):
        for i in f:
            baseElem.append("{}/{}".format(d, i))
    tmplDict["files"] = " ".join(baseElem)
    with open(path.join(outputDir, tclFile), 'w') as f:
        f.write(tcl_vivado_tmpl.substitute(tmplDict))
