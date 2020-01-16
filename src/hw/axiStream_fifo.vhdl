-------------------------------------------------------------------------------
-- Title      : axiStream_fifo
-- Project    : 
-------------------------------------------------------------------------------
-- File       : axiStream_fifo.vhdl
-- Author     : luinaud thomas  <luinaud@localhost.localdomain>
-- Company    : 
-- Created    : 2020-01-16
-- Last update: 2020-01-16
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: A simple AXI stream fifo
-------------------------------------------------------------------------------
-- Copyright (c) 2020 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2020-01-16  1.0      Thomas Luinaud  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AXI_stream is

  generic (
    data_width : natural := 256;        -- width of the data bus in bits
    depth      : natural := 512);       -- fifo depth 

  port (
    clk     : in std_logic;             -- axi clk
    reset_n : in std_logic;             -- asynchronous reset (active low)

    ready_m : in  std_logic;            -- slave ready
    valid_m : out std_logic;            -- indicate the transfer is valid
    data_m  : out std_logic_vector(data_width - 1 downto 0);  -- master data

    ready_s : in  std_logic;            -- master output is valid
    valid_s : out std_logic;            -- ready to receive
    data_s  : in  std_logic_vector(data_width - 1 downto 0)  -- slave data
    );
end entity;

architecture behavioral of AXI_stream is

begin  -- architecture behavioral



end architecture behavioral;
