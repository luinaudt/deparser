#!/usr/bin/python


def genBitPos(combinaison, Entete, bus_width=64, muxNum=0):
    """ Gen list of unique tuple (name, pos) of the muxNum.
    Each tuple correspond to the bit of a protocol that have to be connected
    to the mux
    """
    if bus_width <= muxNum:
        raise ValueError("bus width {} smaller than mux number :{}".format(
            bus_width, muxNum))
    listeEntree = []
    for comb in combinaison:
        pos = muxNum
        for j in comb:
            while pos < Entete[j]:
                if (j, pos) not in listeEntree:
                    listeEntree.append((j, pos))
                pos += bus_width
            pos -= Entete[j]
    return listeEntree


def sortListBitTuple(liste, headers):
    output = []

    def takeSecond(elem):
        return elem[1]

    for entete in headers:
        tmp = []
        for nom, pos in liste:
            if nom == entete:
                tmp.append((nom, pos))
        tmp.sort(key=takeSecond)
        output.extend(tmp)
    return output


def genOrgTable(EntreeOpt, EntreeNonOpt):
    tableau = "|Sans optimisation| Avec Optimisation|\n|--+--|"
    for i in range(max(len(EntreeOpt), len(EntreeNonOpt))):
        tableau += "\n|"
        if i < len(EntreeNonOpt):
            tableau += "{}({})".format(EntreeNonOpt[i][0], EntreeNonOpt[i][1])
        tableau += "|"
        if i < len(EntreeOpt):
            tableau += "{}({})".format(EntreeOpt[i][0], EntreeOpt[i][1])
        tableau += "|"
    return tableau


listeHeader = {"Eth": 112, "IP": 160, "TCP": 160}
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

listeEntreeNonOpt = genBitPos(listeCombinaison, listeHeader, bus_width=128)
listeEntreeOpt = genBitPos(listeCombinaisonOpt, listeHeader, bus_width=128)

listeEntreeNonOpt = sortListBitTuple(listeEntreeNonOpt, listeHeader)
listeEntreeOpt = sortListBitTuple(listeEntreeOpt, listeHeader)

print(genOrgTable(listeEntreeOpt, listeEntreeNonOpt))
