from collections import OrderedDict


def genListCombinaison(P4Graph):
    """ Generate a set of tuples from graph.
    Each tuple represents possible active headers at the same time
    """
    combinaison = []
    
    return combinaison


def genListHeaders(P4Graph):
    """ Generate the dictionnary of headers.
    P4Graph : JSon imported file 
    Name, size
    """
    headers = OrderedDict()
    
    return headers

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
