-------------------------------------------------------------------------------
-- Auto generated file
-- compiler version $compVersion
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deparser_t0 is

  generic (
    payloadStreamSize : natural := 64 ;    --! size of input payload
    outputStreamSize  : natural := 64 );    --! size of output streaming

  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    en_deparser       : in  std_logic;  --! enable emission 
-- inputBuses
    ethernet_bus : in std_logic_vector(112 - 1 downto 0);
    ipv4_bus : in std_logic_vector(160 - 1 downto 0);
    tcp_bus : in std_logic_vector(160 - 1 downto 0);
   
-- validBuses
    ethernet_valid : in std_logic;
    ipv4_valid : in std_logic;
    tcp_valid : in std_logic;

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

end entity deparser_t0;

architecture behavioral of deparser_t0 is
  type muxes_o_t is array (0 to 8 - 1) of std_logic_vector(7 downto 0);
  ----components
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

  ---signals
  signal muxes_0_ctrl : std_logic_vector(2 downto 0); 
signal muxes_0_in : std_logic_vector(55 downto 0); 
 
  signal muxes_o : muxes_o_t;           -- all output muxes_o
begin

  
mux_0 : entity work.mux
  generic map (nbInput => 7,
               width => 8,
               nbBitsControl => 3)
  port map (
    clk     => clk,
    control => muxes_0_ctrl,
    input   => muxes_0_in,
    output  => muxes_o(0));


  
  
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


