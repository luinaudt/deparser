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
-- Last update: 2020-01-22
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: FIFO : Slave --> Master
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
    reset_polarity : std_logic := '0';   --! reset polartity
    data_width     : natural   := 256;   --! width of the data bus in bits
    depth          : natural   := 512);  --! fifo depth 

  port (
    clk     : in  std_logic;            -- axi clk
    reset_n : in  std_logic;            -- asynchronous reset (active low)
    -- master interface
    ready_m : in  std_logic;            --! slave ready
    tlast_m : out std_logic;            --! TLAST
    valid_m : out std_logic;            --! indicate the transfer is valid
    data_m  : out std_logic_vector(data_width - 1 downto 0);  --! master data
    -- slave interface
    valid_s : in  std_logic;            --! master output is valid
    tlast_s : in  std_logic;            --! TLAST
    ready_s : out std_logic;            --! ready to receive
    data_s  : in  std_logic_vector(data_width - 1 downto 0)   --! slave data
    );
end entity;

architecture behavioral of AXI_stream is

  type ram_type is array (0 to depth - 1) of std_logic_vector(1 + data_width - 1 downto 0);
  signal fifo : ram_type;               --! memory to store elements

  signal tlast_i_in, tlast_i_out : std_logic;  --! tlast internal signals
  signal data_out                : std_logic_vector(data_width - 1 downto 0);  --! out of memory
  signal data_in                 : std_logic_vector(data_width - 1 downto 0);  --! input of memory
  signal head, head_next          : unsigned(8 downto 0);  --! head of fifo
  signal tail                    : unsigned(8 downto 0);  --! tail of fifo

  signal ready_i : std_logic;           --! the fifo is ready to receive value
  signal valid_i : std_logic;           --! the fifo generates a valid output
begin  -- architecture behavioral
  head_next   <= head + 1;
  ready_s    <= ready_i;
  valid_m    <= valid_i;
-- internal data signals :
--      IN signals must be synchronous
  data_in    <= data_s;
  tlast_i_in <= tlast_s;
--      OUT signals must be synchronous
  data_m     <= data_out;
  tlast_m    <= tlast_i_out;

  --! process to manage fifo input / writing
  input : process(clk, reset_n)
  begin
    if reset_n = reset_polarity then
      ready_i <= '0';
      head <= (others => '0');
    elsif rising_edge(clk) then
      if head_next /= tail then
        ready_i <= '1';
      else
        ready_i <= '0';
      end if;
      if (ready_i and valid_s) = '1' then
        head <= head_next;
      end if;
    end if;
  end process;

  --! process to manage fifo output / reading
  output : process(clk, reset_n)
  begin
    if reset_n = reset_polarity then
      valid_i <= '0';
      tail <= (others => '0');
    elsif rising_edge(clk) then
      if head /= tail then
        valid_i <= '1';
      else
        valid_i <= '0';
      end if;
      if (valid_i and ready_m) = '1' then
        tail <= tail + 1;
      end if;
    end if;
  end process;

  --! process to write and read from the fifo
  ram_proc : process(clk)
  begin
    if rising_edge(clk) then
      if (ready_i and valid_s) = '1'then
        fifo(to_integer(head)) <= tlast_i_in & data_in;
      end if;
      if (valid_i and ready_m) = '1'then
        data_out    <= fifo(to_integer(tail))(data_width - 1 downto 0);
        tlast_i_out <= fifo(to_integer(tail))(data_width);
      end if;
    end if;
  end process;



end architecture behavioral;
