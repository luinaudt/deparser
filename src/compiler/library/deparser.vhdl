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
    deparser_ready    : out std_logic;  --| ready to deparse new packet
-- inputBuses
    $phvBus           : in  std_logic_vector($phvBusWidth downto 0);
-- validBuses
    $phvValidity      : in  std_logic_vector($phvValidityWidth downto 0);
    phvPayloadValid   : in  std_logic;  --! should be always 1, indicate if the
                                        --packet has payload
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
  type keep_o_t is array (0 to $nbMuxes - 1) of std_logic_vector(0 downto 0);
  ----components
  $components
    ---signals
    $signals

    -- constant signals
    signal muxes_o, payload_o_data : muxes_o_t;  -- all output muxes_o
  signal payload_o_keep            : keep_o_t;
  signal out_valid, deparser_rdy_i : std_logic_vector($nbMuxes - 1 downto 0);
  signal deparser_rdy, dep_rdy_tmp : std_logic;
  signal start_deparser            : std_logic;
  signal emitPayload               : std_logic;  -- should emit payload
  signal last_header               : std_logic;  -- last header emitted
  signal payload_in_tlast_tmp      : std_logic;

  -- control signals
  signal out_valid_tmp         : std_logic_vector(out_valid'range);
  signal header_valid          : std_logic;
  signal muxes_o_tmp           : muxes_o_t;  -- delayed muxes output
  -- selector output
  signal packet_out_tvalid_tmp : std_logic;
  signal packet_out_tlast_tmp  : std_logic;
  signal packet_out_tkeep_tmp  : std_logic_vector(packet_out_tkeep'range);
  signal packet_out_tdata_tmp  : std_logic_vector(packet_out_tdata'range);

begin
  $code

    $entities

    $muxes

    $payloadConnect

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

  -- header shifter management
  process(clk) is
  begin
    if rising_edge(clk) then
      out_valid_tmp <= out_valid;
      muxes_o_tmp   <= muxes_o;
    end if;
  end process;

  process(clk, reset_n) is
    variable out_valid_merge     : std_logic;
    variable out_valid_merge_fut : std_logic;
  begin
    if reset_n = '0' then
      dep_rdy_tmp    <= '0';
      last_header    <= '0';
      header_valid   <= '0';
      start_deparser <= '0';
    elsif rising_edge(clk) then
      -- tmp variable for header deparsing
      out_valid_merge     := '0';
      out_valid_merge_fut := '0';
      for i in out_valid'range loop
        out_valid_merge := out_valid_merge or out_valid_tmp(i);
        out_valid_merge_fut := out_valid_merge_fut or out_valid(i);
      end loop;
      header_valid <= out_valid_merge;
      last_header  <= not out_valid_merge_fut and out_valid_merge;  -- falling edge detector
      -- output validity
      dep_rdy_tmp  <= deparser_rdy;
      if start_deparser = '1' then
        dep_rdy_tmp <= '0';
      end if;
      start_deparser <= en_deparser and dep_rdy_tmp;
    end if;
  end process;

  -- selector merger
  process (clk) is
  begin
    if rising_edge(clk) then
      payload_in_tlast_tmp <= payload_in_tlast;
      emitPayload          <= '0';
      if payload_in_tvalid = '1' then
        emitPayload <= emitPayload;
        if last_header = '1' then
          emitPayload <= '1';
        end if;
        if emitPayload = '1' then
          packet_out_tvalid_tmp <= payload_in_tvalid;
          packet_out_tlast_tmp <= payload_in_tlast;
        else
          packet_out_tvalid_tmp <= header_valid;
        end if;
      else
        packet_out_tlast_tmp  <= last_header;
        packet_out_tvalid_tmp <= header_valid;
      end if;
      
      -- keep and data selection
      for i in payload_o_data'range loop
        if out_valid_tmp(i) = '1' then
          packet_out_tdata_tmp((i+1) * 8 - 1 downto i*8) <= muxes_o_tmp(i);
          packet_out_tkeep_tmp(i)                        <= out_valid_tmp(i);
        else
          packet_out_tdata_tmp((i+1) * 8 - 1 downto i*8) <= payload_o_data(i);
          packet_out_tkeep_tmp(i)                        <= payload_o_keep(i)(0);
        end if;
      end loop;
    -- output sync
    end if;
  end process;
  -- tlast management
  payload_in_tready <= emitPayload;
  packet_out_tlast  <= packet_out_tlast_tmp;
  deparser_ready    <= dep_rdy_tmp;
  packet_out_tkeep  <= packet_out_tkeep_tmp when rising_edge(clk);
  packet_out_tvalid <= packet_out_tvalid_tmp;
  packet_out_tdata  <= packet_out_tdata_tmp when rising_edge(clk);

end architecture behavioral;


