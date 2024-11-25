library IEEE;
use IEEE.std_logic_1164.all;

entity protocol_checker is
    port(clk, cmd :    in    std_logic;
        req		  :    in    std_logic_vector(2 downto 0);
        protocol_violation    :    out   std_logic:='0');
end entity;

architecture bhv of protocol_checker is

	signal violation_1,violation_2 : std_logic := '0';
	signal count: integer := 0;
begin
	process(clk)
    	--variable count: integer := 0;
	begin
		if clk'event and clk='1' then 			
			if cmd = '1' then
				count <= count + 1;
			else	
				count <= 0;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if falling_edge(clk) then
			--Property 1       
			violation_1 <= '0'; --to be completed
			if count = 2 then
				violation_1 <= '1';
            end if;
			--Property 2
			violation_2 <= '0';
			if (cmd = '1' and req = "000") then      --to be completed  
                	violation_2 <= '1'; 
            end if;
		end if;
	end process;

	protocol_violation <= violation_1 or violation_2;

end bhv;