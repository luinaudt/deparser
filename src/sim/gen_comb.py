#!/usr/bin/python

def genBitPos(combinaison, Entete, bus_width=64, muxNum=0, Payload=False):
    """ Gen list of unique tuple (name, pos, [Etat]) of the muxNum.
    Each tuple correspond to the bit of a protocol that have to be connected
    to the mux
    """
    def GetPosTuple(nom, pos, liste):
        for e, v in enumerate(listeEntree):
            if v[0] == nom and v[1] == pos:
                return e
        return 0
    if bus_width <= muxNum:
        raise ValueError("bus width {} smaller than mux number :{}".format(
            bus_width, muxNum))
    listeEntree = []
    EtatAssocie = []
    for combeNum, comb in enumerate(combinaison):
        pos = muxNum
        for j in comb:
            while pos < Entete[j]:
                if (j, pos) not in listeEntree:
                    listeEntree.append((j, pos))
                    EtatAssocie.append([])
                    EtatAssocie[-1].append(combeNum)
                else:
                    e = GetPosTuple(j, pos, listeEntree)
                    if combeNum not in EtatAssocie[e]:
                        EtatAssocie[e].append(combeNum)
                    else:
                        print("{}, {}".format(j, pos))
                pos += bus_width
            pos -= Entete[j]
        if Payload:
            if ("Payload", pos) not in listeEntree:
                listeEntree.append(("Payload", pos))
                EtatAssocie.append([])
                EtatAssocie[-1].append(combeNum)
            else:
                e = GetPosTuple("Payload", pos, listeEntree)
                if combeNum not in EtatAssocie[e]:
                    EtatAssocie[e].append(combeNum)
                else:
                    print("{}, {}".format(j, pos))
    for i, tup in enumerate(listeEntree):
        newTup = (tup[0], tup[1], EtatAssocie[i])
        listeEntree[i] = newTup

    return listeEntree


def sortListBitTuple(liste, headers):
    output = []

    def takeSecond(elem):
        return elem[1]

    for entete in headers:
        tmp = []
        for nom, pos, etat in liste:
            if nom == entete:
                tmp.append((nom, pos, etat))
        tmp.sort(key=takeSecond)
        output.extend(tmp)
    return output


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

# print(genOrgTable(listeEntreeOpt, listeEntreeNonOpt))
