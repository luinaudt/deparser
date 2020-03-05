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
-- Last update: 2020-03-05
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

  signal almost_empty         : std_logic;  --! only one element to read
  signal almost_full          : std_logic;  --! only one place still available
  signal full, empty          : std_logic;  --! FIFO state
  signal ready_i              : std_logic;  --! the fifo is ready to receive value
  signal valid_i, valid_i_tmp : std_logic;  --! the fifo generates a valid output
  signal stream_out_val_tmp   : std_logic;  --! stream_out_valid_management
  signal stream_out_rdy_tmp   : std_logic;  --! previous stream_out_ready
begin  -- architecture behavioral
  stream_out_valid <= valid_i and stream_out_val_tmp;  --valid_i;
  stream_in_ready  <= ready_i;          --ready_i;
  valid_i          <= not empty;
  ready_i          <= not full;
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
      full  <= '0';
      empty <= '1';
    elsif rising_edge(clk) then
      almost_empty <= '0';
      almost_full  <= '0';
      if head_next = tail then          -- only one place left
        almost_full <= '1';
      end if;
      if tail_next = head then          -- only one element left
        almost_empty <= '1';
      end if;
      stream_out_rdy_tmp <= stream_out_ready;
      stream_out_val_tmp <= (stream_out_ready xnor stream_out_rdy_tmp);

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


  --! process to manage pointers
  --! \TODO Check how the tail management synthesize
  ptr_proc : process(clk, reset_n)
  begin
    if reset_n = reset_polarity then
      tail      <= (others => '0');
      tail_next <= to_unsigned(1, 9);
      head      <= (others => '0');
      head_next <= to_unsigned(1, 9);
    elsif rising_edge(clk) then
      -- management for reads
      if (valid_i and stream_out_ready) = '1' then  -- read
        if almost_empty /= '1' then
          tail      <= tail_next;
          tail_next <= tail + 1;
        end if;
      end if;
      --management for writes
      if (ready_i and stream_in_valid) = '1' then   -- write
        head      <= head_next;
        head_next <= head_next + 1;
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
      -- read
      data_out    <= fifo(to_integer(tail))(data_width - 1 downto 0);
      tlast_i_out <= fifo(to_integer(tail))(data_width);
      -- write
      if (ready_i and stream_in_valid) = '1' then
        fifo(to_integer(head)) <= tlast_i_in & data_in;
        if head = tail then             -- case when empty
          data_out    <= data_in;
          tlast_i_out <= tlast_i_in;
        end if;
      end if;

    end if;
  end process;



end architecture behavioral;
