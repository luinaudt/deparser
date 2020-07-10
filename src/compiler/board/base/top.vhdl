library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity top is
  generic (
    streamSize : natural := $outputSize);  --! size of output streaming
  port(
    reset_n     : in  std_logic;
    clk         : in  std_logic;
    clk_100     : in  std_logic;
    gt_refclk_n : in  std_logic;
    gt_refclk_p : in  std_logic;
    gt_rxp_in_0 : in  std_logic;
    gt_rxn_in_0 : in  std_logic;
    gt_txp_in_0 : out std_logic;
    gt_txn_in_0 : out std_logic
    );
end entity;

architecture behavioral of top is
  component eth_10G is
    port (
      diff_clock_in_clk_n               : in  std_logic;
      diff_clock_in_clk_p               : in  std_logic;
      gt_rx_gt_port_0_n                 : in  std_logic;
      gt_rx_gt_port_0_p                 : in  std_logic;
      gt_tx_0_gt_port_0_n               : out std_logic;
      gt_tx_0_gt_port_0_p               : out std_logic;
      axis_tx_tdata                     : in  std_logic_vector (63 downto 0);
      axis_tx_tkeep                     : in  std_logic_vector (7 downto 0);
      axis_tx_tlast                     : in  std_logic;
      axis_tx_tready                    : out std_logic;
      axis_tx_tuser                     : in  std_logic;
      axis_tx_tvalid                    : in  std_logic;
      axis_rx_tdata                     : out std_logic_vector (63 downto 0);
      axis_rx_tkeep                     : out std_logic_vector (7 downto 0);
      axis_rx_tlast                     : out std_logic;
      axis_rx_tuser                     : out std_logic;
      axis_rx_tvalid                    : out std_logic;
      clk_100MHz                        : in  std_logic;
      reset_rtl_0                       : in  std_logic;
      outclksel                         : in  std_logic_vector (2 downto 0);
      gt_loopback_in_0_0                : in  std_logic_vector (2 downto 0);
      tx_clk_out                        : out std_logic;
      gt_refclk_out                     : out std_logic;
      ctl_tx_ctl_tx_data_pattern_select : in  std_logic;
      ctl_tx_ctl_tx_enable              : in  std_logic;
      ctl_tx_ctl_tx_fcs_ins_enable      : in  std_logic;
      ctl_tx_ctl_tx_ignore_fcs          : in  std_logic;
      ctl_tx_ctl_tx_send_idle           : in  std_logic;
      ctl_tx_ctl_tx_send_lfi            : in  std_logic;
      ctl_tx_ctl_tx_send_rfi            : in  std_logic;
      ctl_tx_ctl_tx_test_pattern        : in  std_logic;
      ctl_tx_ctl_tx_test_pattern_enable : in  std_logic;
      ctl_tx_ctl_tx_test_pattern_seed_a : in  std_logic_vector (57 downto 0);
      ctl_tx_ctl_tx_test_pattern_seed_b : in  std_logic_vector (57 downto 0);
      ctl_tx_ctl_tx_test_pattern_select : in  std_logic;
      ctl_rx_ctl_rx_check_preamble      : in  std_logic;
      ctl_rx_ctl_rx_check_sfd           : in  std_logic;
      ctl_rx_ctl_rx_data_pattern_select : in  std_logic;
      ctl_rx_ctl_rx_delete_fcs          : in  std_logic;
      ctl_rx_ctl_rx_enable              : in  std_logic;
      ctl_rx_ctl_rx_force_resync        : in  std_logic;
      ctl_rx_ctl_rx_ignore_fcs          : in  std_logic;
      ctl_rx_ctl_rx_max_packet_len      : in  std_logic_vector (14 downto 0);
      ctl_rx_ctl_rx_min_packet_len      : in  std_logic_vector (7 downto 0);
      ctl_rx_ctl_rx_process_lfi         : in  std_logic;
      ctl_rx_ctl_rx_test_pattern        : in  std_logic;
      ctl_rx_ctl_rx_test_pattern_enable : in  std_logic
      );
  end component eth_10G;
  signal axis_tx_tdata     : std_logic_vector (63 downto 0);
  signal axis_tx_tkeep     : std_logic_vector (7 downto 0);
  signal axis_tx_tlast     : std_logic;
  signal axis_tx_tready    : std_logic;
  signal axis_tx_tuser     : std_logic;
  signal axis_tx_tvalid    : std_logic;
  signal axis_rx_tdata     : std_logic_vector (63 downto 0);
  signal axis_rx_tkeep     : std_logic_vector (7 downto 0);
  signal axis_rx_tlast     : std_logic;
  signal axis_rx_tuser     : std_logic;
  signal axis_rx_tvalid    : std_logic;
  signal gt_ref_out        : std_logic;
  signal axis_clk_0        : std_logic;
  -- signal for dep
  signal payload_in_tready : std_logic;
  signal phvBus            : std_logic_vector($phvBusWidth downto 0)      := (others => '0');
  signal validityBus       : std_logic_vector($phvValidityWidth downto 0) := (others => '0');

  signal deparser_ready : std_logic;
  signal en_deparser    : std_logic;

  signal packet_out_tdata : std_logic_vector(streamSize - 1 downto 0);
  signal packet_out_tkeep : std_logic_vector(streamSize/8 - 1 downto 0);
