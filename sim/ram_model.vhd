----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Joao Leonardo Fragoso
-- 
-- Create Date:    19:11:14 06/26/2012 
-- Design Name:    K and S Modeling
-- Module Name:    ram_model - Behavioral 
-- Description: RAM model for use and "K and S". This module has normal
-- behavioral and load/dump from memory data
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

entity ram_model is
  generic (
    FILE_NAME : string := "program.hex";  -- file to load
    DUMP_FILE : string := "ram.hex"       -- file to dump memory
    );
  port (
    clk            : in  std_logic;
    addr           : in  std_logic_vector (4 downto 0);
    data_in        : in  std_logic_vector (15 downto 0);
    data_out       : out std_logic_vector (15 downto 0);
    write_enable   : in  std_logic;
    operation_mode : in  string(1 to 11);
    done           : out std_logic;
    loading        : out std_logic;
    dumping        : out std_logic
    );
end ram_model;

architecture Behavioral of ram_model is

  function hex_to_std_logic_vector ( s : string ) return std_logic_vector is
    variable slv : std_logic_vector(4*s'length-1 downto 0);
    variable j   : integer := 4*s'length-1;
  begin
    for i in s'range loop
      case (s(i)) is
        when '0'       => slv(j downto j-3) := x"0";
        when '1'       => slv(j downto j-3) := x"1";
        when '2'       => slv(j downto j-3) := x"2";
        when '3'       => slv(j downto j-3) := x"3";
        when '4'       => slv(j downto j-3) := x"4";
        when '5'       => slv(j downto j-3) := x"5";
        when '6'       => slv(j downto j-3) := x"6";
        when '7'       => slv(j downto j-3) := x"7";
        when '8'       => slv(j downto j-3) := x"8";
        when '9'       => slv(j downto j-3) := x"9";
        when 'A' | 'a' => slv(j downto j-3) := x"A";
        when 'B' | 'b' => slv(j downto j-3) := x"B";
        when 'C' | 'c' => slv(j downto j-3) := x"C";
        when 'D' | 'd' => slv(j downto j-3) := x"D";
        when 'E' | 'e' => slv(j downto j-3) := x"E";
        when 'F' | 'f' => slv(j downto j-3) := x"F";
        when others    =>
          assert false report "There is unvalid caracter into string hex - > std_logic_vector. The result will be 'X'" severity warning;
          slv(j downto j-3) := "XXXX";
      end case;
      j := j-4;
    end loop;  -- i
    return slv;
  end hex_to_std_logic_vector;


  type ram_table_type is array(natural range <>) of std_logic_vector(15 downto 0);  -- type for declaring ram table
  signal mem_data : ram_table_type(0 to 31);
  constant c0x    : string(1 to 2) := "0x";
begin


  main_control : process
    variable counter       : integer;   -- only used for load/dump process
    variable line_v        : line;
    variable line_size     : integer;
    variable output_line_v : line;
    variable field_v       : string(1 to 200);
    variable ptr_value     : integer;
    file ptr_file          : TEXT;
    variable file_status   : file_open_status;
  begin  -- process main_control
    wait until clk'event and clk = '1';
    case operation_mode is
      when "LOAD_MEMORY" =>                   -- LOAD DATA FROM FILE
        loading <= '1';
        counter := 0;
        write(output_line_v, string'("[[ RAM ]]Reading File : " & FILE_NAME));
        writeline(output, output_line_v);
        file_open(file_status, ptr_file, FILE_NAME, read_mode);
        assert (file_status = open_ok)
          report string'("[[ RAM ]] Could not open file " & FILE_NAME)
          severity failure;
        while (counter < 32 and not(endfile(ptr_file))) loop
          readline(ptr_file, line_v);
          line_size := line_v'length;
          read(line_v, field_v(1 to line_size));  -- line_v length to avoid
                                                  -- length mismatch
          write(output_line_v, string'("[[ RAM ]]"));
          if (field_v(1) /= ';') then
                if (counter < 10) then
                    write(output_line_v, string'("  "));
                else
                    write(output_line_v, string'(" "));
                end if;
                write(output_line_v, counter);
                mem_data(counter) <= hex_to_std_logic_vector(field_v(1 to 4));
                counter := counter + 1;
          end if;
          write(output_line_v, string'(" " & field_v(1 to line_size)));
          writeline(output, output_line_v);
          wait until clk'event and clk = '1';
        end loop;
        wait until clk'event and clk = '1';
        file_close(ptr_file);
        write(output_line_v, string'("[[ RAM ]]File Loaded - releasing memory"));
        writeline(output, output_line_v);
        wait until clk'event and clk = '1';
        loading <= '0';
        done    <= '1';
        wait until clk'event and clk = '1';
        done    <= '0';
      when "DUMP_MEMORY" =>
        dumping <= '1';
        counter := 0;
        writeline(output, output_line_v);
        writeline(output, output_line_v);
        write(output_line_v, string'("[[ RAM ]]Dumping RAM to File : " & DUMP_FILE));
        writeline(output, output_line_v);
        file_open(file_status, ptr_file, DUMP_FILE, write_mode);
        assert (file_status = open_ok)
          report string'("[[ RAM]] Could not open file " & FILE_NAME & " for dumping memory")
          severity failure;
        while (counter < 32) loop
          hwrite(output_line_v, mem_data(counter));
          writeline(ptr_file, output_line_v);
             write(output_line_v, string'("[[ RAM ]] "));
             if (counter < 10) then
                write(output_line_v, string'(" "));
             end if;
             write(output_line_v, counter);
             write(output_line_v, string'(" "));
          hwrite(output_line_v, mem_data(counter));
          writeline(output, output_line_v);
          wait until clk'event and clk = '1';
             counter := counter + 1;
        end loop;
        wait until clk'event and clk = '1';
        file_close(ptr_file);
        write(output_line_v, string'("[[ RAM ]]Memory Dumped - releasing memory"));
        writeline(output, output_line_v);
        wait until clk'event and clk = '1';
        dumping <= '0';
        done    <= '1';
        wait until clk'event and clk = '1';
        done    <= '0';
      when others =>                    -- NORMAL OPERATION
        if (write_enable = '1') then
          mem_data(conv_integer(addr)) <= data_in;
          data_out                     <= data_in;
        else
          data_out <= mem_data(conv_integer(addr));
        end if;
    end case;
  end process main_control;

end Behavioral;

