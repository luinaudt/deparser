component mux is
  generic (
    nbInput       : natural;
    width         : natural;
    nbBitsControl : natural);
  port (
    clk     : in  std_logic;
    control : in  std_logic_vector(nbBitsControl - 1 downto 0);
    input   : in  std_logic_vector(nbInput * width - 1 downto 0);
    output  : out std_logic_vector(width - 1 downto 0));
end component mux;
