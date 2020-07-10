-------------------------------------------------------------------------------
-- Auto generated file
-- compiler version $compVersion
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ${name}_tb is
  generic(
    payloadStreamSize : natural := $payloadSize;  --! size of input payload
    outputStreamSize  : natural := $outputSize);  --! size of output streaming
  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    deparser_ready    : out std_logic;
    en_deparser       : in  std_logic;            --! enable emission 
-- inputBuses
    $headerBuses
-- validBuses
    $validityBits
    phvPayloadValid   : in  std_logic;
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

end entity ${name}_tb;

architecture behavioral of ${name}_tb is
  signal phvBus      : std_logic_vector($phvBusWidth downto 0)      := (others => '0');
  signal validityBus : std_logic_vector($phvValidityWidth downto 0) := (others => '0');
begin

  $setPhvBus

    $setValBus

    ${name}_ent : entity work.${name}
    generic map (payloadStreamSize => $payloadSize,
                 outputStreamSize  => $payloadSize)
    port map (
      clk               => clk,
      reset_n           => reset_n,
      deparser_ready    => deparser_ready,
      en_deparser       => en_deparser,
-- inputBuses           
      $phvBus           => phvBus,
-- validBuses           
      $phvValidity      => validityBus,
      phvPayloadValid   => phvPayloadValid,
-- input axi4 payload   
      payload_in_tdata  => payload_in_tdata,
      payload_in_tvalid => payload_in_tvalid,
      payload_in_tready => payload_in_tready,
      payload_in_tkeep  => payload_in_tkeep,
      payload_in_tlast  => payload_in_tlast,
-- output axi4 stream   
      packet_out_tdata  => packet_out_tdata,
      packet_out_tvalid => packet_out_tvalid,
      packet_out_tready => packet_out_tready,
      packet_out_tkeep  => packet_out_tkeep,
      packet_out_tlast  => packet_out_tlast
      );
end architecture;
