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
-- Last update: 2020-01-23
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

  type ram_type is array (0 to depth - 1) of std_logic_vector(1 + data_width - 1 downto 0);
  signal fifo : ram_type;               --! memory to store elements

  signal tlast_i_in, tlast_i_out : std_logic;  --! tlast internal signals
  signal tlast_i_out_next        : std_logic;  --! one clk cycle delay (sync to output)
  signal data_out, data_out_next : std_logic_vector(data_width - 1 downto 0);  --! out of memory
  signal data_in                 : std_logic_vector(data_width - 1 downto 0);  --! input of memory
  signal head, head_next         : unsigned(8 downto 0);  --! head of fifo
  signal tail, tail_next         : unsigned(8 downto 0);  --! tail of fifo

  signal almost_empty : std_logic;      --! only one element to read
  signal almost_full  : std_logic;      --! only one place still available
  signal full, empty  : std_logic;      --! FIFO state
  signal ready_i      : std_logic;      --! the fifo is ready to receive value
  signal valid_i      : std_logic;      --! the fifo generates a valid output
begin  -- architecture behavioral
  stream_in_ready  <= ready_i;
  stream_out_valid <= valid_i;
-- internal data signals :
--      IN signals must be synchronous
  data_in          <= stream_in_data;
  tlast_i_in       <= stream_in_tlast;
--      OUT signals must be synchronous
  stream_out_data  <= data_out;
  stream_out_tlast <= tlast_i_out;

  status : process (clk, reset_n)
  begin
    if reset_n = reset_polarity then
      full         <= '0';
      empty        <= '1';
      almost_full  <= '0';
      almost_empty <= '0';
    elsif rising_edge(clk) then
      almost_empty <= '0';
      almost_full  <= '0';
      full         <= full;
      empty        <= empty;
      if head_next = tail then          -- only one place free
        almost_full <= '1';
      end if;
      if tail_next = head then          -- only one element left
        almost_empty <= '1';
      end if;

      -- full and empty signal management
      if head /= tail then
        full  <= '0';
        empty <= '0';
      end if;

      if head = tail and almost_empty = '1' then
        empty <= '1';
      end if;

      if head = tail and almost_full = '1' then
        full <= '1';
      end if;
    end if;
  end process;

  process(head, tail, empty, full, almost_full, almost_empty)
  begin
    head_next <= head + 1;
    valid_i   <= '1';
    ready_i   <= '1';
    if (head = tail and almost_empty = '1') or empty = '1' then
      valid_i <= '0';
    end if;
    if (head = tail and almost_full = '1') or full = '1' then
      ready_i <= '0';
    end if;

  end process;

  --! process to manage pointers
  --! \TODO Check how the tail management synthesize
  ptr_proc : process(clk, reset_n)
  begin
    if reset_n = reset_polarity then
      tail <= (others => '0');
      tail_next <= to_unsigned(1,9);
      head <= (others => '0');
    elsif rising_edge(clk) then
      if (valid_i and stream_out_ready) = '1' then
        tail <= tail_next;
        tail_next <= tail_next + 1;
      end if;
      if (ready_i and stream_in_valid) = '1' then
        head <= head_next;
      end if;
    end if;
  end process;

  --! process to write and read from the fifo
  ram_proc : process(clk, reset_n)
  begin
    if reset_n = reset_polarity then
      data_out    <= (others => '0');
      tlast_i_out <= '0';
    elsif rising_edge(clk) then
      -- write
      if (ready_i and stream_in_valid) = '1' then
        fifo(to_integer(head)) <= tlast_i_in & data_in;
        if tail = head then
          data_out <= data_in;
          tlast_i_out <= tlast_i_in;
        end if;
      end if;
      -- read
      data_out_next    <= fifo(to_integer(tail_next))(data_width - 1 downto 0);
      tlast_i_out_next <= fifo(to_integer(tail_next))(data_width);
      if (valid_i and stream_out_ready) = '1' then
        data_out    <= data_out_next;
        tlast_i_out <= tlast_i_out_next;
      end if;
    end if;
  end process;



end architecture behavioral;
