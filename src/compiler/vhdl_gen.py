from colorama import Fore, Style
from string import Template
from os import path, mkdir


def _validateInputs(a):
    """ a : list of three tuples :
    (Type got, variable Name, expected type)
    """
    val = True
    # validate input
    for g, n, e in a:
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
    with open('deparser_vhdl.template', 'r') as myfile:
        tempOutput = Template(myfile.read())

    headerBus = {}  # corresponding table for header name to bus name
    validity = {}  # corresponding table for header name to validity bit name

    inputTmpl = Template("    ${name} : "
                         "in std_logic_vector($size - 1 downto 0);"
                         "\n")
    validityTmpl = Template("    ${name} : in std_logic;\n")
    validityStr = ""
    inputStr = ""
    for h, size in deparser.headers.items():
        nameBus = h + "_bus"
        nameVal = h + "_valid"
        inputStr += inputTmpl.substitute({'name': nameBus, 'size': size})
        validityStr += validityTmpl.substitute({'name': nameVal})
        headerBus[h] = nameBus
        validity[h] = nameVal

    dictSub = {'name': baseName,
               'payloadSize': deparser.busSize,
               'outputSize': deparser.busSize,
               'inputBuses': inputStr,
               'validityBits': validityStr,
               'nbMuxes': deparser.nbStateMachine}

    with open(outputFiles, 'w') as outFile:
        outFile.write(tempOutput.safe_substitute(dictSub))
