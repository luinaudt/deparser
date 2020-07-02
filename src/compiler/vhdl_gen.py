from colorama import Fore, Style
from string import Template
from os import path, mkdir, scandir
from math import log2, ceil
from shutil import copyfile
from warnings import warn


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
                curPath = path.join(self.tmplFolder, d.name)
                self.lib[d.name] = (path.join(curPath,
                                              "{}.vhdl".format(d.name)),
                                    path.join(curPath,
                                              "{}_comp.vhdl".format(d.name)),
                                    path.join(curPath,
                                              "{}_place.vhdl".format(d.name)))

    def __init__(self, deparser, outputDir,
                 templateFolder,
                 baseName="deparser",
                 libDirName="lib"):
        self.clkName = "clk"
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
        self._setEntitiesImplCode()
        self._setComponentsCode()
        with open(self.tmplFile, 'r') as myfile:
            tmpl = Template(myfile.read())
        return tmpl.safe_substitute(self.dictSub)

    def _setComponentsCode(self):
        code = ""
        for n, d in self.components.items():
            if n not in self.lib:
                raise NameError("component {} does not exist "
                                "in library".format(n))
            if d is False:
                with open(self.lib[n][1], 'r') as f:
                    code += f.read()
            else:
                warn("components with parameters not implemented yet")
        self.dictSub["components"] = code

    def _setEntitiesImplCode(self):
        """ Gen implementation for a component
        Component : component name
        tmplDict : template dictionnary
        Require a <component>_place.vhdl file in <component> dir
        """
        implCode = ""
        for c, d in self.entities.values():
            if c not in self.lib:
                raise NameError("component {} does not exist "
                                "in library".format(c))
            with open(self.lib[c][2], 'r') as f:
                tData = Template(f.read())
            implCode += tData.safe_substitute(d)
        self.dictSub["entities"] = implCode

    def writeFiles(self, mainFileName):
        """ export all files.
        mainFile‌ + lib files in libFolder
        """
        for name, d in self.components.items():
            tF = self.lib[name][0]  # get template file
            oF = path.join(self.libDir,
                           "{}.vhdl".format(name))  # output lib file
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
        self.dictSub["muxes"] = allMuxStr
        warn("not finished genMuxes")

    def _addVector(self, name, size):
        self._addSignal(name,
                        "std_logic_vector({} downto 0)".format(size - 1))

    def _addLogic(self, name):
        self._addSignal(name, "std_logic")

    def _addEntity(self, name, tmplDict):
        """Add entity name with template file template
        and tmplDict
        error if name exists
        """
        if name in self.entities:
            raise NameError("entity {} already exist".format(name))
        self.entities[name] = tmplDict

    def getEntity(self, name):
        if name in self.entities:
            return self.entities[name]
        else:
            raise NameError("entity {} does not exist".format(name))

    def _addSignal(self, name, t):
        """ name : signal name
        t signal Type
        """
        if name in self.signals:
            raise NameError("signal {} already exist".format(name))
        self.signals[name] = t

    def _signalExist(self, name):
        return name in self.signals

    def _getMuxEntity(self, muxNum):
        """Function to get a mux entity name with
        nbIn as nb input and width as output size
        The mux name is generated such as being unique for
        a certain type of mux.
        if mux does not exist, add it to entities dictionnary
        """
        graph = self.dep.getStateMachine(muxNum)
        nbInput = len(graph)-2
        outWidth = 8
        muxName = "mux_{}".format(muxNum)
        outputName = "muxes_o({})".format(muxNum)
        inputName = "muxes_{}_in".format(muxNum)
        controlName = "muxes_{}_ctrl".format(muxNum)
        if muxName not in self.entities:
            if "mux" not in self.components:
                self.components["mux"] = False
            dictMux = {"name": muxName,
                       "nbInput": nbInput,
                       "wControl": getLog2In(nbInput),
                       "clk": self.clkName,
                       "width": outWidth,
                       "input": inputName,
                       "wInput": int(nbInput * outWidth),
                       "output": outputName,
                       "control": controlName}
            self._addEntity(muxName, ("mux", dictMux))
        return self.getEntity(muxName)

    def _connectMux(self, muxNum, entityInfo):
        """ Generate the code to connect a Mux
        """
        pass

    def _genMux(self, muxNum):
        if muxNum not in self.muxes:
            entity = self._getMuxEntity(muxNum)[1]
            self._addVector(entity["control"], entity["wControl"])
            self._addVector(entity["input"], entity["wInput"])
            self.muxes[muxNum] = {"name": entity["name"]}
        else:
            warn("Trying to regenerate mux {}".format(muxNum))


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
    vhdlGen = deparserHDL(deparser, outputFolder, 'library', baseName)

    vhdlGen.genInputs()
    vhdlGen.genMuxes()
    vhdlGen.writeFiles(outputFiles)
