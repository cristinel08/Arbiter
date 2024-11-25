-- Simple OR gate design
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ARB is
port(
  clk: in std_logic;
  rst: in std_logic;
  cmd: in std_logic;
  req: in std_logic_vector(2 downto 0);
  gnt: out std_logic_vector(2 downto 0));
end ARB;

architecture rtl of ARB is
signal internal_gnt, internal_req: std_logic_vector(2 downto 0) := "000";
signal N0, N1, N2: signed(2 downto 0) := "000";
signal delay_cmd: std_logic := '0';
type state is (
				Init, 
  				GRANT_RESOURCE,
                UPDATE_RESOURCE, 
                S0, 
                S1, 
                S2
               );
signal reqState : state;
begin
  process(rst, clk) is
  begin
    if (rst) then
        reqState <= GRANT_RESOURCE;
        --N0 <= "000";
        --N1 <= "000";
        --N2 <= "000";
    elsif (clk'event and clk='1') then
    	case reqState is
        	when INIT =>
                internal_req <= req;
            	reqState <= GRANT_RESOURCE;
            when GRANT_RESOURCE=>
            	if cmd then
                	internal_req <= req;
                	reqState <= UPDATE_RESOURCE;
                end if;
            when UPDATE_RESOURCE =>
            	case internal_req is
                	when "001" =>
                    	reqState <= S0;
                    when "010" =>
                    	reqState <= S1;
                    when "011" =>
                    	if (N1 < N0) then
                        	reqState <= S1;
                            N1 <= N1 + 1;
                            N0 <= N0 - 1;
                        else
                            N0 <= N1 - 1;
                            N1 <= N0 + 1;
                        	reqState <= S0;
                        end if;
                   	when "100" =>
                    	reqState <= S2;
                    when "101" =>
                    	if (N2 < N0) then
                            N2 <= N2 + 1;
                            N0 <= N0 - 1;
                        	reqState <= S2;
                        else
                          	N2 <= N2 - 1;
                            N1 <= N1 + 1;
                        	reqState <= S0;
                        end if;
                    when "110" =>
                    	if(N2 < N1) then
                            N2 <= N2 + 1;
                            N1 <= N1 - 1;
                        	reqState <= S2;
                        else 
                            N2 <= N2 - 1;
                            N1 <= N1 + 1;
                        	reqState <= S1;
                       	end if;
                    when "111" =>
                    	if (N2 < N1 and N2 < N0) then
                        	reqState <= S2;
                            N2 <= N2 + 1;
                            N1 <= N1 - 1;
                            N0 <= N0 - 1;
                        elsif (N1 < N2 and N1 < N0) then
                        	reqState <= S1;
                            N2 <= N2 - 1;
                            N1 <= N1 + 1;
                            N0 <= N0 - 1;
                        else
                        	reqState <= S0;
                            N2 <= N2 - 1;
                            N1 <= N1 - 1;
                            N0 <= N0 + 1;
                        end if;
                    when others =>
                end case;
            when others =>
          		if cmd then
                	internal_req <= req;
            		reqState <= UPDATE_RESOURCE;
                else
                	reqState <= GRANT_RESOURCE;
                end if;
        end case;
		if (N2 = "100" or
          N2 = "011") then
              N2 <= N2;   
        end if;
        if (N1 = "100" or
            N1 = "011") then
                N1 <= N1;
        end if;
        if (N0 = "100" or
            N0 = "011") then
                N0 <= N0;
        end if;  
        --gnt <= internal_gnt;
        --gnt <= "000";
    end if;
  end process;
  
  process(reqState) is
  begin
  	case reqState is
        when Init =>
        	--internal_gnt <= "000";
            gnt <= "000"; 
    	when S0 =>
        	--internal_gnt <= "001";
            gnt <= "001";
        when S1 =>
        	--internal_gnt <= "010";
            gnt <= "010";
        when S2 =>
        	--internal_gnt <= "100";
            gnt <= "100";
         when GRANT_RESOURCE =>
            --gnt <= internal_gnt;
        when UPDATE_RESOURCE =>
        	--internal_gnt <= "000";
            gnt <= "000";
    end case; 
  end process;
  
end rtl;
