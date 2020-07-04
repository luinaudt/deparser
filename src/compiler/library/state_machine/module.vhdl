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
    start_dep   : in  std_logic;
    finish      : out std_logic;
    ready       : out std_logic;
    headerValid : in  std_logic_vector(nbHeader - 1 downto 0);
    output      : out std_logic_vector(outputWidth - 1 downto 0));
end entity $name;

architecture behavioral of $name is
  type STATE_T is ${stateList};
  signal CURRENT_STATE : STATE_T;
  signal NEXT_STATE    : STATE_T;
begin

  process(clk, reset_n) is
  begin
    if reset_n = '0' then
      CURRENT_STATE <= $initState;
    elsif rising_edge(clk) then
      CURRENT_STATE <= NEXT_STATE;
    end if;
  end process;

  process (CURRENT_STATE) is
  begin
    NEXT_STATE <= CURRENT_STATE;
    finish     <= '0';
    case CURRENT_STATE is
      when $initState =>
        output <= (others => '0');
        ready  <= '1';
        if start_dep = '1' then
          NEXT_STATE <= ${lastState};
          $initStateTransition
        end if;
      when $lastState =>
        finish     <= '1';
        NEXT_STATE <= ${initState};

        $otherStateTransition
    end case;
  end process;

end architecture;
