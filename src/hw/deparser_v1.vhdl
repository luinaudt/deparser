-------------------------------------------------------------------------------
-- Title      : deparser version1
-- Project    : 
-------------------------------------------------------------------------------
-- File       : deparser_v1.vhdl
-- Author     : luinaud thomas  <luinaud@localhost.localdomain>
-- Company    : 
-- Created    : 2019-10-02
-- Last update: 2020-04-23
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This file is a deparser for eth/IPv4/TCP in fix size version
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-10-02  1.0      luinaud Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.log2;
use ieee.math_real.ceil;

entity deparser is

  generic (
    nbInMux           : natural := 8;     -- number of input for each mux
    payloadStreamSize : natural := 64;    -- size of input payload
    outputStreamSize  : natural := 64;    -- size of output streaming
    ethsize           : natural := 112;   -- ethernet width
    ipv4size          : natural := 160;   -- IPv4 header size
    tcpSize           : natural := 160);  -- tcp header size

  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    en_deparser : in std_logic;
    ethBus       : in  std_logic_vector(ethsize-1 downto 0);
    ipv4Bus      : in  std_logic_vector(ipv4size - 1 downto 0);
    tcpBus       : in  std_logic_vector(tcpSize - 1 downto 0);
    ethValid     : in  std_logic;
    ipv4Valid    : in  std_logic;
    tcpValid     : in  std_logic;
-- output axi4 stream
    outputData   : out std_logic_vector(outputStreamSize - 1 downto 0);
    outputValid  : out std_logic;
    outputReady  : in  std_logic;
    outputKeep   : out std_logic_vector(outputStreamSize/8 - 1 downto 0);
    outputLast   : out std_logic;
-- input axi4 payload
    payloadData  : in  std_logic_vector(payloadStreamSize - 1 downto 0);
    payloadValid : in  std_logic;
    payloadReady : out std_logic;
    payloadKeep  : in  std_logic_vector(payloadStreamSize/8 - 1 downto 0);
    payloadLast  : in  std_logic);

end entity deparser;

-- inside the deparser we can buffer part of the packet
-- state machine for management.
architecture behavioral of deparser is
  type mux_t is array (0 to nbInMux - 1) of std_logic_vector(7 downto 0);  --all muxes
  type muxes_t is array (0 to outputStreamSize/8 - 1) of mux_t;
  type muxes_o_t is array (0 to outputStreamSize/8 - 1) of std_logic_vector(7 downto 0);
  type muxes_sel_t is array(0 to outputStreamSize/8 - 1) of integer range 0 to nbInMux - 1;  --control signals

  signal muxes_o : muxes_o_t;           -- all output muxes
  signal muxes   : muxes_t;             -- all input muxes
  signal sel     : muxes_sel_t;         -- all selector for muxes

  signal mux0_r : std_logic_vector(7 downto 0);
  signal mux1_r : std_logic_vector(7 downto 0);
  signal mux2_r : std_logic_vector(7 downto 0);
  signal mux3_r : std_logic_vector(7 downto 0);
  signal mux4_r : std_logic_vector(7 downto 0);
  signal mux5_r : std_logic_vector(7 downto 0);
  signal mux6_r : std_logic_vector(7 downto 0);
  signal mux7_r : std_logic_vector(7 downto 0);

  signal sels     : muxes_sel_t;
  signal full_hdr : std_logic_vector(ethsize + ipv4size + tcpSize + 2*payloadStreamSize - 1 downto 0);
begin  -- architecture behavioral


  

  full_hdr <= payloadData & payloadData & tcpBus & ipv4Bus & ethBus;

  Muxes_inputs : process(full_hdr)
  begin
    for i in muxes'range loop
      for j in muxes(i)'range loop
        muxes(i)(j) <= full_hdr((j*(muxes(i)'length) + i)*8 + 7 downto (j*muxes(i)'length + i)*8);
      end loop;
    end loop;
  end process;
  
  --! \brief generates all muxes
  muxes_generation : process(muxes, sel) is
  begin
    for i in muxes_o'range loop
      muxes_o(i) <= muxes(i)(sel(i));
    end loop;
  end process;


  --! \brief process to clk all muxes output
  muxes_registration : process(clk) is
  begin
    if rising_edge(clk) then
      mux0_r <= muxes_o(0);
      mux1_r <= muxes_o(1);
      mux2_r <= muxes_o(2);
      mux3_r <= muxes_o(3);
      mux4_r <= muxes_o(4);
      mux5_r <= muxes_o(5);
      mux6_r <= muxes_o(6);
      mux7_r <= muxes_o(7);
    end if;
  end process;


  data_out : process (clk, rst) is
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      outputData <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      outputData <= mux7_r & mux6_r & mux5_r & mux4_r & mux3_r & mux2_r & mux1_r & mux0_r;
    end if;
  end process;

end architecture behavioral;
