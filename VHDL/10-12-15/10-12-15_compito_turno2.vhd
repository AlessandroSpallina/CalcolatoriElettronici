-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity mezzanotte is
	port (
	din : in std_logic_vector(15 downto 0);
	start, clk : in std_logic;
	dout : out std_logic_vector(15 downto 0);
	fine : out std_logic
	);
end entity;

architecture beh of mezzanotte is
type stati is (idle, getOP, getA, getB, exe1, exe2, exe3);
signal st : stati;
signal A, B, REG : std_logic_vector(15 downto 0);
signal OP : std_logic_vector(1 downto 0);
signal enOP, enA, enB, enEXE1, enEXE2, enEXE3 : std_logic;	   
signal counter : integer range 2 downto 0;

function next_state (st : stati; start : std_logic; op : std_logic_vector(1 downto 0); counter : integer range 2 downto 0)
return stati is
variable nxt : stati;
begin	  
	case st is
		when idle =>
		if start = '1' then
			nxt := getOp;
		else
			nxt :=idle;
		end if;
		
		when getOP =>
		nxt := getA;
		
		when getA =>
		if op = "01" then
			nxt := exe3;
		else
			nxt := getB;
		end if;
			
		when getB =>
		case op is
			when "00" =>
			nxt := exe1;
			when "10" =>
			nxt := exe3;
			when others => -- "11"
			nxt := exe2;
		end case;		
		
		when exe1 =>
		nxt := idle;
		
		when exe2 =>
		if counter < 1 then
			nxt := exe2;
		else
			nxt := idle;
		end if;
		
		when exe3 =>
		if counter < 2 then
			nxt := exe3;
		else
			nxt := idle;
		end if;
	end case;
return nxt;
end next_state;

begin

	-- CU
	process (clk)
	begin
		if clk'event and clk = '0' then
			st <= next_state(st, start, op, counter);
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
	variable tmp : std_logic_vector(15 downto 0);
	begin
	if enOP = '1' then
		OP <= din(1 downto 0);
		counter <= 0;
	end if;
	
	if enA = '1' then
		A <= din;
	end if;
	
	if enB = '1' then
		B <= din;
	end if;
	
	if enEXE1 = '1' then
		REG <= A and B;
		dout <= REG;
	end if;	 
	
	if enEXE2 = '1' then
		if counter = 1 then
			if A < B then
				tmp := A;
			else 
				tmp := B;
			end if;
			if tmp < REG then
				REG <= tmp;	
				dout <= REG;
			else
				dout <= REG;
			end if;
		else
			counter <= counter + 1;
		end if;
	end if;	 
	
	if enEXE3 = '1' then
		if counter = 2 then
			if op = "01" then
				tmp := A + REG;	
				REG <= tmp;
				dout <= REG;
			else -- OP "10"	
				REG <= A + B;
				dout <= REG;
			end if;
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
end architecture;