begin
  process (packet_out_tdata, packet_out_tkeep, axis_rx_tkeep) is
  begin
    if streamSize < 64 then
      axis_tx_tdata <= packet_out_tdata(streamSize - 1 downto 0);
      axis_tx_tkeep <= packet_out_tkeep(streamSize/8 -1 downto 0);
    elsif streamSize > 64 then
      for i in packet_out_tkeep'range loop
        axis_tx_tdata(((i+1)*8 mod 64) - 1 downto i*8 mod 64) <= packet_out_tdata((i+1)*8 - 1 downto i*8);
        axis_tx_tkeep(i mod 8)                       <= packet_out_tkeep(i);
      end loop;
    else
      axis_tx_tdata <= packet_out_tdata;
      axis_tx_tkeep <= packet_out_tkeep;
    end if;
    for i in validityBus'range loop
      validityBus(i) <= axis_rx_tkeep(i mod 8);
    end loop;
  end process;

  dep : entity work.$depName
    generic map(payloadStreamSize => 64,
                outputStreamSize  => streamSize)
    port map (
      clk               => clk,
      reset_n           => reset_n,
      deparser_ready    => deparser_ready,
      en_deparser       => axis_rx_tvalid,
      $phvBusDep        => phvBus,
      $phvValidityDep   => validityBus,
      payload_in_tdata  => axis_rx_tdata,
      payload_in_tvalid => axis_rx_tvalid,
      payload_in_tready => payload_in_tready,
      payload_in_tkeep  => axis_rx_tkeep,
      payload_in_tlast  => axis_rx_tlast,
      packet_out_tdata  => packet_out_tdata,
      packet_out_tvalid => axis_tx_tvalid,
      packet_out_tready => axis_tx_tready,
      packet_out_tkeep  => packet_out_tkeep,
      packet_out_tlast  => axis_tx_tlast
      );

  eth_10G_i : component eth_10G
    port map (
      axis_rx_tdata(63 downto 0)                     => axis_rx_tdata(63 downto 0),
      axis_rx_tkeep(7 downto 0)                      => axis_rx_tkeep(7 downto 0),
      axis_rx_tlast                                  => axis_rx_tlast,
      axis_rx_tuser                                  => axis_rx_tuser,
      axis_rx_tvalid                                 => axis_rx_tvalid,
      axis_tx_tdata(63 downto 0)                     => axis_tx_tdata(63 downto 0),
      axis_tx_tkeep(7 downto 0)                      => axis_tx_tkeep(7 downto 0),
      axis_tx_tlast                                  => axis_tx_tlast,
      axis_tx_tready                                 => axis_tx_tready,
      axis_tx_tuser                                  => axis_tx_tuser,
      axis_tx_tvalid                                 => axis_tx_tvalid,
      clk_100MHz                                     => clk_100,
      ctl_rx_ctl_rx_check_preamble                   => '0',
      ctl_rx_ctl_rx_check_sfd                        => '0',
      ctl_rx_ctl_rx_data_pattern_select              => '0',
      ctl_rx_ctl_rx_delete_fcs                       => '0',
      ctl_rx_ctl_rx_enable                           => '1',
      ctl_rx_ctl_rx_force_resync                     => '0',
      ctl_rx_ctl_rx_ignore_fcs                       => '0',
      ctl_rx_ctl_rx_max_packet_len(14 downto 0)      => (others => '1'),
      ctl_rx_ctl_rx_min_packet_len(7 downto 0)       => (others => '0'),
      ctl_rx_ctl_rx_process_lfi                      => '0',
      ctl_rx_ctl_rx_test_pattern                     => '0',
      ctl_rx_ctl_rx_test_pattern_enable              => '0',
      ctl_tx_ctl_tx_data_pattern_select              => '0',
      ctl_tx_ctl_tx_enable                           => '1',
      ctl_tx_ctl_tx_fcs_ins_enable                   => '0',
      ctl_tx_ctl_tx_ignore_fcs                       => '0',
      ctl_tx_ctl_tx_send_idle                        => '0',
      ctl_tx_ctl_tx_send_lfi                         => '0',
      ctl_tx_ctl_tx_send_rfi                         => '0',
      ctl_tx_ctl_tx_test_pattern                     => '0',
      ctl_tx_ctl_tx_test_pattern_enable              => '0',
      ctl_tx_ctl_tx_test_pattern_seed_a(57 downto 0) => (others => '0'),
      ctl_tx_ctl_tx_test_pattern_seed_b(57 downto 0) => (others => '0'),
      ctl_tx_ctl_tx_test_pattern_select              => '0',
      diff_clock_in_clk_n                            => gt_refclk_n,
      diff_clock_in_clk_p                            => gt_refclk_p,
      gt_loopback_in_0_0(2 downto 0)                 => "000",
      gt_refclk_out                                  => gt_ref_out,
      gt_rx_gt_port_0_n                              => gt_rxn_in_0,
      gt_rx_gt_port_0_p                              => gt_rxp_in_0,
      gt_tx_0_gt_port_0_n                            => gt_txn_in_0,
      gt_tx_0_gt_port_0_p                            => gt_txp_in_0,
      outclksel(2 downto 0)                          => "101",
      reset_rtl_0                                    => reset_n,
      tx_clk_out                                     => axis_clk_0
      );
end architecture;
