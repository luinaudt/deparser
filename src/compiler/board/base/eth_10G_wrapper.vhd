--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Thu Jul  9 16:45:23 2020
--Host        : lenovo-thomas running 64-bit Antergos Linux
--Command     : generate_target eth_10G_wrapper.bd
--Design      : eth_10G_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity eth_10G_wrapper is
  port (
    axis_rx_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    axis_rx_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    axis_rx_tlast : out STD_LOGIC;
    axis_rx_tuser : out STD_LOGIC;
    axis_rx_tvalid : out STD_LOGIC;
    axis_tx_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    axis_tx_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axis_tx_tlast : in STD_LOGIC;
    axis_tx_tready : out STD_LOGIC;
    axis_tx_tuser : in STD_LOGIC;
    axis_tx_tvalid : in STD_LOGIC;
    clk_100MHz : in STD_LOGIC;
    ctl_rx_ctl_rx_check_preamble : in STD_LOGIC;
    ctl_rx_ctl_rx_check_sfd : in STD_LOGIC;
    ctl_rx_ctl_rx_data_pattern_select : in STD_LOGIC;
    ctl_rx_ctl_rx_delete_fcs : in STD_LOGIC;
    ctl_rx_ctl_rx_enable : in STD_LOGIC;
    ctl_rx_ctl_rx_force_resync : in STD_LOGIC;
    ctl_rx_ctl_rx_ignore_fcs : in STD_LOGIC;
    ctl_rx_ctl_rx_max_packet_len : in STD_LOGIC_VECTOR ( 14 downto 0 );
    ctl_rx_ctl_rx_min_packet_len : in STD_LOGIC_VECTOR ( 7 downto 0 );
    ctl_rx_ctl_rx_process_lfi : in STD_LOGIC;
    ctl_rx_ctl_rx_test_pattern : in STD_LOGIC;
    ctl_rx_ctl_rx_test_pattern_enable : in STD_LOGIC;
    ctl_tx_ctl_tx_data_pattern_select : in STD_LOGIC;
    ctl_tx_ctl_tx_enable : in STD_LOGIC;
    ctl_tx_ctl_tx_fcs_ins_enable : in STD_LOGIC;
    ctl_tx_ctl_tx_ignore_fcs : in STD_LOGIC;
    ctl_tx_ctl_tx_send_idle : in STD_LOGIC;
    ctl_tx_ctl_tx_send_lfi : in STD_LOGIC;
    ctl_tx_ctl_tx_send_rfi : in STD_LOGIC;
    ctl_tx_ctl_tx_test_pattern : in STD_LOGIC;
    ctl_tx_ctl_tx_test_pattern_enable : in STD_LOGIC;
    ctl_tx_ctl_tx_test_pattern_seed_a : in STD_LOGIC_VECTOR ( 57 downto 0 );
    ctl_tx_ctl_tx_test_pattern_seed_b : in STD_LOGIC_VECTOR ( 57 downto 0 );
    ctl_tx_ctl_tx_test_pattern_select : in STD_LOGIC;
    diff_clock_in_clk_n : in STD_LOGIC;
    diff_clock_in_clk_p : in STD_LOGIC;
    gt_loopback_in_0_0 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    gt_refclk_out : out STD_LOGIC;
    gt_rx_gt_port_0_n : in STD_LOGIC;
    gt_rx_gt_port_0_p : in STD_LOGIC;
    gt_tx_0_gt_port_0_n : out STD_LOGIC;
    gt_tx_0_gt_port_0_p : out STD_LOGIC;
    outclksel : in STD_LOGIC_VECTOR ( 2 downto 0 );
    reset_rtl_0 : in STD_LOGIC;
    tx_clk_out : out STD_LOGIC
  );
end eth_10G_wrapper;

