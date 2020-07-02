component $name is
  generic (
    nbInput      : natural);
  port (
    clk     : in  std_logic;
    control : in  std_logic_vector($nbControl - 1 downto 0);
    input   : in  std_logic_vector((nbInput * $width) - 1 downto 0);
    output  : out std_logic_vector($width downto 0));
end component $name;
