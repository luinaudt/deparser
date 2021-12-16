from os import listdir, path, walk, mkdir, getcwd
from string import Template
tmplDict = {"main": "deparser",
            "rtl": "rtl"}
tmpl = Template("make clean \n"
                "make VHDL_SOURCES=${rtl}/lib/*.vhdl "
                "VHDL_SOURCES+=${rtl}/deparser.vhdl TOPLEVEL=work.${main} "
                "MODULE=deparser_raw \n")

ignoreFold=["result"] # liste de dossier à ignorer
toTreat=["noOpt"] # liste des optimisation a prendre en compte
folder = getcwd()
runFile = path.join(getcwd(), "runRaw.sh") #fichier de script de sortie
for d in listdir(folder):
    curFold = path.join(folder, d)
    if d in ignoreFold or path.isfile(curFold):
        continue
    s = d.split("_")
    for opt in toTreat:
        tmplDict["rtl"] = path.join(curFold, "rtlNoOpt")
        with open(runFile, 'a') as f:
            f.write(tmpl.substitute(tmplDict))
