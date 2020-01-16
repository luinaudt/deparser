-------------------------------------------------------------------------------
-- Title      : axi stream
-- Project    : 
-------------------------------------------------------------------------------
--! \file       : axiStream_fifo.vhdl
--! \author     : luinaud thomas  <luinaud@localhost.localdomain>
--! \brief      : axi stream fifo to validate axi slave and master interface
-------------------------------------------------------------------------------
-- Company    : 
-- Created    : 2020-01-16
-- Last update: 2020-01-16
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
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

entity AXI_stream is

  generic (
    data_width : natural := 256;        --! width of the data bus in bits
    depth      : natural := 512);       --! fifo depth 

  port (
    clk     : in  std_logic;            -- axi clk
    reset_n : in  std_logic;            -- asynchronous reset (active low)
    -- master interface
    ready_m : in  std_logic;            --! slave ready
    valid_m : out std_logic;            --! indicate the transfer is valid
    data_m  : out std_logic_vector(data_width - 1 downto 0);  --! master data
    -- slave interface
    ready_s : in  std_logic;            --! master output is valid
    valid_s : out std_logic;            --! ready to receive
    data_s  : in  std_logic_vector(data_width - 1 downto 0)   --! slave data
    );
end entity;

architecture behavioral of AXI_stream is

  type ram_type is array (0 to depth - 1) of std_logic_vector(data_m'range);
  signal fifo : ram_type;               --! memory to store elements

  signal head : unsigned(fifo'range);            --! head of fifo
  signal tail : unsigned(fifo'range)index_type;  --! tail of fifo

  signal ready_i : std_logic;           --! the fifo is ready to receive value
  signal valid_i : std_logic;           --! the fifo generates a valid output
begin  -- architecture behavioral
  --! process to manage fifo handshake
  
  --! process to write and read from the fifo
  ram_proc : process(clk)
  begin
    if rising_edge(clk) then
      if (ready_i and ready_s) = '1'then
        fifo(head) <=data_s;
      end if
      if (valid_i and valid_s) = '1'then
        data_m <= fifo(tail);
      end if;
    end if;
  end process;



end architecture behavioral;
