-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;	
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sedici_bit is
	port ( 
	din : in std_logic_vector(15 downto 0);	
	start, clk : in std_logic;
	res : out std_logic_vector(15 downto 0);
	fine : out std_logic
	);
end sedici_bit;


architecture beh of sedici_bit is
type stati is (idle, getOP, getD0, getD1, exe1, exe2, exe4);
signal st : stati;
signal OP : std_logic_vector(1 downto 0);
signal counter : integer range 3 downto 0;
signal D0, D1 : std_logic_vector(15 downto 0);

signal enOP, enD0, enD1, enEXE1, enEXE2, enexe4 : std_logic;


function next_state (st : stati; start : std_logic; op : std_logic_vector(1 downto 0); counter : integer range 3 downto 0)
return stati is

variable nxt : stati;

begin
	case st is
		when idle => 
		if start = '1' then
			nxt := getOP;
		else nxt := idle; 
		end if;
		
		when getOP =>
		nxt := getD0;
		
		when getD0 =>
		if op = "00" then
			nxt := exe1;
		else
			nxt := getD1;
		end if;
		
		when getD1 =>
		case op is
			when "01" =>
			nxt := exe1;
			when "10" =>
			nxt := exe2;
			when "11" =>
			nxt := exe4;
			when others =>
			nxt := idle;
		end case;
		
		when exe1 =>
		nxt := idle;
		
		when exe2 =>
		if counter = 1 then
			nxt := idle;
		else			
			nxt := exe2;
		end if;
			
		when exe4 =>
		if counter = 3 then
			nxt := idle;
		else
			nxt := exe4;
		end if;
		
		when others => nxt := idle;		
		
	end case;
	
	return nxt;
	

end next_state;

begin
	
	-- cu
	process (clk)
	begin
		if clk'event and clk = '0' then
			st <= next_state(st, start, op, counter);
			end if;
	end process;									 
	
	
	enOP <= '1' when st = getOP else '0';
	enD0 <= '1' when st = getD0 else '0';
	enD1 <= '1' when st = getD1 else '0';
	enEXE1 <= '1' when st = exe1 else '0';
	enEXE2 <= '1' when st = exe2 else '0';
	enEXE4 <= '1' when st = exe4 else '0';
		
	-- datapath
	process (clk)
	begin
		if clk'event and clk = '0' then
			if enOP = '1' then
				op <= din(1 downto 0);
				counter <= 0;
			end if;
			
			if enD0 = '1' then
				 D0 <= din;
			end if;
			
			if enD1 = '1' then
				 D1 <= din;
			end if; 
			
			if enEXE1 = '1' then
				if op = "00" then  -- NOT
				 	res <= not D0;
				else 
					res <= D0 or D1; -- OR
				end if;
			end if;
			
			if enEXE2 = '1' then -- ADD
				if counter = 1 then	   
					res <= D0 + D1;
				else counter <= counter + 1;
				end if;
			end if;	 
			
			if enEXE4 = '1' then -- MAC
			 	if counter = 3 then
				res <= D0+(D1(15 downto 8)*D1(7 downto 0));
				else counter <= counter + 1;
				end if;
			end if;
			
			if enEXE1 = '1' or (enEXE2 = '1' and counter = 1) or (enEXE4 = '1' and counter = 3) then
				fine <= '1';
			else
				fine <= '0';
			end if;
		end if;
	end process;
end beh;
