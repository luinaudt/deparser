import networkx as nx
from networkx.drawing import nx_agraph


listeTuple = ["eth", "ipv4", "ipv6", "tcp", "udp"]  # conversion de nom

G = nx.DiGraph([("start", "eth"), ("eth", "ipv4"), ("ipv4", "ipv6"),
                ("ipv6", "tcp"), ("tcp", "udp")])

Gc = nx.transitive_closure(G)
nx_agraph.write_dot(G, "./OriginalGraphTest.dot")
G.remove_node("start")
Stmp = [(0, 1, 3), (0, 1, 4), (0, 2), (0, 2, 4)]
S = []
for i in Stmp:
    tmp = []
    for j in i:
        tmp.append(listeTuple[j])
    S.append(tuple(tmp))

GMin = nx.DiGraph()
for i in S:
    tmp = nx.subgraph(Gc, i)
    GMin = nx.compose(GMin, tmp)
GMin = nx.transitive_reduction(GMin)

# draw gaphs
nx_agraph.write_dot(G, "./OriginalGraph.dot")
nx_agraph.write_dot(Gc, "./ClosedGraph.dot")
nx_agraph.write_dot(GMin, "./FinalGraph.dot")
