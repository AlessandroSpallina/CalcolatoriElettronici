-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;				
use ieee.std_logic_arith.all;	   
use ieee.std_logic_unsigned.all;


entity gianni is
	port (
	op : in std_logic_vector(1 downto 0);
	din : in std_logic_vector(31 downto 0);
	nw, clk : in std_logic;
	res : out std_logic_vector(31 downto 0);
	ready : out std_logic
	);
end gianni;				  



architecture beh of gianni is
	type stati is (idle, getOPD0, getD1, exe1, exe2, exe5);
	signal st : stati;											 
	-- signal OP : std_logic_vector(1 downto 0); Non dichiaro nessun signal poichè l'ingresso nella porta dedicata è fisso
	signal D0, D1 : std_logic_vector(31 downto 0);
	signal enOPD0, enD1, enEXE1, enEXE2, enEXE5 : std_logic;	  
	signal counter : integer range 4 downto 0;


	function next_state (st : stati; nw : std_logic; op : std_logic_vector(1 downto 0); counter : integer range 4 downto 0) return stati is
	variable nxt : stati;
	begin				 
	case st is
		when idle =>
		if nw = '1' then nxt := getOPD0;
		else nxt := idle;
		end if;
		
		when getOPD0 =>
		nxt := getD1;
		
		when getD1 =>
		case op is
			when "00" =>
			nxt := exe2;
			when "01" | "10" =>
			nxt := exe1;
			when others =>
			nxt := exe5;
		end case;  
		
		when exe1 =>
		nxt := idle;
		
		when exe2 =>
		if counter = 1 then nxt := idle;
		else nxt := exe2;
		end if;
		
		when exe5 =>
		if counter = 4 then nxt := idle;
		else nxt := exe5;
		end if;
	end case;  
	return nxt;
	end next_state;
	
	
	
begin 
	
	-- CU
	process (clk) is
	begin  
		if clk'event and clk = '0' then 
		st <= next_state (st, nw, op, counter);	
		end if;
	end process;
	
	enOPD0 <= '1' when st = getOPD0 else '0';
	enD1 <= '1' when st = getD1 else '0';
	enEXE1 <= '1' when st = exe1 else '0';
	enEXE2 <= '1' when st = exe2 else '0';
	enEXE5 <= '1' when st = exe5 else '0';

	-- DATAPAH
	process (clk) is  
	begin
		if clk'event and clk = '0' then
			if enOPD0 = '1' then
				D0 <= din;
				counter <= 0;
			end if;
			
			
			if enD1 = '1' then
				D1 <= din;
			end if;
			
			
			if enEXE1 = '1' then
				if op = "01" then -- OR code "01"
					res <= D0 or D1;
				
				else -- SLT code "10"
					if D0<D1 then res <= "0000000000000000000000000000000"&'1';
					else res <= "0000000000000000000000000000000"&'0';
					end if;			   
				end if;	
			end if;
			
			
			if enEXE2 = '1' then -- ADD code "00"
				if counter < 1 then counter <= counter + 1;
				else res <= D0 + D1;
				end if;
			end if;	 
			
			if enEXE5 = '1' then -- MUL code "11"
				if counter < 4 then counter <= counter + 1;
				else res <=	D0(15 downto 0) * D1(15 downto 0);
				end if;
			end if;
			
			if enEXE1 = '1' or (enEXE2 = '1' and counter=1) or (enEXE5 = '1' and counter=4) then 
				ready <= '1';
			else ready <= '0';
			end if;
		end if;
	end process;
end beh;
