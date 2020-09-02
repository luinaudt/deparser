component payload_shifter is
  generic (
    nbInput       : natural;
    dataWidth     : natural;
    keepWidth     : natural;
    nbBitsControl : natural);
  port (
    clk     : in  std_logic;
    ctrl    : in  std_logic_vector(nbBitsControl - 1 downto 0);
    data    : in  std_logic_vector(nbInput * dataWidth - 1 downto 0);
    keep    : in  std_logic_vector(nbInput * keepWidth - 1 downto 0);
    selKeep : out std_logic_vector(keepWidth -1 downto 0);
    selData : out std_logic_vector(dataWidth - 1 downto 0));
end component payload_shifter;
