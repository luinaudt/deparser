
################################################################
# This is a generated script based on design: eth_10G
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source eth_10G_script.tcl

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xxv_ethernet:3.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set axis_rx [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 axis_rx ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {390625000} \
   CONFIG.PHASE {0} \
   ] $axis_rx

  set axis_tx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 axis_tx ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {390625000} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {1} \
   ] $axis_tx

  set ctl_rx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_xxv_ethernet:ctrl_ports:2.0 ctl_rx ]

  set ctl_tx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_xxv_ethernet:ctrl_ports:2.0 ctl_tx ]

  set diff_clock_in [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 diff_clock_in ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {161132812} \
   ] $diff_clock_in

  set gt_rx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_xxv_ethernet:gt_ports:2.0 gt_rx ]

  set gt_tx_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_xxv_ethernet:gt_ports:2.0 gt_tx_0 ]


  # Create ports
  set clk_100MHz [ create_bd_port -dir I -type clk clk_100MHz ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
 ] $clk_100MHz
  set gt_loopback_in_0_0 [ create_bd_port -dir I -from 2 -to 0 gt_loopback_in_0_0 ]
  set gt_refclk_out [ create_bd_port -dir O -type clk gt_refclk_out ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {161132812} \
 ] $gt_refclk_out
  set outclksel [ create_bd_port -dir I -from 2 -to 0 outclksel ]
  set reset_rtl_0 [ create_bd_port -dir I -type rst reset_rtl_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset_rtl_0
  set tx_clk_out [ create_bd_port -dir O -type clk tx_clk_out ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {390625000} \
 ] $tx_clk_out

  # Create instance: clk_wiz, and set properties
  set clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz ]

  # Create instance: rst_clk_wiz_100M, and set properties
  set rst_clk_wiz_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_clk_wiz_100M ]

  # Create instance: xxv_ethernet_0, and set properties
  set xxv_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xxv_ethernet:3.0 xxv_ethernet_0 ]
  set_property -dict [ list \
   CONFIG.ADD_GT_CNTRL_STS_PORTS {0} \
   CONFIG.BASE_R_KR {BASE-R} \
   CONFIG.CORE {Ethernet MAC+PCS/PMA 64-bit} \
   CONFIG.DATA_PATH_INTERFACE {AXI Stream} \
   CONFIG.ENABLE_DATAPATH_PARITY {0} \
   CONFIG.ENABLE_PIPELINE_REG {1} \
   CONFIG.ENABLE_PREEMPTION {0} \
   CONFIG.ENABLE_TIME_STAMPING {0} \
   CONFIG.GT_LOCATION {1} \
   CONFIG.GT_REF_CLK_FREQ {161.1328125} \
   CONFIG.INCLUDE_AUTO_NEG_LT_LOGIC {None} \
   CONFIG.INCLUDE_AXI4_INTERFACE {0} \
   CONFIG.INCLUDE_SHARED_LOGIC {1} \
   CONFIG.INCLUDE_STATISTICS_COUNTERS {0} \
   CONFIG.INCLUDE_USER_FIFO {0} \
   CONFIG.LANE2_GT_LOC {NA} \
   CONFIG.LANE3_GT_LOC {NA} \
   CONFIG.LANE4_GT_LOC {NA} \
   CONFIG.LINE_RATE {25} \
   CONFIG.NUM_OF_CORES {1} \
   CONFIG.PTP_OPERATION_MODE {2} \
   CONFIG.RX_EQ_MODE {AUTO} \
 ] $xxv_ethernet_0

  # Create interface connections
  connect_bd_intf_net -intf_net axis_tx_0_0_1 [get_bd_intf_ports axis_tx] [get_bd_intf_pins xxv_ethernet_0/axis_tx_0]
  connect_bd_intf_net -intf_net ctl_rx_0_0_1 [get_bd_intf_ports ctl_rx] [get_bd_intf_pins xxv_ethernet_0/ctl_rx_0]
  connect_bd_intf_net -intf_net ctl_tx_0_0_1 [get_bd_intf_ports ctl_tx] [get_bd_intf_pins xxv_ethernet_0/ctl_tx_0]
  connect_bd_intf_net -intf_net diff_clock_rtl_0_1 [get_bd_intf_ports diff_clock_in] [get_bd_intf_pins xxv_ethernet_0/gt_ref_clk]
  connect_bd_intf_net -intf_net gt_rx_0_1 [get_bd_intf_ports gt_rx] [get_bd_intf_pins xxv_ethernet_0/gt_rx]
  connect_bd_intf_net -intf_net xxv_ethernet_0_axis_rx_0 [get_bd_intf_ports axis_rx] [get_bd_intf_pins xxv_ethernet_0/axis_rx_0]
  connect_bd_intf_net -intf_net xxv_ethernet_0_gt_tx [get_bd_intf_ports gt_tx_0] [get_bd_intf_pins xxv_ethernet_0/gt_tx]

  # Create port connections
  connect_bd_net -net clk_100MHz_1 [get_bd_ports clk_100MHz] [get_bd_pins clk_wiz/clk_in1]
  connect_bd_net -net clk_wiz_clk_out1 [get_bd_pins clk_wiz/clk_out1] [get_bd_pins rst_clk_wiz_100M/slowest_sync_clk] [get_bd_pins xxv_ethernet_0/dclk]
  connect_bd_net -net clk_wiz_locked [get_bd_pins clk_wiz/locked] [get_bd_pins rst_clk_wiz_100M/dcm_locked]
  connect_bd_net -net gt_loopback_in_0_0_1 [get_bd_ports gt_loopback_in_0_0] [get_bd_pins xxv_ethernet_0/gt_loopback_in_0]
  connect_bd_net -net reset_rtl_0_1 [get_bd_ports reset_rtl_0] [get_bd_pins rst_clk_wiz_100M/ext_reset_in]
  connect_bd_net -net rst_clk_wiz_100M_peripheral_reset [get_bd_pins rst_clk_wiz_100M/peripheral_reset] [get_bd_pins xxv_ethernet_0/sys_reset]
  connect_bd_net -net txoutclksel_in_0_0_1 [get_bd_ports outclksel] [get_bd_pins xxv_ethernet_0/rxoutclksel_in_0] [get_bd_pins xxv_ethernet_0/txoutclksel_in_0]
  connect_bd_net -net xxv_ethernet_0_gt_refclk_out [get_bd_ports gt_refclk_out] [get_bd_pins xxv_ethernet_0/gt_refclk_out]
  connect_bd_net -net xxv_ethernet_0_rx_clk_out_0 [get_bd_pins xxv_ethernet_0/rx_clk_out_0] [get_bd_pins xxv_ethernet_0/rx_core_clk_0]
  connect_bd_net -net xxv_ethernet_0_tx_clk_out_0 [get_bd_ports tx_clk_out] [get_bd_pins xxv_ethernet_0/tx_clk_out_0]
  connect_bd_net -net xxv_ethernet_0_user_rx_reset_0 [get_bd_pins clk_wiz/reset] [get_bd_pins xxv_ethernet_0/rx_reset_0] [get_bd_pins xxv_ethernet_0/tx_reset_0] [get_bd_pins xxv_ethernet_0/user_rx_reset_0]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

}
# End of create_root_design()




proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_root_design"
   puts "#"
   puts "#"
   puts "# The following procedures will create hiearchical blocks with addressing "
   puts "# for IPs within those blocks and their sub-hierarchical blocks. Addressing "
   puts "# will not be handled outside those blocks:"
   puts "#"
   puts "#    create_root_design"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs
