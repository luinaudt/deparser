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
    nbInput      : natural := $nbInput);     --! nbInputBits

  port (
    clk     : in  std_logic;
    reset_n : in  std_logic;
    control : in  std_logic_vector($nbControl - 1 downto 0);
    input   : in  std_logic_vector(nbInput * $muxWidth - 1 downto 0);
    output  : out std_logic_vector($muxWidth - 1 downto 0));
end entity $name;

architecture behavioral of $name is
begin
  process(control, input) is
  begin
    output <= input($muxWidth - 1 downto 0);
    for i in 0 to nbInput loop
      if i = unsigned(control) then
        output <= input((i+1)*${muxWidth} - 1 downto i*${muxWidth});
      end if;
    end loop;
  end process;
end architecture;
