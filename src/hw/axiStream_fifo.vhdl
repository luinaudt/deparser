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
-- Last update: 2020-03-11
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

use ieee.math_real."log2";
use ieee.math_real."ceil";

entity AXI_stream is

  generic (
    reset_polarity : std_logic := '0';   --! reset polartity
    data_width     : natural   := 32;    --! width of the data bus in bits
    depth          : natural   := 512);  --! fifo depth 

  port (
    clk              : in  std_logic;   -- axi clk
    reset_n          : in  std_logic;   -- asynchronous reset (active low)
    -- master interface
    stream_out_ready : in  std_logic;   --! slave ready
    stream_out_tlast : out std_logic;   --! TLAST
    stream_out_valid : out std_logic;   --! indicate the transfer is valid
    stream_out_data  : out std_logic_vector(data_width - 1 downto 0);  --! master data
    -- slave interface
    stream_in_valid  : in  std_logic;   --! master output is valid
    stream_in_tlast  : in  std_logic;   --! TLAST
    stream_in_ready  : out std_logic;   --! ready to receive
    stream_in_data   : in  std_logic_vector(data_width - 1 downto 0)  --! slave data
    );
end entity;

architecture behavioral of AXI_stream is
  constant address_width         : natural  := integer(ceil(log2(real(depth))));
  -- memory signals
  type ram_type is array (0 to depth - 1) of std_logic_vector(1 + data_width - 1 downto 0);
  signal fifo                    : ram_type := (others => (others => '0'));  --! memory to store elements
  signal data_out, data_out_next : std_logic_vector(data_width downto 0);  --! out of memory
  signal data_in                 : std_logic_vector(data_width downto 0);  --! input of memory
  signal read_tail, set_tail     : std_logic;  --! read in memory
  signal write_head              : std_logic;  --! write in memory

  -- FIFO management
  signal head, head_next      : unsigned(address_width - 1 downto 0);  --! head of fifo
  signal tail, tail_next      : unsigned(address_width - 1 downto 0);  --! tail of fifo
  signal tail_next_1          : unsigned(address_width - 1 downto 0);  --! tail_next + 1
  signal tail_next_rd         : unsigned(address_width - 1 downto 0);  --! tail read
  signal almost_empty         : std_logic;  --! only one element to read
  signal almost_full          : std_logic;  --! only one place still available
  signal full, empty          : std_logic;  --! FIFO state
  signal ready_i              : std_logic;  --! the fifo is ready to receive value
  signal prev_empty           : std_logic;  --! previous state of empty
  -- AXI4 stream
  signal valid_i, valid_i_tmp : std_logic;  --! the fifo generates a valid output
  signal stream_out_val_tmp   : std_logic;  --! stream_out_valid_management
  signal stream_out_rdy_tmp   : std_logic;  --! previous stream_out_ready
  signal axi_read_valid       : std_logic;  --! valid handshake for read
  signal axi_write_valid      : std_logic;  --! valid handshake for read
begin  -- architecture behavioral

-- input/output management :
--      IN signals must be synchronous
  data_in          <= stream_in_tlast & stream_in_data;
--      OUT signals must be synchronous
  stream_out_data  <= data_out(data_width - 1 downto 0);
  stream_out_tlast <= data_out(data_width);

  -- AXI4 wrapper
  -- insertion
  axi_write_valid  <= ready_i and stream_in_valid;   --! handshake write
  axi_read_valid   <= valid_i and stream_out_ready;  --! handshake read
  stream_out_valid <= valid_i;
  stream_in_ready  <= ready_i;                       --ready_i;

  -- FIFO logic
  ready_i    <= not full;
--! write/read en signals
  write_head <= axi_write_valid;

  read_tail <= axi_read_valid;
  set_tail  <= (empty xor prev_empty) and not empty;
  valid_i   <= not (empty or prev_empty);
  -- ! sync status management
  status : process (clk)
  begin
    if rising_edge(clk) then
      prev_empty <= empty;

      if reset_n = reset_polarity then
        empty <= '1';
        full  <= '0';
      else
        if head /= tail then
          full  <= '0';
          empty <= '0';
        end if;
        if (almost_empty and read_tail) = '1' then
          empty <= '1';
        end if;
        if (almost_full and write_head) = '1' then
          full <= '1';
        end if;
      end if;
    end if;
  end process;

  comb_status : process(tail, head, tail_next, head_next)
  begin
    almost_full  <= '0';
    almost_empty <= '0';
    if head_next = tail then            -- only one place left
      almost_full <= '1';
    end if;
    if tail_next = head then            -- only one element left
      almost_empty <= '1';
    end if;
  end process;

--! Pointers management
--! \TODO Check how the tail management synthesize
  ptr_proc : process(clk)
  begin
    if rising_edge(clk) then
      -- reset
      if reset_n = reset_polarity then
        tail      <= (others => '0');
        tail_next <= (others => '0');
        head_next <= to_unsigned(1, address_width);
        head      <= (others => '0');
      else
        -- management for reads
        if empty = '1' then
          tail_next <= tail;
        end if;
        if read_tail = '1' then
          tail      <= tail_next;
          tail_next <= tail_next_1;
        end if;
        if set_tail = '1' then
          tail_next <= tail_next_1;
        end if;
        --management for writes
        if write_head = '1' then        -- write
          head      <= head_next;
          head_next <= head_next + 1;
        end if;
      end if;
    end if;
  end process;
  ptr_proc_async: process(tail_next, empty, tail, almost_empty, set_tail)
  begin
    if empty = '1' then
      tail_next_1 <= tail;
    elsif almost_empty = '1' then
      tail_next_1 <= tail_next;
    else
      tail_next_1 <= tail_next + 1;
    end if;
  end process;
  
-- Memory management real BRAM
--! write into memory
  ram_proc : process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = reset_polarity then
        tail_next_rd <= (others => '0');
      else
        -- read
        if (read_tail or set_tail) = '1' then
          tail_next_rd <= tail_next_1;
        end if;
        -- write
        if write_head = '1' then
          fifo(to_integer(head)) <= data_in;
        end if;
      end if;
    end if;
  end process;
  data_out_next <= fifo(to_integer(tail_next_rd));

--! generate output registers.
  output_register : process(clk)
  begin
    if rising_edge(clk) then
      if reset_n = reset_polarity then
        data_out <= (others => '0');
      elsif (set_tail or read_tail) = '1' then
        data_out <= data_out_next;
      end if;
    end if;
  end process;

end architecture behavioral;
