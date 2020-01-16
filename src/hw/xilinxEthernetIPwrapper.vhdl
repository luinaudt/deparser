-------------------------------------------------------------------------------
-- Basic wrapper for ethernet interface. Must be used as example to help design
-------------------------------------------------------------------------------
--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Thu Jan 16 14:42:29 2020
--Host        : pcpl01 running 64-bit Scientific Linux release 7.7 (Nitrogen)
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
  port (
    -- AXI rx signals (as master interface) : out of IP
    axis_rx_0_0_tdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    axis_rx_0_0_tkeep : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axis_rx_0_0_tlast : out STD_LOGIC;
    axis_rx_0_0_tuser : out STD_LOGIC_VECTOR ( 0 to 0 );
    axis_rx_0_0_tvalid : out STD_LOGIC;
    -- AXI tx signals (as slave interface) : in the IP
    axis_tx_0_0_tdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    axis_tx_0_0_tkeep : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axis_tx_0_0_tlast : in STD_LOGIC;
    axis_tx_0_0_tready : out STD_LOGIC;
    axis_tx_0_0_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axis_tx_0_0_tvalid : in STD_LOGIC;

    -- other signals
    ctl_tx_0_0_ctl_tx_send_idle : in STD_LOGIC;
    ctl_tx_0_0_ctl_tx_send_lfi : in STD_LOGIC;
    ctl_tx_0_0_ctl_tx_send_rfi : in STD_LOGIC;
    dclk_0 : in STD_LOGIC;
    gt_ref_clk_0_clk_n : in STD_LOGIC;
    gt_ref_clk_0_clk_p : in STD_LOGIC;
    gt_refclk_out_0 : out STD_LOGIC;
    gt_serial_port_0_grx_n : in STD_LOGIC_VECTOR ( 3 downto 0 );
    gt_serial_port_0_grx_p : in STD_LOGIC_VECTOR ( 3 downto 0 );
    gt_serial_port_0_gtx_n : out STD_LOGIC_VECTOR ( 3 downto 0 );
    gt_serial_port_0_gtx_p : out STD_LOGIC_VECTOR ( 3 downto 0 );
    gtpowergood_out_0_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    gtwiz_reset_rx_datapath_0_0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_tx_datapath_0_0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    pm_tick_0_0 : in STD_LOGIC;
    rx_clk_out_0_0 : out STD_LOGIC;
    rx_core_clk_0_0 : in STD_LOGIC;
    rx_preambleout_0_0 : out STD_LOGIC_VECTOR ( 55 downto 0 );
    rx_reset_0_0 : in STD_LOGIC;
    rxoutclksel_in_0_0 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    rxrecclkout_0_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_0_0_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_0_0_arready : out STD_LOGIC;
    s_axi_0_0_arvalid : in STD_LOGIC;
    s_axi_0_0_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_0_0_awready : out STD_LOGIC;
    s_axi_0_0_awvalid : in STD_LOGIC;
    s_axi_0_0_bready : in STD_LOGIC;
    s_axi_0_0_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_0_0_bvalid : out STD_LOGIC;
    s_axi_0_0_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_0_0_rready : in STD_LOGIC;
    s_axi_0_0_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_0_0_rvalid : out STD_LOGIC;
    s_axi_0_0_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_0_0_wready : out STD_LOGIC;
    s_axi_0_0_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_0_0_wvalid : in STD_LOGIC;
    s_axi_aclk_0_0 : in STD_LOGIC;
    s_axi_aresetn_0_0 : in STD_LOGIC;
    -- statitic informations
    stat_rx_0_0_stat_rx_aligned : out STD_LOGIC;
    stat_rx_0_0_stat_rx_aligned_err : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bad_code : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_bad_fcs : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_bad_preamble : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bad_sfd : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bip_err_0 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bip_err_1 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bip_err_2 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bip_err_3 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_block_lock : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_fragment : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_framing_err_0 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_1 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_2 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_3 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_valid_0 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_valid_1 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_valid_2 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_valid_3 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_got_signal_os : out STD_LOGIC;
    stat_rx_0_0_stat_rx_hi_ber : out STD_LOGIC;
    stat_rx_0_0_stat_rx_internal_local_fault : out STD_LOGIC;
    stat_rx_0_0_stat_rx_jabber : out STD_LOGIC;
    stat_rx_0_0_stat_rx_local_fault : out STD_LOGIC;
    stat_rx_0_0_stat_rx_mf_err : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_mf_len_err : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_mf_repeat_err : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_misaligned : out STD_LOGIC;
    stat_rx_0_0_stat_rx_oversize : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_1024_1518_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_128_255_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_1519_1522_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_1523_1548_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_1549_2047_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_2048_4095_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_256_511_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_4096_8191_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_512_1023_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_64_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_65_127_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_8192_9215_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_bad_fcs : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_large : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_small : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_received_local_fault : out STD_LOGIC;
    stat_rx_0_0_stat_rx_remote_fault : out STD_LOGIC;
    stat_rx_0_0_stat_rx_status : out STD_LOGIC;
    stat_rx_0_0_stat_rx_stomped_fcs : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_synced : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_synced_err : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_test_pattern_mismatch : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_toolong : out STD_LOGIC;
    stat_rx_0_0_stat_rx_total_bytes : out STD_LOGIC_VECTOR ( 5 downto 0 );
    stat_rx_0_0_stat_rx_total_good_bytes : out STD_LOGIC_VECTOR ( 13 downto 0 );
    stat_rx_0_0_stat_rx_total_good_packets : out STD_LOGIC;
    stat_rx_0_0_stat_rx_total_packets : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_truncated : out STD_LOGIC;
    stat_rx_0_0_stat_rx_undersize : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_vl_demuxed : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_vl_number_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_vl_number_1 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_vl_number_2 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_vl_number_3 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_tx_0_0_stat_tx_bad_fcs : out STD_LOGIC;
    stat_tx_0_0_stat_tx_frame_error : out STD_LOGIC;
    stat_tx_0_0_stat_tx_local_fault : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_1024_1518_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_128_255_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_1519_1522_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_1523_1548_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_1549_2047_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_2048_4095_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_256_511_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_4096_8191_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_512_1023_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_64_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_65_127_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_8192_9215_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_large : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_small : out STD_LOGIC;
    stat_tx_0_0_stat_tx_total_bytes : out STD_LOGIC_VECTOR ( 4 downto 0 );
    stat_tx_0_0_stat_tx_total_good_bytes : out STD_LOGIC_VECTOR ( 13 downto 0 );
    stat_tx_0_0_stat_tx_total_good_packets : out STD_LOGIC;
    stat_tx_0_0_stat_tx_total_packets : out STD_LOGIC;
    stat_tx_overflow_err_0_0 : out STD_LOGIC;
    stat_tx_underflow_err_0_0 : out STD_LOGIC;
    -- signals specific to design (clk generated for transceiver, reset etc..)
    sys_reset_0 : in STD_LOGIC;
    tx_clk_out_0_0 : out STD_LOGIC;
    tx_preamblein_0_0 : in STD_LOGIC_VECTOR ( 55 downto 0 );
    tx_reset_0_0 : in STD_LOGIC;
    tx_unfout_0_0 : out STD_LOGIC;
    txoutclksel_in_0_0 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    user_reg0_0_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    user_rx_reset_0_0 : out STD_LOGIC;
    user_tx_reset_0_0 : out STD_LOGIC
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  port (
    dclk_0 : in STD_LOGIC;
    gt_refclk_out_0 : out STD_LOGIC;
    gtpowergood_out_0_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    gtwiz_reset_rx_datapath_0_0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    gtwiz_reset_tx_datapath_0_0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    pm_tick_0_0 : in STD_LOGIC;
    rx_clk_out_0_0 : out STD_LOGIC;
    rx_core_clk_0_0 : in STD_LOGIC;
    rx_preambleout_0_0 : out STD_LOGIC_VECTOR ( 55 downto 0 );
    rx_reset_0_0 : in STD_LOGIC;
    rxoutclksel_in_0_0 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    rxrecclkout_0_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_aclk_0_0 : in STD_LOGIC;
    s_axi_aresetn_0_0 : in STD_LOGIC;
    stat_tx_overflow_err_0_0 : out STD_LOGIC;
    stat_tx_underflow_err_0_0 : out STD_LOGIC;
    sys_reset_0 : in STD_LOGIC;
    tx_clk_out_0_0 : out STD_LOGIC;
    tx_preamblein_0_0 : in STD_LOGIC_VECTOR ( 55 downto 0 );
    tx_reset_0_0 : in STD_LOGIC;
    tx_unfout_0_0 : out STD_LOGIC;
    txoutclksel_in_0_0 : in STD_LOGIC_VECTOR ( 11 downto 0 );
    user_reg0_0_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    user_rx_reset_0_0 : out STD_LOGIC;
    user_tx_reset_0_0 : out STD_LOGIC;
    axis_rx_0_0_tdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    axis_rx_0_0_tkeep : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axis_rx_0_0_tlast : out STD_LOGIC;
    axis_rx_0_0_tuser : out STD_LOGIC_VECTOR ( 0 to 0 );
    axis_rx_0_0_tvalid : out STD_LOGIC;
    axis_tx_0_0_tdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    axis_tx_0_0_tkeep : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axis_tx_0_0_tlast : in STD_LOGIC;
    axis_tx_0_0_tready : out STD_LOGIC;
    axis_tx_0_0_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    axis_tx_0_0_tvalid : in STD_LOGIC;
    ctl_tx_0_0_ctl_tx_send_idle : in STD_LOGIC;
    ctl_tx_0_0_ctl_tx_send_lfi : in STD_LOGIC;
    ctl_tx_0_0_ctl_tx_send_rfi : in STD_LOGIC;
    gt_ref_clk_0_clk_n : in STD_LOGIC;
    gt_ref_clk_0_clk_p : in STD_LOGIC;
    gt_serial_port_0_grx_n : in STD_LOGIC_VECTOR ( 3 downto 0 );
    gt_serial_port_0_grx_p : in STD_LOGIC_VECTOR ( 3 downto 0 );
    gt_serial_port_0_gtx_n : out STD_LOGIC_VECTOR ( 3 downto 0 );
    gt_serial_port_0_gtx_p : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_0_0_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_0_0_arready : out STD_LOGIC;
    s_axi_0_0_arvalid : in STD_LOGIC;
    s_axi_0_0_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_0_0_awready : out STD_LOGIC;
    s_axi_0_0_awvalid : in STD_LOGIC;
    s_axi_0_0_bready : in STD_LOGIC;
    s_axi_0_0_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_0_0_bvalid : out STD_LOGIC;
    s_axi_0_0_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_0_0_rready : in STD_LOGIC;
    s_axi_0_0_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_0_0_rvalid : out STD_LOGIC;
    s_axi_0_0_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_0_0_wready : out STD_LOGIC;
    s_axi_0_0_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_0_0_wvalid : in STD_LOGIC;
    stat_rx_0_0_stat_rx_aligned : out STD_LOGIC;
    stat_rx_0_0_stat_rx_aligned_err : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bad_code : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_bad_fcs : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_bad_preamble : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bad_sfd : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bip_err_0 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bip_err_1 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bip_err_2 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_bip_err_3 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_block_lock : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_fragment : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_framing_err_0 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_1 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_2 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_3 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_valid_0 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_valid_1 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_valid_2 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_framing_err_valid_3 : out STD_LOGIC;
    stat_rx_0_0_stat_rx_got_signal_os : out STD_LOGIC;
    stat_rx_0_0_stat_rx_hi_ber : out STD_LOGIC;
    stat_rx_0_0_stat_rx_internal_local_fault : out STD_LOGIC;
    stat_rx_0_0_stat_rx_jabber : out STD_LOGIC;
    stat_rx_0_0_stat_rx_local_fault : out STD_LOGIC;
    stat_rx_0_0_stat_rx_mf_err : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_mf_len_err : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_mf_repeat_err : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_misaligned : out STD_LOGIC;
    stat_rx_0_0_stat_rx_oversize : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_64_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_65_127_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_128_255_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_256_511_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_512_1023_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_1024_1518_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_1519_1522_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_1523_1548_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_1549_2047_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_2048_4095_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_4096_8191_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_8192_9215_bytes : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_bad_fcs : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_large : out STD_LOGIC;
    stat_rx_0_0_stat_rx_packet_small : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_received_local_fault : out STD_LOGIC;
    stat_rx_0_0_stat_rx_remote_fault : out STD_LOGIC;
    stat_rx_0_0_stat_rx_status : out STD_LOGIC;
    stat_rx_0_0_stat_rx_stomped_fcs : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_synced : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_synced_err : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_test_pattern_mismatch : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_toolong : out STD_LOGIC;
    stat_rx_0_0_stat_rx_total_bytes : out STD_LOGIC_VECTOR ( 5 downto 0 );
    stat_rx_0_0_stat_rx_total_good_bytes : out STD_LOGIC_VECTOR ( 13 downto 0 );
    stat_rx_0_0_stat_rx_total_good_packets : out STD_LOGIC;
    stat_rx_0_0_stat_rx_total_packets : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_truncated : out STD_LOGIC;
    stat_rx_0_0_stat_rx_undersize : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_vl_demuxed : out STD_LOGIC_VECTOR ( 3 downto 0 );
    stat_rx_0_0_stat_rx_vl_number_0 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_vl_number_1 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_vl_number_2 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_rx_0_0_stat_rx_vl_number_3 : out STD_LOGIC_VECTOR ( 1 downto 0 );
    stat_tx_0_0_stat_tx_bad_fcs : out STD_LOGIC;
    stat_tx_0_0_stat_tx_frame_error : out STD_LOGIC;
    stat_tx_0_0_stat_tx_local_fault : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_64_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_65_127_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_128_255_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_256_511_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_512_1023_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_1024_1518_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_1519_1522_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_1523_1548_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_1549_2047_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_2048_4095_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_4096_8191_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_8192_9215_bytes : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_large : out STD_LOGIC;
    stat_tx_0_0_stat_tx_packet_small : out STD_LOGIC;
    stat_tx_0_0_stat_tx_total_bytes : out STD_LOGIC_VECTOR ( 4 downto 0 );
    stat_tx_0_0_stat_tx_total_good_bytes : out STD_LOGIC_VECTOR ( 13 downto 0 );
    stat_tx_0_0_stat_tx_total_good_packets : out STD_LOGIC;
    stat_tx_0_0_stat_tx_total_packets : out STD_LOGIC
  );
  end component design_1;
begin
design_1_i: component design_1
     port map (
      axis_rx_0_0_tdata(255 downto 0) => axis_rx_0_0_tdata(255 downto 0),
      axis_rx_0_0_tkeep(31 downto 0) => axis_rx_0_0_tkeep(31 downto 0),
      axis_rx_0_0_tlast => axis_rx_0_0_tlast,
      axis_rx_0_0_tuser(0) => axis_rx_0_0_tuser(0),
      axis_rx_0_0_tvalid => axis_rx_0_0_tvalid,
      axis_tx_0_0_tdata(255 downto 0) => axis_tx_0_0_tdata(255 downto 0),
      axis_tx_0_0_tkeep(31 downto 0) => axis_tx_0_0_tkeep(31 downto 0),
      axis_tx_0_0_tlast => axis_tx_0_0_tlast,
      axis_tx_0_0_tready => axis_tx_0_0_tready,
      axis_tx_0_0_tuser(0) => axis_tx_0_0_tuser(0),
      axis_tx_0_0_tvalid => axis_tx_0_0_tvalid,
      ctl_tx_0_0_ctl_tx_send_idle => ctl_tx_0_0_ctl_tx_send_idle,
      ctl_tx_0_0_ctl_tx_send_lfi => ctl_tx_0_0_ctl_tx_send_lfi,
      ctl_tx_0_0_ctl_tx_send_rfi => ctl_tx_0_0_ctl_tx_send_rfi,
      dclk_0 => dclk_0,
      gt_ref_clk_0_clk_n => gt_ref_clk_0_clk_n,
      gt_ref_clk_0_clk_p => gt_ref_clk_0_clk_p,
      gt_refclk_out_0 => gt_refclk_out_0,
      gt_serial_port_0_grx_n(3 downto 0) => gt_serial_port_0_grx_n(3 downto 0),
      gt_serial_port_0_grx_p(3 downto 0) => gt_serial_port_0_grx_p(3 downto 0),
      gt_serial_port_0_gtx_n(3 downto 0) => gt_serial_port_0_gtx_n(3 downto 0),
      gt_serial_port_0_gtx_p(3 downto 0) => gt_serial_port_0_gtx_p(3 downto 0),
      gtpowergood_out_0_0(3 downto 0) => gtpowergood_out_0_0(3 downto 0),
      gtwiz_reset_rx_datapath_0_0(0) => gtwiz_reset_rx_datapath_0_0(0),
      gtwiz_reset_tx_datapath_0_0(0) => gtwiz_reset_tx_datapath_0_0(0),
      pm_tick_0_0 => pm_tick_0_0,
      rx_clk_out_0_0 => rx_clk_out_0_0,
      rx_core_clk_0_0 => rx_core_clk_0_0,
      rx_preambleout_0_0(55 downto 0) => rx_preambleout_0_0(55 downto 0),
      rx_reset_0_0 => rx_reset_0_0,
      rxoutclksel_in_0_0(11 downto 0) => rxoutclksel_in_0_0(11 downto 0),
      rxrecclkout_0_0(3 downto 0) => rxrecclkout_0_0(3 downto 0),
      s_axi_0_0_araddr(31 downto 0) => s_axi_0_0_araddr(31 downto 0),
      s_axi_0_0_arready => s_axi_0_0_arready,
      s_axi_0_0_arvalid => s_axi_0_0_arvalid,
      s_axi_0_0_awaddr(31 downto 0) => s_axi_0_0_awaddr(31 downto 0),
      s_axi_0_0_awready => s_axi_0_0_awready,
      s_axi_0_0_awvalid => s_axi_0_0_awvalid,
      s_axi_0_0_bready => s_axi_0_0_bready,
      s_axi_0_0_bresp(1 downto 0) => s_axi_0_0_bresp(1 downto 0),
      s_axi_0_0_bvalid => s_axi_0_0_bvalid,
      s_axi_0_0_rdata(31 downto 0) => s_axi_0_0_rdata(31 downto 0),
      s_axi_0_0_rready => s_axi_0_0_rready,
      s_axi_0_0_rresp(1 downto 0) => s_axi_0_0_rresp(1 downto 0),
      s_axi_0_0_rvalid => s_axi_0_0_rvalid,
      s_axi_0_0_wdata(31 downto 0) => s_axi_0_0_wdata(31 downto 0),
      s_axi_0_0_wready => s_axi_0_0_wready,
      s_axi_0_0_wstrb(3 downto 0) => s_axi_0_0_wstrb(3 downto 0),
      s_axi_0_0_wvalid => s_axi_0_0_wvalid,
      s_axi_aclk_0_0 => s_axi_aclk_0_0,
      s_axi_aresetn_0_0 => s_axi_aresetn_0_0,
      stat_rx_0_0_stat_rx_aligned => stat_rx_0_0_stat_rx_aligned,
      stat_rx_0_0_stat_rx_aligned_err => stat_rx_0_0_stat_rx_aligned_err,
      stat_rx_0_0_stat_rx_bad_code(1 downto 0) => stat_rx_0_0_stat_rx_bad_code(1 downto 0),
      stat_rx_0_0_stat_rx_bad_fcs(1 downto 0) => stat_rx_0_0_stat_rx_bad_fcs(1 downto 0),
      stat_rx_0_0_stat_rx_bad_preamble => stat_rx_0_0_stat_rx_bad_preamble,
      stat_rx_0_0_stat_rx_bad_sfd => stat_rx_0_0_stat_rx_bad_sfd,
      stat_rx_0_0_stat_rx_bip_err_0 => stat_rx_0_0_stat_rx_bip_err_0,
      stat_rx_0_0_stat_rx_bip_err_1 => stat_rx_0_0_stat_rx_bip_err_1,
      stat_rx_0_0_stat_rx_bip_err_2 => stat_rx_0_0_stat_rx_bip_err_2,
      stat_rx_0_0_stat_rx_bip_err_3 => stat_rx_0_0_stat_rx_bip_err_3,
      stat_rx_0_0_stat_rx_block_lock(3 downto 0) => stat_rx_0_0_stat_rx_block_lock(3 downto 0),
      stat_rx_0_0_stat_rx_fragment(1 downto 0) => stat_rx_0_0_stat_rx_fragment(1 downto 0),
      stat_rx_0_0_stat_rx_framing_err_0 => stat_rx_0_0_stat_rx_framing_err_0,
      stat_rx_0_0_stat_rx_framing_err_1 => stat_rx_0_0_stat_rx_framing_err_1,
      stat_rx_0_0_stat_rx_framing_err_2 => stat_rx_0_0_stat_rx_framing_err_2,
      stat_rx_0_0_stat_rx_framing_err_3 => stat_rx_0_0_stat_rx_framing_err_3,
      stat_rx_0_0_stat_rx_framing_err_valid_0 => stat_rx_0_0_stat_rx_framing_err_valid_0,
      stat_rx_0_0_stat_rx_framing_err_valid_1 => stat_rx_0_0_stat_rx_framing_err_valid_1,
      stat_rx_0_0_stat_rx_framing_err_valid_2 => stat_rx_0_0_stat_rx_framing_err_valid_2,
      stat_rx_0_0_stat_rx_framing_err_valid_3 => stat_rx_0_0_stat_rx_framing_err_valid_3,
      stat_rx_0_0_stat_rx_got_signal_os => stat_rx_0_0_stat_rx_got_signal_os,
      stat_rx_0_0_stat_rx_hi_ber => stat_rx_0_0_stat_rx_hi_ber,
      stat_rx_0_0_stat_rx_internal_local_fault => stat_rx_0_0_stat_rx_internal_local_fault,
      stat_rx_0_0_stat_rx_jabber => stat_rx_0_0_stat_rx_jabber,
      stat_rx_0_0_stat_rx_local_fault => stat_rx_0_0_stat_rx_local_fault,
      stat_rx_0_0_stat_rx_mf_err(3 downto 0) => stat_rx_0_0_stat_rx_mf_err(3 downto 0),
      stat_rx_0_0_stat_rx_mf_len_err(3 downto 0) => stat_rx_0_0_stat_rx_mf_len_err(3 downto 0),
      stat_rx_0_0_stat_rx_mf_repeat_err(3 downto 0) => stat_rx_0_0_stat_rx_mf_repeat_err(3 downto 0),
      stat_rx_0_0_stat_rx_misaligned => stat_rx_0_0_stat_rx_misaligned,
      stat_rx_0_0_stat_rx_oversize => stat_rx_0_0_stat_rx_oversize,
      stat_rx_0_0_stat_rx_packet_1024_1518_bytes => stat_rx_0_0_stat_rx_packet_1024_1518_bytes,
      stat_rx_0_0_stat_rx_packet_128_255_bytes => stat_rx_0_0_stat_rx_packet_128_255_bytes,
      stat_rx_0_0_stat_rx_packet_1519_1522_bytes => stat_rx_0_0_stat_rx_packet_1519_1522_bytes,
      stat_rx_0_0_stat_rx_packet_1523_1548_bytes => stat_rx_0_0_stat_rx_packet_1523_1548_bytes,
      stat_rx_0_0_stat_rx_packet_1549_2047_bytes => stat_rx_0_0_stat_rx_packet_1549_2047_bytes,
      stat_rx_0_0_stat_rx_packet_2048_4095_bytes => stat_rx_0_0_stat_rx_packet_2048_4095_bytes,
      stat_rx_0_0_stat_rx_packet_256_511_bytes => stat_rx_0_0_stat_rx_packet_256_511_bytes,
      stat_rx_0_0_stat_rx_packet_4096_8191_bytes => stat_rx_0_0_stat_rx_packet_4096_8191_bytes,
      stat_rx_0_0_stat_rx_packet_512_1023_bytes => stat_rx_0_0_stat_rx_packet_512_1023_bytes,
      stat_rx_0_0_stat_rx_packet_64_bytes => stat_rx_0_0_stat_rx_packet_64_bytes,
      stat_rx_0_0_stat_rx_packet_65_127_bytes => stat_rx_0_0_stat_rx_packet_65_127_bytes,
      stat_rx_0_0_stat_rx_packet_8192_9215_bytes => stat_rx_0_0_stat_rx_packet_8192_9215_bytes,
      stat_rx_0_0_stat_rx_packet_bad_fcs => stat_rx_0_0_stat_rx_packet_bad_fcs,
      stat_rx_0_0_stat_rx_packet_large => stat_rx_0_0_stat_rx_packet_large,
      stat_rx_0_0_stat_rx_packet_small(1 downto 0) => stat_rx_0_0_stat_rx_packet_small(1 downto 0),
      stat_rx_0_0_stat_rx_received_local_fault => stat_rx_0_0_stat_rx_received_local_fault,
      stat_rx_0_0_stat_rx_remote_fault => stat_rx_0_0_stat_rx_remote_fault,
      stat_rx_0_0_stat_rx_status => stat_rx_0_0_stat_rx_status,
      stat_rx_0_0_stat_rx_stomped_fcs(1 downto 0) => stat_rx_0_0_stat_rx_stomped_fcs(1 downto 0),
      stat_rx_0_0_stat_rx_synced(3 downto 0) => stat_rx_0_0_stat_rx_synced(3 downto 0),
      stat_rx_0_0_stat_rx_synced_err(3 downto 0) => stat_rx_0_0_stat_rx_synced_err(3 downto 0),
      stat_rx_0_0_stat_rx_test_pattern_mismatch(1 downto 0) => stat_rx_0_0_stat_rx_test_pattern_mismatch(1 downto 0),
      stat_rx_0_0_stat_rx_toolong => stat_rx_0_0_stat_rx_toolong,
      stat_rx_0_0_stat_rx_total_bytes(5 downto 0) => stat_rx_0_0_stat_rx_total_bytes(5 downto 0),
      stat_rx_0_0_stat_rx_total_good_bytes(13 downto 0) => stat_rx_0_0_stat_rx_total_good_bytes(13 downto 0),
      stat_rx_0_0_stat_rx_total_good_packets => stat_rx_0_0_stat_rx_total_good_packets,
      stat_rx_0_0_stat_rx_total_packets(1 downto 0) => stat_rx_0_0_stat_rx_total_packets(1 downto 0),
      stat_rx_0_0_stat_rx_truncated => stat_rx_0_0_stat_rx_truncated,
      stat_rx_0_0_stat_rx_undersize(1 downto 0) => stat_rx_0_0_stat_rx_undersize(1 downto 0),
      stat_rx_0_0_stat_rx_vl_demuxed(3 downto 0) => stat_rx_0_0_stat_rx_vl_demuxed(3 downto 0),
      stat_rx_0_0_stat_rx_vl_number_0(1 downto 0) => stat_rx_0_0_stat_rx_vl_number_0(1 downto 0),
      stat_rx_0_0_stat_rx_vl_number_1(1 downto 0) => stat_rx_0_0_stat_rx_vl_number_1(1 downto 0),
      stat_rx_0_0_stat_rx_vl_number_2(1 downto 0) => stat_rx_0_0_stat_rx_vl_number_2(1 downto 0),
      stat_rx_0_0_stat_rx_vl_number_3(1 downto 0) => stat_rx_0_0_stat_rx_vl_number_3(1 downto 0),
      stat_tx_0_0_stat_tx_bad_fcs => stat_tx_0_0_stat_tx_bad_fcs,
      stat_tx_0_0_stat_tx_frame_error => stat_tx_0_0_stat_tx_frame_error,
      stat_tx_0_0_stat_tx_local_fault => stat_tx_0_0_stat_tx_local_fault,
      stat_tx_0_0_stat_tx_packet_1024_1518_bytes => stat_tx_0_0_stat_tx_packet_1024_1518_bytes,
      stat_tx_0_0_stat_tx_packet_128_255_bytes => stat_tx_0_0_stat_tx_packet_128_255_bytes,
      stat_tx_0_0_stat_tx_packet_1519_1522_bytes => stat_tx_0_0_stat_tx_packet_1519_1522_bytes,
      stat_tx_0_0_stat_tx_packet_1523_1548_bytes => stat_tx_0_0_stat_tx_packet_1523_1548_bytes,
      stat_tx_0_0_stat_tx_packet_1549_2047_bytes => stat_tx_0_0_stat_tx_packet_1549_2047_bytes,
      stat_tx_0_0_stat_tx_packet_2048_4095_bytes => stat_tx_0_0_stat_tx_packet_2048_4095_bytes,
      stat_tx_0_0_stat_tx_packet_256_511_bytes => stat_tx_0_0_stat_tx_packet_256_511_bytes,
      stat_tx_0_0_stat_tx_packet_4096_8191_bytes => stat_tx_0_0_stat_tx_packet_4096_8191_bytes,
      stat_tx_0_0_stat_tx_packet_512_1023_bytes => stat_tx_0_0_stat_tx_packet_512_1023_bytes,
      stat_tx_0_0_stat_tx_packet_64_bytes => stat_tx_0_0_stat_tx_packet_64_bytes,
      stat_tx_0_0_stat_tx_packet_65_127_bytes => stat_tx_0_0_stat_tx_packet_65_127_bytes,
      stat_tx_0_0_stat_tx_packet_8192_9215_bytes => stat_tx_0_0_stat_tx_packet_8192_9215_bytes,
      stat_tx_0_0_stat_tx_packet_large => stat_tx_0_0_stat_tx_packet_large,
      stat_tx_0_0_stat_tx_packet_small => stat_tx_0_0_stat_tx_packet_small,
      stat_tx_0_0_stat_tx_total_bytes(4 downto 0) => stat_tx_0_0_stat_tx_total_bytes(4 downto 0),
      stat_tx_0_0_stat_tx_total_good_bytes(13 downto 0) => stat_tx_0_0_stat_tx_total_good_bytes(13 downto 0),
      stat_tx_0_0_stat_tx_total_good_packets => stat_tx_0_0_stat_tx_total_good_packets,
      stat_tx_0_0_stat_tx_total_packets => stat_tx_0_0_stat_tx_total_packets,
      stat_tx_overflow_err_0_0 => stat_tx_overflow_err_0_0,
      stat_tx_underflow_err_0_0 => stat_tx_underflow_err_0_0,
      sys_reset_0 => sys_reset_0,
      tx_clk_out_0_0 => tx_clk_out_0_0,
      tx_preamblein_0_0(55 downto 0) => tx_preamblein_0_0(55 downto 0),
      tx_reset_0_0 => tx_reset_0_0,
      tx_unfout_0_0 => tx_unfout_0_0,
      txoutclksel_in_0_0(11 downto 0) => txoutclksel_in_0_0(11 downto 0),
      user_reg0_0_0(31 downto 0) => user_reg0_0_0(31 downto 0),
      user_rx_reset_0_0 => user_rx_reset_0_0,
      user_tx_reset_0_0 => user_tx_reset_0_0
    );
end STRUCTURE;


