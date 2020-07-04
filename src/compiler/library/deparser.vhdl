-------------------------------------------------------------------------------
-- Auto generated file
-- compiler version $compVersion
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity $name is

  generic (
    payloadStreamSize : natural := $payloadSize;  --! size of input payload
    outputStreamSize  : natural := $outputSize);  --! size of output streaming

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
  ----components
  $components
    ---signals
    $signals
    signal muxes_o : muxes_o_t;         -- all output muxes_o
  signal endDeparser, deparser_rdy_i        : std_logic_vector($nbMuxes - 1 downto 0);
  signal deparser_rdy                       : std_logic;
  signal start_deparser_reg, start_deparser : std_logic;
  signal packet_out_tvalid_tmp              : std_logic;
  signal packet_out_tlast_tmp               : std_logic;
  signal packet_out_tkeep_tmp               : std_logic_vector(packet_out_tkeep'range);
--  signal packet_out_tdata_tmp               : std_logic_vector(packet_out_tdata'range);
begin
  $code

    $entities

    $muxes

    -- output assignment
    process(deparser_rdy_i) is
      variable tmp : std_logic;
    begin
      tmp := '1';
      for i in deparser_rdy_i'range loop
        tmp := tmp and deparser_rdy_i(i);
      end loop;
      deparser_rdy <= tmp;
    end process;
  start_deparser <= en_deparser and deparser_rdy;
  process(clk) is
  begin
    if rising_edge(clk) then
      start_deparser_reg <= start_deparser;
      for i in muxes_o'range loop
        packet_out_tdata((i+1) * 8 - 1 downto i*8) <= muxes_o(i);
      end loop;

      --axi stream control
      packet_out_tlast_tmp <= '0';
      packet_out_tkeep_tmp <= packet_out_tkeep_tmp xor endDeparser;
      -- packet out tvalid gen
      if deparser_rdy = '1' then
        packet_out_tvalid_tmp <= '0';
      end if;
      if start_deparser_reg = '1' then
        packet_out_tvalid_tmp <= '1';
        packet_out_tkeep_tmp  <= (others => '1');
      end if;
      if endDeparser(0) = '1' then
        packet_out_tvalid_tmp <= '0';
        packet_out_tlast_tmp  <= '1';
      end if;
    -- packet out tkeep gen
    end if;
  end process;
  packet_out_tkeep  <= packet_out_tkeep_tmp;
  packet_out_tvalid <= packet_out_tvalid_tmp;
  packet_out_tlast <=   endDeparser(0); -- packet_out_tlast_tmp;
  -- packet_out_tdata  <= packet_out_tdata_tmp;

end architecture behavioral;


