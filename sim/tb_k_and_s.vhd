--------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Joao Leonardo Fragoso
--
-- Create Date:   19:56:12 06/26/2012
-- Design Name:   K and S Modeling
-- Module Name:   tb_k_and_s.vhd
-- Description:   Testbench for simulating and verifing K and S processor model
-- 
-- 
-- Dependencies: k_and_s.vhd, k_and_s_pkg.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;

entity tb_k_and_s is
end tb_k_and_s;

architecture behavior of tb_k_and_s is

  --K and S Inputs
  signal rst_n         : std_logic := '0';
  signal clk           : std_logic := '0';
  signal data_from_ram : std_logic_vector(15 downto 0);

  --K and S Outputs
  signal halt             : std_logic;
  signal ram_addr         : std_logic_vector(4 downto 0);
  signal data_to_ram      : std_logic_vector(15 downto 0);
  signal ram_write_enable : std_logic;

  -- RAM Control Signals
  signal ram_operation : string(1 to 11) := "LOAD_MEMORY";
  signal ram_done      : std_logic;
  signal ram_loading   : std_logic;
  signal ram_dumping   : std_logic;
  -- Clock period definitions
  constant clk_period  : time                := 10 ns;
  
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : entity k_and_s port map (
    rst_n        => rst_n,
    clk          => clk,
    halt         => halt,
    addr         => ram_addr,
    data_in      => data_from_ram,
    data_out     => data_to_ram,
    write_enable => ram_write_enable
    );

  ram : entity work.ram_model
    generic map (
    FILE_NAME => "program.hex",  -- file to load
    DUMP_FILE => "ram.hex"       -- file to dump memory
    )
    port map (
      clk            => clk,
      addr           => ram_addr,
      data_in        => data_to_ram,
      data_out       => data_from_ram,
      write_enable   => ram_write_enable,
      operation_mode => ram_operation,
      done           => ram_done,
      loading        => ram_loading,
      dumping        => ram_dumping
      );

  -- Clock process definitions
  clk_100Mhz : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;


  -- Stimulus process
  testbench_control : process
    variable output_line_v : line;
  begin
    -- hold reset state until memory is loaded
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    write(output_line_v, string'("[[ TBT ]] Asking memory to load data"));
    writeline(output, output_line_v);
    write(output_line_v, string'("[[ TBT ]] Waiting memory loading process"));
    writeline(output, output_line_v);
    ram_operation <= "LOAD_MEMORY";
    wait until (clk'event and clk = '1' and ram_loading = '1');
    ram_operation <= "NORMAL_OPER";
    wait until (clk'event and clk = '1' and ram_done = '1' and ram_loading = '0');
    write(output_line_v, string'("[[ TBT ]] Memory load is finished, releasing Reset in next cycle"));
    writeline(output, output_line_v);
    wait until (clk'event and clk = '1');
    rst_n         <= '1';               -- releasing reset signal
    write(output_line_v, string'("[[ TBT ]] Reset is de-asserted. K and S processor must start now"));
    writeline(output, output_line_v);
    wait until (clk'event and clk = '1');
    write(output_line_v, string'("[[ TBT ]] Testbench is waiting HALT signal"));
    writeline(output, output_line_v);
    wait until (clk'event and clk = '1' and halt = '1');
    write(output_line_v, string'("[[ TBT ]] K and S is HALTED!!!"));
    writeline(output, output_line_v);
    wait until (clk'event and clk = '1');
    write(output_line_v, string'("[[ TBT ]] Asking memory to dump data"));
    writeline(output, output_line_v);
    write(output_line_v, string'("[[ TBT ]] Waiting memory dumping process"));
    writeline(output, output_line_v);
    ram_operation <= "DUMP_MEMORY";
    wait until (clk'event and clk = '1' and ram_dumping = '1');
    ram_operation <= "NORMAL_OPER";
    wait until (clk'event and clk = '1' and ram_done = '1' and ram_dumping = '0');
    write(output_line_v, string'("[[ TBT ]] Memory dump is finished, stop simulation in two clock cycle"));
    writeline(output, output_line_v);
    wait until (clk'event and clk = '1');
    wait until (clk'event and clk = '1');
    assert false report "[[ TBT ]] Testbench finished normally... ignore this failure!" severity failure;
  end process;

end;

