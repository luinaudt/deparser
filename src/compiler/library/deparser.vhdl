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
    $phvBus           : in  std_logic_vector($phvBusWidth downto 0);
-- validBuses
    $phvValidity      : in  std_logic_vector($phvValidityWidth downto 0);
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
  signal out_valid, deparser_rdy_i : std_logic_vector($nbMuxes - 1 downto 0);
  signal deparser_rdy              : std_logic;
  signal start_deparser            : std_logic;
  signal packet_out_tvalid_tmp     : std_logic;
  signal packet_out_tlast_tmp      : std_logic;
  signal packet_out_tkeep_tmp      : std_logic_vector(packet_out_tkeep'range);
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

  process(clk) is
    variable out_valid_tmp  : std_logic;
    variable not_finish_tmp : std_logic;
  begin
    if rising_edge(clk) then
      start_deparser <= en_deparser and deparser_rdy;
      for i in muxes_o'range loop
        packet_out_tdata((i+1) * 8 - 1 downto i*8) <= muxes_o(i);
      end loop;
      --axi stream control
      packet_out_tlast_tmp <= '0';
      packet_out_tkeep_tmp <= out_valid;
      -- packet out tvalid gen
      out_valid_tmp        := '0';
      not_finish_tmp       := '1';
      for i in out_valid'range loop
        out_valid_tmp  := out_valid_tmp or out_valid(i);
        not_finish_tmp := not_finish_tmp and out_valid(i);
      end loop;
      packet_out_tvalid_tmp <= out_valid_tmp;
      packet_out_tlast_tmp  <= not not_finish_tmp;
    -- packet out tkeep gen
    end if;
  end process;
  packet_out_tkeep  <= packet_out_tkeep_tmp;
  packet_out_tvalid <= packet_out_tvalid_tmp;
  packet_out_tlast  <= packet_out_tlast_tmp;
  -- packet_out_tdata  <= packet_out_tdata_tmp;

end architecture behavioral;


