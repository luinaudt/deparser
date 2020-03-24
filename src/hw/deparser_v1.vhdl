-------------------------------------------------------------------------------
-- Title      : deparser version1
-- Project    : 
-------------------------------------------------------------------------------
-- File       : deparser_v1.vhdl
-- Author     : luinaud thomas  <luinaud@localhost.localdomain>
-- Company    : 
-- Created    : 2019-10-02
-- Last update: 2020-03-24
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

entity deparser is

  generic (
    payloadStreamSize : natural := 256;   -- size of input payload
    outputStreamSize  : natural := 256;   -- size of output streaming
    ethsize           : natural := 112;   -- ethernet width
    ipv4size          : natural := 160;   -- IPv4 header size
    tcpSize           : natural := 160);  -- tcp header size

  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
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

begin  -- architecture behavioral

  process (clk, rst) is
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      outputData <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      outputData <= ipv4Bus(outputStreamSize - ethsize - 1 downto 0) & ethBus;
    end if;
  end process;

end architecture behavioral;
