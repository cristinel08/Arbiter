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
  gnt: out std_logic_vector(2 downto 0);
  n0_out : out signed(1 downto 0);
  n1_out : out signed(1 downto 0); 
  n2_out: out signed(1 downto 0));
end ARB;

architecture rtl of ARB is
signal internal_gnt, internal_req: std_logic_vector(2 downto 0) := "000";
signal N0, N1, N2: signed(1 downto 0) := "00";
type state is (
                Init, 
                GRANT_RESOURCE,
                UPDATE_RESOURCE, 
                S0, 
                S1, 
                S2
               );
signal reqState : state;
signal addN0, addN1, addN2,modN0, modN1, modN2 : std_logic:= '0';
signal enableAdd : std_logic := '0';
begin
  process(rst, clk) is

  begin
    if (rst = '1') then
        reqState <= GRANT_RESOURCE;
        enableAdd <= '0';
    elsif (clk'event and clk='1') then
    	case reqState is
        	when INIT =>
                internal_req <= req;
            	reqState <= GRANT_RESOURCE;
            when GRANT_RESOURCE=>
            	if cmd = '1' and not(req = "000") then
                	internal_req <= req;
                    enableAdd <= '1';
                	reqState <= UPDATE_RESOURCE;
                end if;
            when UPDATE_RESOURCE =>
            	case internal_req is
                    when "001" =>
                    	reqState <= S0;
                    when "010" =>
                    	reqState <= S1;
                    when "100" =>
                    	reqState <= S2;
                    when "011" =>
                    	if (N1 < N0) then
                        	reqState <= S1;
                            addN1 <= '1';
                            addN0 <= '0';
                        else
                            addN0 <= '1';
                            addN1 <= '0';
                        	reqState <= S0;
                        end if;
                        modN0 <= not modN0;
                        modN1 <= not modN1;
                    when "101" =>
                    	if (N2 < N0) then
                            addN2 <= '1';
                            addN0 <= '0';
                        	reqState <= S2;
                        else
                            addN0 <= '1';
                            addN2 <= '0';
                        	reqState <= S0;
                        end if;
                        modN0 <= not modN0;
                        modN2 <= not modN2;
                    when "110" =>
                    	if(N2 < N1) then
                            addN2 <= '1';
                            addN1 <= '0';
                        	reqState <= S2;
                        else 
                            addN2 <= '0';
                            addN1 <= '1';
                        	reqState <= S1;
                       	end if;
                        modN2 <= not modN2;
                        modN1 <= not modN1;
                    when "111" =>
                    	if (N2 < N1 and N2 < N0) then
                        	reqState <= S2;
                            addN0 <= '0';
                            addN1 <= '0';
                            addN2 <= '1';
                        elsif (N1 < N2 and N1 < N0) then
                        	reqState <= S1;
                            addN0 <= '0';
                            addN1 <= '1';
                            addN2 <= '0';
                        else
                        	reqState <= S0;
                            addN0 <= '1';
                            addN1 <= '0';
                            addN2 <= '0';
                        end if;
                        modN0 <= not modN0;
                        modN1 <= not modN1;
                        modN2 <= not modN2;
                    when others =>
                        reqState <= UPDATE_RESOURCE;
                end case;
            when others =>
          		if cmd = '1' and req /= "000" then
                		internal_req <= req;
            			reqState <= UPDATE_RESOURCE;
                else
                	reqState <= GRANT_RESOURCE;
                end if;
        end case; 
        -- gnt <= internal_gnt;
    end if;
  end process;

  process(modN0, rst) is
  begin
    if (rst = '1') then
        N0 <= "00";
    elsif enableAdd = '1' then 
        if (addN0 = '1') then
            if (N0 = "01") then
                N0 <= N0;
            else
                N0 <= N0 + 1;
            end if;
        else
            if (N0 = "10") then
                N0 <= N0;
            else
                N0 <= N0 - 1;
            end if;
        end if;
    end if;
  end process;

process(modN1, rst) is
  begin
    if (rst = '1') then
        N1 <= "00";
    elsif (enableAdd = '1') then
        if (addN1 = '1') then
            if (N1 = "01") then
                N1 <= N1;
            else
                N1 <= N1 + 1;
            end if;
        else
            if (N1 = "10") then
                N1 <= N1;
            else
                N1 <= N1 - 1;
            end if;
        end if;
    end if;
  end process;

process(modN2, rst) is
  begin
    if rst = '1' then
        N2 <= "00";
    elsif enableAdd = '1' then
        if (addN2 = '1') then
            if (N2 = "01") then
                N2 <= N2;
            else
                N2 <= N2 + 1;
            end if;
        else
            if (N2 = "10") then
                N2 <= N2;
            else
                N2 <= N2 - 1;
            end if;
        end if;
    end if;
  end process;
  
  process(reqState) is
  begin
  	case reqState is
        when Init =>
        	-- internal_gnt <= "000";
            gnt <= "000"; 
    	when S0 =>
        	-- internal_gnt <= "001";
            gnt <= "001";
        when S1 =>
        	-- internal_gnt <= "010";
            gnt <= "010";
        when S2 =>
        	-- internal_gnt <= "100";
            gnt <= "100";
         when GRANT_RESOURCE =>
            gnt <= "000";
            -- internal_gnt <= "000";
        when UPDATE_RESOURCE =>
        	internal_gnt <= "000";
            gnt <= "000";
    end case; 
  end process;
    n0_out <= N0;
    n1_out <= N1;
    n2_out <= N2;
end rtl;
