-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;							
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mariangela is
	port (
	din : in std_logic_vector(15 downto 0);
	start, clk : in std_logic;
	dout : out std_logic_vector(15 downto 0);
	fine : out std_logic
	);
end mariangela;		

architecture beh of mariangela is
type stati is (idle, getOP, getA, getB, exe1, exe2, exe3);
signal st : stati;
signal REG, A, B : std_logic_vector(15 downto 0);	
signal OP : std_logic_vector(2 downto 0);
signal counter : integer range 2 downto 0;

function next_state (st : stati; start : std_logic; op : std_logic_vector(2 downto 0); counter : integer range 2 downto 0; reg : std_logic_vector(15 downto 0)) 
return stati is		   
variable nxt : stati;																									
begin

	case st is
	
		when idle =>
			if start = '1' then nxt := getOP;
			else nxt := idle;
			end if;
		
		when getOP =>
			nxt := getA;
	
		when getA =>
		case op is
			when "101" | "000" | "100" =>
				nxt := exe1;
			
			when "110" =>
				if conv_integer(REG) = 0 then nxt := exe1;
				else nxt := exe3;
				end if;
				
			when others =>
				nxt := getB;
		end case;			
		
		when getB =>	
		case op is
			when "001" =>
				nxt := exe1;
			when "010" =>
				nxt := exe3;
			when others =>
				nxt := exe2;
		end case;			
		
		when exe1 =>
			nxt := idle;
		
		when exe2 =>
			if counter < 1 then nxt := exe2;
			else nxt := idle;
			end if;
			
		when exe3 =>
			if counter < 2 then nxt := exe3;
			else nxt := idle;
			end if;
	end case;
return nxt;
end next_state;

-- siccome non ho niente da fare nella vita, mi scrivo sta procedura tanto per D:
procedure return_result (signal REG : inout std_logic_vector(15 downto 0); value_to_return : in std_logic_vector(15 downto 0); signal dout : out std_logic_vector(15 downto 0)) is
begin												
	REG <= value_to_return;
	dout <= REG;
end return_result;	

-- anche questa funzione è fatta perchè non ho che fare :D
function min (A : std_logic_vector(15 downto 0); B : std_logic_vector(15 downto 0); REG : std_logic_vector(15 downto 0))
return std_logic_vector is
variable tmp : std_logic_vector(15 downto 0);
begin
	if (A < B) then 
		tmp := A;
	else
		tmp := B;
	end if;
	if(tmp > REG) then
		tmp	:= REG;
	end if;
return tmp;
end min;

signal enOP, enA, enB, enEXE1, enEXE2, enEXE3 : std_logic;

begin													  
	
	-- CU
	process (clk)
	begin
		if clk'event and clk = '0' then 
			st <= next_state (st, start, op, counter, reg);
		end if;		
	end process;
	
	enOP <= '1' when st = getOP else '0';
	enA <= '1' when st = getA else '0';
	enB <= '1' when st = getB else '0';
	enEXE1 <= '1' when st = exe1 else '0';
	enEXE2 <= '1' when st = exe2 else '0';
	enEXE3 <= '1' when st = exe3 else '0';

	-- DATAPATH
	process (clk)
	begin
		if enOP = '1' then
			op <= din(2 downto 0); 
			counter <= 0;
		end if;
		
		if enA = '1' then
			A <= din;
		end if;
		
		if enB = '1' then
			B <= din;
		end if;
		
		if enEXE1 = '1' then
			case op is
				when "100" | "000" => -- SET
				REG <= A;
				
				when "001" => -- AND (A,B)
				return_result(REG, (A and B), dout); 
				
				when "101" => -- AND (A,REG)
				return_result(REG, (A and REG), dout);
				
				when others => -- "110" ADD => SET
				REG <= A;
			end case;
		end if;		 
		
		if enEXE2 = '1' then -- MIN
			if counter = 1 then 
				return_result(REG, min(A,B,REG), dout);
			else
				counter <= counter + 1;
			end if;
		end if;									   
		
		if enEXE3 = '1' then
			if counter = 2 then
				case op is
					when "010" => -- ADD (A,B)
					return_result(REG, A+B, dout);
				
					when others => -- "110" ADD (A,REG)
					return_result(REG, A+REG, dout);
				end case;
			else 
				counter <= counter + 1;
			end if;
		end if;
			
		if enEXE1 = '1' or (enEXE2 = '1' and counter = 1) or (enEXE3 = '1' and counter = 2) then
			fine <= '1';
		else
			fine <= '0';
		end if;	
	end process;	
end beh;
