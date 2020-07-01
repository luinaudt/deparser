-------------------------------------------------------------------------------
-- Auto generated file
-- compiler version $compVersion
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity $name is

  generic (
    payloadStreamSize : natural := $payloadSize ;    --! size of input payload
    outputStreamSize  : natural := $outputSize );    --! size of output streaming

  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    en_deparser       : in  std_logic;  --! enable emission 
-- inputBuses
$inputBuses   
-- validBuses
$validityBits
-- input axi4 payload
    payload_in_tdata  : in  std_logic_vector(payloadStreamSize - 1 downto 0);
    payload_in_tvalid : in  std_logic;
    payload_in_tready : out std_logic;
    payload_in_tkeep  : in  std_logic_vector(payloadStreamSize/8 - 1 downto 0);
    payload_in_tlast  : in  std_logic;
-- output axi4 stream
    packet_out_tdata  : out std_logic_vector(outputStreamSize - 1 downto 0);
    packet_out_tvalid : out std_logic;
    packet_out_tready : in  std_logic;
    packet_out_tkeep  : out std_logic_vector(outputStreamSize/8 - 1 downto 0);
    packet_out_tlast  : out std_logic);

end entity $name;

architecture behavioral of $name is
  type muxes_o_t is array (0 to $nbMuxes - 1) of std_logic_vector(7 downto 0);

  $signals 
  signal muxes_o : muxes_o_t;           -- all output muxes_o
begin


  -- output assignment
  process(clk) is
  begin
    if rising_edge(clk) then
      for i in muxes_o'range loop
        packet_out_tdata((i+1) * 8 - 1 downto i*8) <= muxes_o(i);
      end loop;
    end if;
  end process;
end architecture behavioral;


