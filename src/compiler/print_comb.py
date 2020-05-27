from gen_comb import genBitPos, sortListBitTuple


def genOrgTable(EntreeOpt, EntreeNonOpt):
    tableau = "|Sans optimisation|Etats |Avec Optimisation| Etats|"
    tableau += "\n|-+-+-+-|"
    for i in range(max(len(EntreeOpt), len(EntreeNonOpt))):
        tableau += "\n|"
        # Column1
        if i < len(EntreeNonOpt):
            tableau += "{}({})".format(EntreeNonOpt[i][0], EntreeNonOpt[i][1])
        tableau += "|"
        # Column 2
        if i < len(EntreeNonOpt):
            tableau += "{}".format(EntreeNonOpt[i][2])
        tableau += "|"
        # Column3
        if i < len(EntreeOpt):
            tableau += "{}({})".format(EntreeOpt[i][0], EntreeOpt[i][1])
        tableau += "|"
        # Column4
        if i < len(EntreeOpt):
            tableau += "{}".format(EntreeOpt[i][2])
        tableau += "|"
    return tableau


bus_width = 64
listeHeader = {"Eth": 112, "IP": 160, "TCP": 160, "Payload": bus_width}
Eth = "Eth"
TCP = "TCP"
IP = "IP"
listeCombinaison = [(Eth,),
                    (IP,),
                    (TCP,),
                    (Eth, IP),
                    (Eth, TCP),
                    (Eth, IP, TCP),
                    (IP, TCP)]
listeCombinaisonOpt = [(Eth,), (Eth, IP), (Eth, IP, TCP)]

listeEntreeNonOpt = genBitPos(listeCombinaison, listeHeader,
                              bus_width=bus_width, Payload=True)
listeEntreeOpt = genBitPos(listeCombinaisonOpt, listeHeader,
                           bus_width=bus_width, Payload=True)

listeEntreeNonOpt = sortListBitTuple(listeEntreeNonOpt, listeHeader)
listeEntreeOpt = sortListBitTuple(listeEntreeOpt, listeHeader)

print(genOrgTable(listeEntreeOpt, listeEntreeNonOpt))
