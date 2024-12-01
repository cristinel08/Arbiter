library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.env.stop;
 
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
 
ENTITY arb_tb_fuzzer IS
END arb_tb_fuzzer;
 
ARCHITECTURE behavior OF arb_tb_fuzzer IS 
    COMPONENT ARB
    PORT(
         clk : IN  std_logic;
         cmd : IN  std_logic;
         rst : IN  std_logic;
         req : IN  std_logic_vector(2 downto 0);
         gnt : INOUT  std_logic_vector(2 downto 0);
		 n0_out : out signed(1 downto 0);
		 n1_out : out signed(1 downto 0);
		 n2_out : out signed(1 downto 0));
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal cmd : std_logic := '0';
   signal rst : std_logic := '0';
   signal req : std_logic_vector(2 downto 0) := (others => '0');
   signal eof1 : integer;
	--BiDirs
   signal gnt : std_logic_vector(2 downto 0);
	signal n0_out : signed(1 downto 0);
	signal n1_out : signed(1 downto 0);
	signal n2_out : signed(1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ARB PORT MAP (
          clk => clk,
          cmd => cmd,
          rst => rst,
          req => req,
          gnt => gnt,
		  n0_out => n0_out,
		  n1_out => n1_out,
		  n2_out => n2_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= not clk;
		wait for clk_period/2;
		-- clk <= '1';
		-- wait for clk_period/2;
   end process;
 

   -- Stimulus proces
   stim_proc: process 
	file logfile: text open read_mode is "sequences.txt";
	variable row,row1 : line;
	file logfile1: text open write_mode is "results.txt";
	variable buf : character;
	variable eof : boolean;
	variable buf1 : std_logic_vector(3 downto 0);
	variable min : integer;
   begin	

	while (not endfile(logfile))  loop
		wait until clk = '1';	
		rst <= '0';
		readline(logfile, row); 
		-- report "Processing line: " & row.all;
		if  (row.all = string'("Done")) then
			if (to_integer(n2_out) <= to_integer(n1_out) and to_integer(n2_out) <= to_integer(n0_out)) then
				write(row1,to_integer(n2_out));
			elsif to_integer(n1_out) <= to_integer(n0_out) then
				write(row1,to_integer(n1_out));
			else
				write(row1,to_integer(n0_out));
			end if;
			writeline(logfile1, row1);				
			rst <= '1';	
		else 	
				read (row, buf1);
				cmd <= buf1(3);
				req <= buf1(2 downto 0);			
		end if;		
	end loop;
	wait until clk = '1';
	stop;
   end process;

END;
