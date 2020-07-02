from colorama import Fore, Style
from string import Template
from os import path, mkdir, scandir, copy
from math import log2, ceil
from shutil import copyfile

class deparserHDL(object):
    def __getlibrary(self):
        """set a dictionnary with library folder
        each folder is the <name> of an entity
        file <name>_comp components instantiation templates
        file <name>_place are placement template for components
        file <name> are lib file to copy
        """
        self.lib = {}
        for d in scandir(self.tmplFolder):
            if d.is_dir():
                self.lib[d.name] = ("{}.vhdl".format(d.name),
                                    "{}_comp.vhdl".format(d.name),
                                    "{}_place.vhdl".format(d.name))

    def __init__(self, deparser, outputDir,
                 templateFolder,
                 baseName="deparser",
                 libDirName="lib"):
        self.dep = deparser
        self.entityName = baseName
        self.tmplFolder = templateFolder
        self.tmplFile = path.join(templateFolder, "deparser.vhdl")
        self.libDir = path.join(outputDir, libDirName)
        if not path.exists(self.libDir):
            mkdir(self.libDir)
        self.signals = {}
        self.entities = {}
        self.components = {}
        self.__getlibrary()
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

    def writeFiles(self, mainFileName):
        """ export all files.
        mainFile‌ + lib files in libFolder
        """
        for name, d in self.components:
            tmplName, _, _ = self.lib[name]
            tmplPath = path.join(name, tmplName)
            tF = path.join(self.tmplFolder, tmplPath)  # template file
            oF = path.join(self.libDir, name)  # output lib file
            if d is False:
                copyfile(tF, oF)
            else:
                with open(tF, 'r') as tmpl:
                    t = Template(tmpl.read())
                with open(oF, 'w') as outFile:
                    outFile.write(t.substitute(d))
        with open(mainFileName, 'w') as outFile:
            outFile.write(str(self))

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

    def _addEntity(self, name, template, tmplDict):
        """Add entity name with template file template
        and tmplDict
        error if name exists
        """
        if name in self.entities:
            raise NameError("entity {} already exist".format(name))
        self.entities[name] = (template, tmplDict)

    def _addSignal(self, name, t):
        """ name : signal name
        t signal Type
        """
        if name in self.signals:
            raise NameError("signal {} already exist".format(name))
        self.signals[name] = t

    def _getMuxEntity(self, nbIn, width):
        """Function to get a mux entity name with
        nbIn as nb input and width as output size
        The mux name is generated such as being unique for
        a certain type of mux.
        if mux does not exist, add it to entities dictionnary
        """
        muxName = "mux_{}_{}".format(nbIn, width)
        if muxName not in self.entities:
            dictMux = {"name": muxName,
                       "nbInput": nbIn,
                       "wControl": getLog2In(nbIn),
                       "muxWidth": width}
            self._addEntity(muxName, "mux.vhdl", dictMux)
        return muxName

    def _connectMux(self, muxNum):
        """ Generate the code to connect a Mux
        """
        
    def _genMux(self, muxNum):
        if "mux" not in self.components:
            self.components["mux"] = False
        graph = self.dep.getStateMachine(muxNum)
        nbInput = len(graph)-2
        outWidth = 8

        muxName = "mux_{}".format(muxNum)
        outputName = "muxes_o({})".format(muxNum)
        inputName = "muxes_{}_in".format(muxNum)
        controlName = "muxes_{}_ctrl".format(muxNum)
        entityName = self._getMuxEntity(muxName, nbInput, outWidth)
        self._addVector(controlName, getLog2In(nbInput))
        self.muxes[muxNum] = {"name": muxName,
                              "entity": entityName,
                              "signals": (inputName, controlName, outputName)}


def getLog2In(nbInput):
    return int(ceil(log2(nbInput)))


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
    vhdlGen = deparserHDL(deparser, outputFolder, 'templates', baseName)

    vhdlGen.genInputs()
    vhdlGen.genMuxes()
    vhdlGen.writeFiles(outputFiles)
