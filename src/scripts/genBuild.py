#!/bin/python
import os
from string import Template


def cleanVivadoDir(directory):
    for d, p, f in os.walk(directory):
        for fichier in f:
            if fichier == "vivado.tcl":
                continue
            os.remove(os.path.join(d, fichier))
    while len(os.listdir(directory)) > 1:
        for p, d, _ in os.walk(directory):
            if p == directory:
                continue
            if len(d) == 0:
                os.rmdir(p)


tclTmpl = """
cd $project
source vivado.tcl
synth_design
report_timing_summary -file ${report_folder}/post_synth_timing_summary.rpt
report_utilization -hierarchical -file ${report_folder}/post_synth_util_hier.rpt
close_project
cd $curPWD
"""
resDirName = "result"
tmplBuild = Template(tclTmpl)
outputFile = ""
resDir = os.path.join(os.getcwd(), resDirName)
for d in os.listdir():
    if d == resDirName or os.path.isfile(d):
        continue
    s = d.split("_")
    for opt in ["Opt", "noOpt"]:
        tmplDict = {"project": "{}/vivado_{}".format(d, opt),
                    "curPWD": os.getcwd(),
                    "report_folder": str(os.path.join(resDir,
                                                      "{}_{}".format(d, opt)))}
        outputFile += tmplBuild.substitute(tmplDict)
        os.makedirs(os.path.join(resDir, "{}_{}".format(d, opt)),
                    exist_ok=True)
        cleanVivadoDir(os.path.join(os.getcwd(),
                                    d, "vivado_{}".format(opt)))

with open("build.tcl", 'w') as f:
    f.write(outputFile)