architecture STRUCTURE of eth_10G_wrapper is
  component eth_10G is
  port (
    diff_clock_in_clk_n : in STD_LOGIC;
    diff_clock_in_clk_p : in STD_LOGIC;
    gt_rx_gt_port_0_n : in STD_LOGIC;
    gt_rx_gt_port_0_p : in STD_LOGIC;
    gt_tx_0_gt_port_0_n : out STD_LOGIC;
    gt_tx_0_gt_port_0_p : out STD_LOGIC;
    axis_tx_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    axis_tx_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
    axis_tx_tlast : in STD_LOGIC;
    axis_tx_tready : out STD_LOGIC;
    axis_tx_tuser : in STD_LOGIC;
    axis_tx_tvalid : in STD_LOGIC;
    axis_rx_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    axis_rx_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
    axis_rx_tlast : out STD_LOGIC;
    axis_rx_tuser : out STD_LOGIC;
    axis_rx_tvalid : out STD_LOGIC;
    clk_100MHz : in STD_LOGIC;
    reset_rtl_0 : in STD_LOGIC;
    outclksel : in STD_LOGIC_VECTOR ( 2 downto 0 );
    gt_loopback_in_0_0 : in STD_LOGIC_VECTOR ( 2 downto 0 );
    tx_clk_out : out STD_LOGIC;
    gt_refclk_out : out STD_LOGIC;
    ctl_tx_ctl_tx_data_pattern_select : in STD_LOGIC;
    ctl_tx_ctl_tx_enable : in STD_LOGIC;
    ctl_tx_ctl_tx_fcs_ins_enable : in STD_LOGIC;
    ctl_tx_ctl_tx_ignore_fcs : in STD_LOGIC;
    ctl_tx_ctl_tx_send_idle : in STD_LOGIC;
    ctl_tx_ctl_tx_send_lfi : in STD_LOGIC;
    ctl_tx_ctl_tx_send_rfi : in STD_LOGIC;
    ctl_tx_ctl_tx_test_pattern : in STD_LOGIC;
    ctl_tx_ctl_tx_test_pattern_enable : in STD_LOGIC;
    ctl_tx_ctl_tx_test_pattern_seed_a : in STD_LOGIC_VECTOR ( 57 downto 0 );
    ctl_tx_ctl_tx_test_pattern_seed_b : in STD_LOGIC_VECTOR ( 57 downto 0 );
    ctl_tx_ctl_tx_test_pattern_select : in STD_LOGIC;
    ctl_rx_ctl_rx_check_preamble : in STD_LOGIC;
    ctl_rx_ctl_rx_check_sfd : in STD_LOGIC;
    ctl_rx_ctl_rx_data_pattern_select : in STD_LOGIC;
    ctl_rx_ctl_rx_delete_fcs : in STD_LOGIC;
    ctl_rx_ctl_rx_enable : in STD_LOGIC;
    ctl_rx_ctl_rx_force_resync : in STD_LOGIC;
    ctl_rx_ctl_rx_ignore_fcs : in STD_LOGIC;
    ctl_rx_ctl_rx_max_packet_len : in STD_LOGIC_VECTOR ( 14 downto 0 );
    ctl_rx_ctl_rx_min_packet_len : in STD_LOGIC_VECTOR ( 7 downto 0 );
    ctl_rx_ctl_rx_process_lfi : in STD_LOGIC;
    ctl_rx_ctl_rx_test_pattern : in STD_LOGIC;
    ctl_rx_ctl_rx_test_pattern_enable : in STD_LOGIC
  );
  end component eth_10G;
