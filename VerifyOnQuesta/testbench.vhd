-- Testbench for OR gate
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
 
entity testbench is
-- empty
end testbench; 

architecture tb of testbench is

-- DUT component
component ARB is
port(
  clk: in std_logic;
  rst: in std_logic;
  cmd: in std_logic;
  req: in std_logic_vector(2 downto 0);
  gnt: out std_logic_vector(2 downto 0);
  n0_out: out signed (1 downto 0);
  n1_out: out signed(1 downto 0);
  n2_out: out signed(1 downto 0));
end component;

component property_checker is
port(
	clk: in std_logic;
    cmd: in std_logic;
    req: in std_logic_vector(2 downto 0);
    gnt: in std_logic_vector(2 downto 0);
    fails: out std_logic_vector(2 downto 0));
end component;

component protocol_checker is
port(
    clk: in std_logic;
    cmd: in std_logic;
    req: in std_logic_vector(2 downto 0);
    protocol_violation: out std_logic);
end component;

component driver is
port(
	clk: in std_logic;
	cmd: inout std_logic;
	n0,n1,n2: in signed(1 downto 0);
	req: inout std_logic_vector(2 downto 0));
end component;

signal rst_in, clk_in: std_logic := '0';
signal cmd_in:std_logic := '0';
signal gnt, req_in, fails: std_logic_vector(2 downto 0);
signal protocol_violation: std_logic;
signal n0_out, n1_out, n2_out: signed(1 downto 0);

begin
	
  -- Connect DUT
  DUT: ARB 
  	port map(
  	clk_in,
        rst_in,
        cmd_in,
        req_in, 
        gnt,
        n0_out,
        n1_out,
        n2_out);
  prp_checker: property_checker 
  	port map(
  	      clk_in,
          cmd_in,
          req_in,
          gnt,
          fails);
  prot_checker: protocol_checker
  	port map(
          clk_in,
          cmd_in,
          req_in,
          protocol_violation);
  driver_checker: driver
	port map(
          clk_in,
          cmd_in,
          n0_out,
          n1_out,
          n2_out,
          req_in);

  clk_toggle : process begin
    wait for 5 ns;
  	clk_in <= not clk_in;
  	wait for 5 ns;
  end process;
  -- cmd_toggle: process begin
  --   --wait for 10 ns;
  --   --wait for 5 ns;
  --   cmd_in <= not cmd_in;
  --   wait for 26 ns;
  -- end process;
  process
  begin
  	-- rst_in <= '1';
	-- req_in <= "000";
    -- wait for 10 ns;
  
  	-- rst_in <= '0';
    --req_in <= "100";
  --   wait for 10 ns;
   
  --   --req_in <= "010";
  --   wait for 20 ns;
   
	-- --req_in <= "001";
  --   wait for 100 ns;
    
  --   req_in <= "110";
  --   wait for 50 ns;
    
  --   req_in <= "101";
  --   wait for 50 ns;
    
  --   req_in <= "011";
  --   wait for 50 ns;
    
  --   req_in <= "111";
  --   wait for 50 ns;
    
  --   req_in <= "101";
  --   wait for 50 ns;
  --   -- Clear inputs
  --   rst_in <= '1';
  --   wait for 20 ns;
    
  --   rst_in <= '0';

    wait;
  end process;
end tb;
