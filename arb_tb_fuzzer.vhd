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
 
 
    COMPONENT arb
    PORT(
         clk : IN  std_logic;
         cmd : IN  std_logic;
         rst_n : IN  std_logic;
         req : IN  std_logic_vector(0 to 2);

         gnt : INOUT  std_logic_vector(0 to 2);
			   N1 : out signed(4 downto 0);
			   N2 : out signed(4 downto 0);
			   N3 : out signed(4 downto 0);
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal cmd : std_logic := '0';
   signal rst_n : std_logic := '1';
   signal req : std_logic_vector(0 to 2) := (others => '0');
   signal eof1 : integer;
	--BiDirs
   signal gnt : std_logic_vector(0 to 2);
	signal N1 : signed(4 downto 0);
	signal N2 : signed(4 downto 0);
	signal N3 : signed(4 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: arb PORT MAP (
          clk => clk,
          cmd => cmd,
          rst_n => rst_n,
          req => req,
			 N1 => N1,
			 N2 => N2,
			 N3 => N3,
          gnt => gnt
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
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
		
		rst_n <= '1';

		readline(logfile, row); 
		
	        if  (row.all = string'("Done")) then

			
			if (to_integer(n3) <= to_integer(n2) and to_integer(n3) <= to_integer(n1)) then
				write(row1,to_integer(n3));
			elsif to_integer(n2) <= to_integer(n1) then
				write(row1,to_integer(n2));
			else
				write(row1,to_integer(n1));
			end if;
			writeline(logfile1,row1);
			
			
			rst_n <= '0';
			
			
	
		 else 	

			  read (row,buf1);
			  
			  cmd <= buf1(3);
			  req <= buf1(2 downto 0);

			
		 end if;	
		wait until clk = '1';
		
	end loop;
	wait until clk = '1';
	stop;
   end process;

END;
