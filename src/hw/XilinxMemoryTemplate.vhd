--  Xilinx True Dual Port RAM Write First Single Clock
--  This code implements a parameterizable true dual port memory (both ports can read and write).
--  This implementes write-first mode where the data being written to the RAM also resides on
--  the output port.  If the output data is not needed during writes or the last read value is
--  desired to be retained, it is suggested to use no change as it is more power efficient.
--  If a reset or enable is not necessary, it may be tied off or removed from the code.

-- Following libraries have to be used
--use ieee.std_logic_1164.all;
--use std.textio.all;
--use ieee.numeric_std.all;


--Insert the following in the architecture before the begin keyword
--  The following function calculates the address width based on specified RAM depth
function clogb2( depth : natural) return integer is
variable temp    : integer := depth;
variable ret_val : integer := 0;
begin
    while temp > 1 loop
        ret_val := ret_val + 1;
        temp    := temp / 2;
    end loop;

    return ret_val;
end function;

-- Note :
-- If the chosen width and depth values are low, Synthesis will infer Distributed RAM.
-- C_RAM_DEPTH should be a power of 2
constant C_RAM_WIDTH : integer := <width>;                                                   -- Specify RAM data width
constant C_RAM_DEPTH : integer := <depth>;                                                   -- Specify RAM depth (number of entries)
constant C_RAM_PERFORMANCE : string := <ram_performance>;                  -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
constant C_INIT_FILE : string := <init_file>;                                         -- Specify name/location of RAM initialization file if using one (leave blank if not)

signal <addra> : std_logic_vector(clogb2(C_RAM_DEPTH)-1 downto 0);                          -- Port A Address bus, width determined from RAM_DEPTH
signal <addrb> : std_logic_vector(clogb2(C_RAM_DEPTH)-1 downto 0);                          -- Port B Address bus, width determined from RAM_DEPTH
signal <dina>  : std_logic_vector(C_RAM_WIDTH-1 downto 0);                                  -- Port A RAM input data
signal <dinb>  : std_logic_vector(C_RAM_WIDTH-1 downto 0);                                  -- Port B RAM input data
signal <clka>  : std_logic;                                                                 -- Clock
signal <wea>   : std_logic;                                                                 -- Port A Write enable
signal <web>   : std_logic;                                                                 -- Port B Write enable
signal <ena>   : std_logic;                                                                 -- Port A RAM Enable, for additional power savings, disable port when not in use
signal <enb>   : std_logic;                                                                 -- Port B RAM Enable, for additional power savings, disable port when not in use
signal <rsta>  : std_logic;                                                                 -- Port A Output reset (does not affect memory contents)
signal <rstb>  : std_logic;                                                                 -- Port B Output reset (does not affect memory contents)
signal <regcea>: std_logic;                                                                 -- Port A Output register enable
signal <regceb>: std_logic;                                                                 -- Port B Output register enable
signal <douta> : std_logic_vector(C_RAM_WIDTH-1 downto 0);                                  -- Port A RAM output data
signal <doutb> : std_logic_vector(C_RAM_WIDTH-1 downto 0);                                  -- Port B RAM output data
signal <douta_reg> : std_logic_vector(C_RAM_WIDTH-1 downto 0) := (others => '0');           -- Port A RAM output data when RAM_PERFORMANCE = HIGH_PERFORMANCE
signal <doutb_reg> : std_logic_vector(C_RAM_WIDTH-1 downto 0) := (others => '0');           -- Port B RAM output data when RAM_PERFORMANCE = HIGH_PERFORMANCE

type ram_type is array (C_RAM_DEPTH-1 downto 0) of std_logic_vector (C_RAM_WIDTH-1 downto 0);      -- 2D Array Declaration for RAM signal
signal <ram_data_a> : std_logic_vector(C_RAM_WIDTH-1 downto 0) ;
signal <ram_data_b> : std_logic_vector(C_RAM_WIDTH-1 downto 0) ;

-- The folowing code either initializes the memory values to a specified file or to all zeros to match hardware

function initramfromfile (ramfilename : in string) return ram_type is
file ramfile	: text is in ramfilename;
variable ramfileline : line;
variable ram_name	: ram_type;
variable bitvec : bit_vector(C_RAM_WIDTH-1 downto 0);
begin
    for i in ram_type'range loop
        readline (ramfile, ramfileline);
        read (ramfileline, bitvec);
        ram_name(i) := to_stdlogicvector(bitvec);
    end loop;
    return ram_name;
end function;

function init_from_file_or_zeroes(ramfile : string) return ram_type is
begin
    if ramfile = "<Init File Name>" then
        return InitRamFromFile("<Init File Name>") ;
    else
        return (others => (others => '0'));
    end if;
end;

-- Define RAM
shared vairable <ram_name> : ram_type := init_from_file_or_zeroes(C_INIT_FILE);

--Insert the following in the architecture after the begin keyword
process(<clka>)
begin
    if(<clka>'event and <clka> = '1') then
        if(<ena> = '1') then
            if(<wea> = '1') then
                <ram_name>(to_integer(unsigned(<addra>))) := <dina>;
                <ram_data_a> <= <dina>;
            else
                <ram_data_a> <= <ram_name>(to_integer(unsigned(<addra>)));
            end if;
        end if;
    end if;
end process;

process(<clka>)
begin
    if(<clka>'event and <clka> = '1') then
        if(<enb> = '1') then
            if(<web> = '1') then
                <ram_name>(to_integer(unsigned(<addrb>))) := <dinb>;
                <ram_data_b> <= <dinb>;
            else
                <ram_data_b> <= <ram_name>(to_integer(unsigned(<addrb>)));
            end if;
        end if;
    end if;
end process;

--  Following code generates LOW_LATENCY (no output register)
--  Following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing

no_output_register : if C_RAM_PERFORMANCE = "LOW_LATENCY" generate
    <douta> <= <ram_data_a>;
    <doutb> <= <ram_data_b>;
end generate;

--  Following code generates HIGH_PERFORMANCE (use output register)
--  Following is a 2 clock cycle read latency with improved clock-to-out timing

output_register : if C_RAM_PERFORMANCE = "HIGH_PERFORMANCE"  generate
process(<clka>)
begin
    if(<clka>'event and <clka> = '1') then
        if(<rsta> = '1') then
            <douta_reg> <= (others => '0');
        elsif(<regcea> = '1') then
            <douta_reg> <= <ram_data_a>;
        end if;
    end if;
end process;
<douta> <= <douta_reg>;

process(<clka>)
begin
    if(<clka>'event and <clka> = '1') then
        if(<rstb> = '1') then
            <doutb_reg> <= (others => '0');
        elsif(<regceb> = '1') then
            <doutb_reg> <= <ram_data_b>;
        end if;
    end if;
end process;
<doutb> <= <doutb_reg>;

end generate;

							
						
