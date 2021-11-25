from warnings import warn
from random import randint
from math import log2, ceil
""" Some utility function for VHDL generation
"""


def getLog2In(nbInput):
    if nbInput == 0:
        return int(0)
    return int(ceil(log2(nbInput)))


def int2vector(val, vecSize):
    """
    return the string to have a std_logic_vector
    """
    return "std_logic_vector({})".format(int2unsigned(val, vecSize))


def int2unsigned(val, size=None):
    """ return to unsigned of a val
    if size unsupported add comment with random value
    """
    if size is None:
        return "unsigned({})".format(val)
    elif isinstance(size, str) or isinstance(size, int):
        return "to_unsigned({},{})".format(val, size)
    else:
        ret = "to_unsigned({},{}) -- ERROR {}".format(val,
                                                      size,
                                                      randint(0, 100))
        warn("unsupported value returned : {}".format(ret))
        return ret
