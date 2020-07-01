from colorama import Fore, Style
from string import Template
from os import path, mkdir
from math import log2, ceil


class deparserHDL(object):
    def __init__(self, deparser, templateFolder, baseName="deparser"):
        self.dep = deparser
        self.entityName = baseName
        self.tmplFolder = templateFolder
        self.tmplFile = path.join(templateFolder, "deparser.vhdl")
        self.signals = {}
        self.dictSub = {'name': baseName,
                        'payloadSize': deparser.busSize,
                        'outputSize': deparser.busSize,
                        'nbMuxes': deparser.nbStateMachine}

    def _setSignalStr(self):
        strSignal = ""
        sigTmpl = Template("signal $n : ${t}; \n")
        for n, t in self.signals.items():
            strSignal += sigTmpl.substitute({"n": n, "t": t})
        self.dictSub["signals"] = strSignal

    def __str__(self):
        self._setSignalStr()
        with open(self.tmplFile, 'r') as myfile:
            tmpl = Template(myfile.read())
        return tmpl.safe_substitute(self.dictSub)

    def genInputs(self):
        self.headerBus = {}  # header name to bus name
        self.validity = {}  # header name to validity bit name

        # value assignments
        inputTmpl = Template("    ${name} : "
                             "in std_logic_vector($size - 1 downto 0);"
                             "\n")
        validityTmpl = Template("    ${name} : in std_logic;\n")
        validityStr = ""
        inputStr = ""
        for h, size in self.dep.headers.items():
            nameBus = h + "_bus"
            nameVal = h + "_valid"
            inputStr += inputTmpl.substitute({'name': nameBus, 'size': size})
            validityStr += validityTmpl.substitute({'name': nameVal})
            self.headerBus[h] = nameBus
            self.validity[h] = nameVal
        self.dictSub["inputBuses"] = inputStr
        self.dictSub["validityBits"] = validityStr

    def genMuxes(self):
        self.muxes = {}
        self._genMux(0)
        allMuxStr = ""
        for s in self.muxes:
            allMuxStr += self.muxes[s]["code"]
        self.dictSub["muxes"] = allMuxStr

    def _addVector(self, name, size):
        self._addSignal(name,
                        "std_logic_vector({} downto 0)".format(size - 1))

    def _addLogic(self, name):
        self._addSignal(name, "std_logic")

    def _addSignal(self, name, t):
        """ name : signal name
        t signal Type
        """
        if name in self.signals:
            raise NameError("signal {} already exist".format(name))
        self.signals[name] = t

    def _genMux(self, muxNum):
        graph = self.dep.getStateMachine(muxNum)
        muxStr = ""
        muxName = "muxes_o({})".format(muxNum)
        muxSel = "selMux_{}".format(muxNum)
        tmpMux = {"sel": muxSel}
        self._addVector(muxSel, int(ceil(log2(len(graph) - 2))))
        with open(path.join(self.tmplFolder, "mux.vhdl")) as muxF:
            tmplMux = Template(muxF.read())
        tmplCase = Template("when $cond =>‌ \n \t $mux <= ${val};\n")
        strCase = ""
        for n, d in graph.nodes(data=True):
            if d != {}:
                val = "{}({} downto {})".format(self.headerBus[d["header"]],
                                                d["pos"][1],
                                                d["pos"][0])
                tmpCase = {'cond': "00",
                           'mux': muxName,
                           'val': val}
                strCase += tmplCase.substitute(tmpCase)
                
        dictMux = {"muxSel": muxSel,
                   "cases": strCase}
        muxStr = tmplMux.substitute(dictMux)
        tmpMux["code"] = muxStr
        self.muxes[muxNum] = tmpMux


def _validateInputs(funcIn):
    """ funcIn : list of three tuples :
    (Type got, variable Name, expected type)
    """
    val = True
    # validate input
    for g, n, e in funcIn:
        if g != e:
            print(Fore.YELLOW + "Wrong {} type got {}"
                  ", expected {} {}".format(n, g, e,
                                            Style.RESET_ALL))
            val = False
    return val


def exportDeparserToVHDL(deparser, outputFolder, baseName="deparser"):
    """ This function export to VHDL a deparserStateMachines
    If stateMachines are not of type deparserStateMachines exit
    """
    toValidate = [(type(outputFolder), "outputFolder", str),
                  (type(baseName), "baseName", str)]
    if not _validateInputs(toValidate):
        return
    if not path.exists(outputFolder):
        mkdir(outputFolder)

    outputFiles = path.join(outputFolder, baseName + ".vhdl")
    vhdlGen = deparserHDL(deparser, 'templates', baseName)

    vhdlGen.genInputs()
    vhdlGen.genMuxes()

    with open(outputFiles, 'w') as outFile:
        outFile.write(str(vhdlGen))
