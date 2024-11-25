-- property_checker.vhd

library IEEE;
use IEEE.std_logic_1164.all;


entity property_checker is
    port(clk, cmd :    in    std_logic;
        req, gnt  :    in    std_logic_vector(2 downto 0);
        fails     :    out   std_logic_vector(2 downto 0):="000");
end property_checker;

architecture bhv of property_checker is

signal save_req : std_logic_vector(2 downto 0);
signal enable_count : std_logic := '0';
signal count : integer := 0;
signal startFrom1: std_logic := '0';
signal delayStartFrom1:std_logic := '0';
begin



process(clk)
    begin
        if clk'event and clk = '1' then
            if enable_count = '1' then
                count <= count + 1;
            end if;
            if count = 1 and cmd = '1' then
                save_req <= req;
                startFrom1 <= '1';
                -- count <= 1;
            elsif count = 2 and startFrom1 = '1' then
                count <= 1;
                startFrom1 <= '0';
            elsif count = 4 then
                enable_count <= '0';
                count <= 0;
            end if;
            if cmd ='1' and enable_count = '0' then
            enable_count<='1';
            count <= 0;
            save_req <= req;
            end if;
            delayStartFrom1 <= startFrom1;
        end if;
end process;

process(count)
begin
    if gnt/="001" and gnt/="010" and gnt/="100" and count = 2 then
        fails(0) <= '1';
    else
        fails(0) <= '0';
    end if;
    if gnt/="000" and (count = 3 or delayStartFrom1 = '1') then
        fails(1) <= '1';
    else
        fails(1) <= '0';
    end if;       
        --property 2 : to be completed
    if ((gnt = "000" or save_req = "000") and count = 2) then
        fails(2) <= '1';
    else
        fails(2) <= '0';
    end if;
end process;
-- process(count)
-- begin
-- 		if clk'event and clk = '1'then
--             save_req <= req;
--         end if;
-- end process;

-- process(clk)
-- begin
-- 		  if clk'event and clk = '1' then
--                 --property 0
--             if (gnt/="001" and gnt/="010" and gnt/="100" and triple_delay = '1') then
--                 fails(0) <= '1';
--             else
--                 fails(0) <= '0';
--             end if;

--                --property 1 : to be completed
--             if (gnt/="000" and triple_delay = '0') then
--                 fails(1) <= '1';
--             else
--                 fails(1) <= '0';
--             end if;       
--                --property 2 : to be completed
--             if (triple_delay = '1' and ((gnt and save_req) = "000")) then
--                 fails(2) <= '1';
--             else
--                 fails(2) <= '0';
--             end if;
--           end if;
-- end process;

end bhv;
