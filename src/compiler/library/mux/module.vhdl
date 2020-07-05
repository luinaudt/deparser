-------------------------------------------------------------------------------
-- Auto generated file
-- compiler version $compVersion
-- template version : 1.0
-- Mux 8 bits
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux is
  generic (
    nbInput       : natural := 8;       --! nbInputBits
    width         : natural := 8;
    nbBitsControl : natural := 8);

  port (
    clk     : in  std_logic;
    control : in  std_logic_vector(nbBitsControl - 1 downto 0);
    input   : in  std_logic_vector(nbInput * width - 1 downto 0);
    output  : out std_logic_vector(width - 1 downto 0));
end entity mux;

architecture behavioral of mux is
begin
  process(control, input) is
  begin
    output <= input(width - 1 downto 0);
    for i in 0 to nbInput - 1 loop
      if i = unsigned(control) then
        output <= input((i+1)*width - 1 downto i*width);
      end if;
    end loop;
  end process;
end architecture;
