-------------------------------------------------------------------------------
-- Title      : test for cocotb
-- Project    : 
-------------------------------------------------------------------------------
-- File       : testCocotb.vhdl
-- Author     : luinaud thomas  <luinaud@localhost.localdomain>
-- Company    : 
-- Created    : 2019-10-02
-- Last update: 2019-10-02
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This file test the correct installation of cocotb
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

entity cocotbTest is

  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    valueIn1    : in  std_logic_vector(7 downto 0);
    valueIn2    : in  std_logic_vector(7 downto 0);
    outputValue : out std_logic_vector(8 downto 0));

end entity cocotbTest;

architecture behavioral of cocotbTest is

begin  -- architecture behavioral
  process (clk, rst) is
  begin  -- process
    if rst = '0' then                   -- asynchronous reset (active low)
      outputValue <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      outputValue <= std_logic_vector(unsigned('0' & valueIn1)+unsigned('0' & valueIn2));
    end if;
  end process;

end architecture behavioral;
