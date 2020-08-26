-------------------------------------------------------------------------------
-- Auto generated file
-- compiler version $compVersion
-- template version : 1.0
-- payload shifter
-- Control bit 'high is to register signal. Control bit high-1 to 0 are for value selection
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity payload_shifter is
  generic (
    nbInput       : natural := 8;       --! nbInputBits
    dataWidth     : natural := 8;       --! width of data
    keepWidth     : natural := 1;
    nbBitsControl : natural := 8);      --! nb controlBits

  port (
    clk     : in  std_logic;
    ctrl    : in  std_logic_vector(nbBitsControl - 1 downto 0);
    data    : in  std_logic_vector(nbInput * dataWidth - 1 downto 0);
    keep    : in  std_logic_vector(nbInput * keepWidth - 1 downto 0);
    selKeep : out std_logic_vector(keepWidth -1 downto 0);
    selData : out std_logic_vector(width - 1 downto 0));
end entity payload_shifter;

architecture behavioral of payload_shifter is
  component mux is
    generic (
      nbInput       : natural;
      width         : natural;
      nbBitsControl : natural);
    port (
      clk     : in  std_logic;
      control : in  std_logic_vector(nbBitsControl - 1 downto 0);
      input   : in  std_logic_vector(nbInput * width - 1 downto 0);
      output  : out std_logic_vector(width - 1 downto 0));
  end component mux;
  signal selData_tmp     : std_logic_vector(data'range);
  signal selData_tmp_reg : std_logic_vector(data'range);
  signal selKeep_tmp     : std_logic_vector(keep'range);
  signal selKeep_tmp_reg : std_logic_vector(keep'range);
  signal ctrlPos         : std_logic_vector(nbBitsControl - 2 downto 0);  --! data to select
  signal selReg          : std_logic;   --! register selected datas
begin
  selReg  <= ctrl(ctrl'high);
  ctrlPos <= ctrl(ctrl'high - 1 downto 0);

  mux_data : entity work.mux
    generic map (nbInput       => nbInput,
                 width         => dataWidth,
                 nbBitsControl => nbBitsControl - 1)
    port map (
      clk     => clk,
      control => ctrlPos,
      input   => data,
      output  => selData_tmp);


  mux_keep : entity work.mux
    generic map (nbInput       => nbInput,
                 width         => keepWidth,
                 nbBitsControl => nbBitsControl - 1)
    port map (
      clk     => clk,
      control => ctrlPos,
      input   => keep,
      output  => selKeep_tmp);


  process(clk) is
  begin
    if rising_edge(clk) then
      selData_tmp_reg <= selData_tmp;
      selKeep_tmp_reg <= selKeep_tmp;
    end if;
  end process;

  process(selReg, selData_tmp, selData_tmp_reg,
          selKeep_tmp, selKeep_tmp_reg) is
  begin
    if selReg = '1' then
      selData <= selData_tmp_reg;
      selKeep <= selKeep_tmp_reg;
    else
      selData <= selData_tmp;
      selKeep <= selKeep_tmp;
    end if;
  end process;
end architecture;