begin
eth_10G_i: component eth_10G
     port map (
      axis_rx_tdata(63 downto 0) => axis_rx_tdata(63 downto 0),
      axis_rx_tkeep(7 downto 0) => axis_rx_tkeep(7 downto 0),
      axis_rx_tlast => axis_rx_tlast,
      axis_rx_tuser => axis_rx_tuser,
      axis_rx_tvalid => axis_rx_tvalid,
      axis_tx_tdata(63 downto 0) => axis_tx_tdata(63 downto 0),
      axis_tx_tkeep(7 downto 0) => axis_tx_tkeep(7 downto 0),
      axis_tx_tlast => axis_tx_tlast,
      axis_tx_tready => axis_tx_tready,
      axis_tx_tuser => axis_tx_tuser,
      axis_tx_tvalid => axis_tx_tvalid,
      clk_100MHz => clk_100MHz,
      ctl_rx_ctl_rx_check_preamble => ctl_rx_ctl_rx_check_preamble,
      ctl_rx_ctl_rx_check_sfd => ctl_rx_ctl_rx_check_sfd,
      ctl_rx_ctl_rx_data_pattern_select => ctl_rx_ctl_rx_data_pattern_select,
      ctl_rx_ctl_rx_delete_fcs => ctl_rx_ctl_rx_delete_fcs,
      ctl_rx_ctl_rx_enable => ctl_rx_ctl_rx_enable,
      ctl_rx_ctl_rx_force_resync => ctl_rx_ctl_rx_force_resync,
      ctl_rx_ctl_rx_ignore_fcs => ctl_rx_ctl_rx_ignore_fcs,
      ctl_rx_ctl_rx_max_packet_len(14 downto 0) => ctl_rx_ctl_rx_max_packet_len(14 downto 0),
      ctl_rx_ctl_rx_min_packet_len(7 downto 0) => ctl_rx_ctl_rx_min_packet_len(7 downto 0),
      ctl_rx_ctl_rx_process_lfi => ctl_rx_ctl_rx_process_lfi,
      ctl_rx_ctl_rx_test_pattern => ctl_rx_ctl_rx_test_pattern,
      ctl_rx_ctl_rx_test_pattern_enable => ctl_rx_ctl_rx_test_pattern_enable,
      ctl_tx_ctl_tx_data_pattern_select => ctl_tx_ctl_tx_data_pattern_select,
      ctl_tx_ctl_tx_enable => ctl_tx_ctl_tx_enable,
      ctl_tx_ctl_tx_fcs_ins_enable => ctl_tx_ctl_tx_fcs_ins_enable,
      ctl_tx_ctl_tx_ignore_fcs => ctl_tx_ctl_tx_ignore_fcs,
      ctl_tx_ctl_tx_send_idle => ctl_tx_ctl_tx_send_idle,
      ctl_tx_ctl_tx_send_lfi => ctl_tx_ctl_tx_send_lfi,
      ctl_tx_ctl_tx_send_rfi => ctl_tx_ctl_tx_send_rfi,
      ctl_tx_ctl_tx_test_pattern => ctl_tx_ctl_tx_test_pattern,
      ctl_tx_ctl_tx_test_pattern_enable => ctl_tx_ctl_tx_test_pattern_enable,
      ctl_tx_ctl_tx_test_pattern_seed_a(57 downto 0) => ctl_tx_ctl_tx_test_pattern_seed_a(57 downto 0),
      ctl_tx_ctl_tx_test_pattern_seed_b(57 downto 0) => ctl_tx_ctl_tx_test_pattern_seed_b(57 downto 0),
      ctl_tx_ctl_tx_test_pattern_select => ctl_tx_ctl_tx_test_pattern_select,
      diff_clock_in_clk_n => diff_clock_in_clk_n,
      diff_clock_in_clk_p => diff_clock_in_clk_p,
      gt_loopback_in_0_0(2 downto 0) => gt_loopback_in_0_0(2 downto 0),
      gt_refclk_out => gt_refclk_out,
      gt_rx_gt_port_0_n => gt_rx_gt_port_0_n,
      gt_rx_gt_port_0_p => gt_rx_gt_port_0_p,
      gt_tx_0_gt_port_0_n => gt_tx_0_gt_port_0_n,
      gt_tx_0_gt_port_0_p => gt_tx_0_gt_port_0_p,
      outclksel(2 downto 0) => outclksel(2 downto 0),
      reset_rtl_0 => reset_rtl_0,
      tx_clk_out => tx_clk_out
    );
end STRUCTURE;
