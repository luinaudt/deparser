component $name is
  generic (
    nbHeader    : natural;         --! nbInputBits
    outputWidth : natural);

  port (
    clk         : in  std_logic;
    reset_n     : in  std_logic;
    start       : in  std_logic;
    finish      : out std_logic;
    headerValid : in  std_logic_vector(nbHeader - 1 downto 0);
    output      : out std_logic_vector(outputWidth - 1 downto 0));
end component $name;
