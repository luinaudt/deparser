-------------------------------------------------------------------------------
-- Auto generated file
-- compiler version $compVersion
-- template version : 1.0
-- Mux 8 bits
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity $name is
  generic (
    nbHeader    : natural := 8;         --! nbInputBits
    outputWidth : natural := 3);

  port (
    clk         : in  std_logic;
    reset_n     : in  std_logic;
    start       : in  std_logic;
    finish      : out std_logic;
    headerValid : in  std_logic_vector(nbHeader - 1 downto 0);
    output      : out std_logic_vector(outputWidth - 1 downto 0));
end entity $name;

architecture behavioral of $name is
begin

end architecture;
