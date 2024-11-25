-- driver.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all; -- for UNIFORM, TRUNC
use ieee.numeric_std.all; -- for TO_UNSIGNED
use std.textio.all;
use ieee.std_logic_textio.all;

entity driver is
    port(   clk : in   std_logic;
            cmd   :   inout   std_logic;
            n0,n1,n2 : in signed( 1 downto 0 );
            req   :   inout  std_logic_vector(2 downtoto 0));
end entity;

architecture bhv of driver is
file display : text open write_mode is "Display.txt"; 
constant n : real:=10.0;
begin
procedure WriteToDisplay(
    signal req: in std_logic_vector(2 downto 0);
    signal n0_write:  in signed(1 downto 0);
    signal n1_write:  in signed(1 downto 0);
    signal n2_write:  in signed(1 downto 0)) is
    variable displayLine: line;
    begin
        write(displayLine, req);
        write(displayLine, ' ');
        write(displayLine, n0_write);
        write(displayLine, ' ');
        write(displayLine, n1_write);
        write(displayLine, ' ');
        write(displayLine, n2_write);
        writeline(display, displayLine);
end procedure;

--clk <= not(clk) after 10 ns;

process(clk)
-- Seed values for random generator
   variable seed1, seed2: positive;
-- Random real-number value in range 0 to 1.0
   variable rand: real;
-- Random integer value in range 0..7
   variable int_rand_wait, int_rand_req, count: integer := 0;
-- Next req
   variable req_next : std_logic_vector(2 downto 0) :="000"; 
   
   begin
-- initialise seed1, seed2 if you want -
-- otherwise they're initialised to 1 by default
   
   if count=0 then
       -- Random wait
       UNIFORM(seed1, seed2, rand);
       -- 1. rescale to 1..n, find integer part
       int_rand_wait := INTEGER(TRUNC(rand*n)) + 1;

       -- Random req
       UNIFORM(seed1, seed2, rand);
      -- get a 3-bit random value...
      -- 1. rescale to 0..7, find integer part
      int_rand_req := INTEGER(TRUNC(rand*8.0));
      -- 2. convert to std_logic_vector
      req_next := std_logic_vector(to_unsigned(int_rand_req, req'LENGTH));
   end if;
   

   if clk'event and clk='1' then
   --To be completed
        if count = int_rand_req then
            cmd <= not cmd;
            req <= req_next;
            count <= 0;
        else
            count <= count + 1;
        end if;
   end if;
       
end process;

process(cmd)
begin
   --To be completed for display req,n0,n1 and n2
   if cmd = '1' then
        WriteToDisplay(req, n0, n1, n2);
   end if;
 end process;         

end architecture;