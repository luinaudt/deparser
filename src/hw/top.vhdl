-------------------------------------------------------------------------------
-- Title      : Top Module
-- Project    : deparser
-------------------------------------------------------------------------------
--! \file       : top.vhdl
--! \author     : luinaud thomas  <luinaud@localhost.localdomain>
--! \brief      : Top module for deparser
-------------------------------------------------------------------------------
-- Company    : 
-- Created    : 2020-01-16
-- Last update: 2020-03-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Deparser
-------------------------------------------------------------------------------
-- Copyright (c) 2020 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-16  1.0      luinaud Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.log2;
use ieee.math_real.ceil;

entity deparser_top is

  generic (
    reset_polarity : std_logic := '0');  --! reset polartity

  port (
    clk              : in  std_logic;   -- axi clk
    reset_n          : in  std_logic;   -- asynchronous reset (active low)
    -- master interface
    stream_out_ready : in  std_logic;   --! slave ready
    stream_out_tlast : out std_logic;   --! TLAST
    stream_out_valid : out std_logic;   --! indicate the transfer is valid
    stream_in_keep   : out std_logic_vector(32/8 - 1 downto 0)
    stream_out_data  : out std_logic_vector(31 downto 0);  --! master data
    -- slave interface
    stream_in_valid  : in  std_logic;   --! master output is valid
    stream_in_tlast  : in  std_logic;   --! TLAST
    stream_in_ready  : out std_logic;   --! ready to receive
    stream_in_keep   : in  std_logic_vector(32/8 - 1 downto 0)
    stream_in_data   : in  std_logic_vector(31 downto 0)   --! slave data
    );
end entity;

architecture behavioral of deparser_top is
  signal intermediate_ready : std_logic;
  signal intermediate_valid : std_logic;
  signal intermediate_data  : std_logic_vector(31 downto 0);
  signal intermediate_tlast : std_logic;
  signal intermediate_keep  : std_logic_vector(32/8 - 1 downto 0);
begin
  fifo1 : entity work.AXI_stream(behavioral)
    generic map (reset_polarity => reset_polarity,
                 data_width     => 32,
                 depth          => 512)
    port map(clk              => clk,
             reset_n          => reset_n,
             stream_out_ready => intermediate_ready,
             stream_out_tlast => intermediate_tlast,
             stream_out_valid => intermediate_valid,
             stream_out_keep  => intermediate_keep,
             stream_out_data  => intermediate_data,
             stream_in_valid  => stream_in_valid,
             stream_in_tlast  => stream_in_tlast,
             stream_in_keep   => stream_in_keep,
             stream_in_ready  => stream_in_ready,
             stream_in_data   => stream_in_data
             );
  fifo2 : entity work.AXI_stream(behavioral)
    generic map (reset_polarity => reset_polarity,
                 data_width     => 32,
                 depth          => 512)
    port map(clk              => clk,
             reset_n          => reset_n,
             stream_out_ready => stream_out_ready,
             stream_out_tlast => stream_out_tlast,
             stream_out_valid => stream_out_valid,
             stream_out_keep  => stream_out_keep,
             stream_out_data  => stream_out_data,
             stream_in_valid  => intermediate_valid,
             stream_in_tlast  => intermediate_tlast,
             stream_in_ready  => intermediate_ready,
             stream_in_keep   => intermediate_keep,
             stream_in_data   => intermediate_data
             );
end architecture;
