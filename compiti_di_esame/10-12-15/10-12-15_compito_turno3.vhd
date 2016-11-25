-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity difficile is
	port (		  
	din : in std_logic_vector(15 downto 0);
	start, clk : in std_logic;
	res : out std_logic_vector(15 downto 0);
	fine : out std_logic
	);
end difficile;			 

architecture beh of difficile is
type stati is (idle, getOP, getA, exe1, exe2, exe4);
type memory is array (0 to 1) of std_logic_vector(15 downto 0);
signal st : stati;
signal REGS : memory;			   
signal OP : std_logic_vector(2 downto 0);
signal A : std_logic_vector(15 downto 0); 
signal counter : integer range 3 downto 0;		 
signal enOP, enA, enEXE1, enEXE2, enEXE4 : std_logic;

function next_state (st : stati; start : std_logic; op : std_logic_vector(2 downto 0); din : std_logic_vector(15 downto 0); counter : integer range 3 downto 0)
return stati is
variable nxt : stati;
begin	   
	case st is 
		when idle =>
		if start = '1' then
			nxt := getOP;
		else
			nxt := idle;
		end if;					  			  
		
		when getOP =>
		if din(1 downto 0) = "00" then
			nxt := exe1;
		else
			nxt := getA;
		end if;
		
		when getA =>
		case op(1 downto 0) is
			when "01" =>
			nxt := exe1;
			when "10" =>
			nxt := exe2;
			when others => -- "11"
			nxt := exe4;
		end case;
		
		when exe1 =>
		nxt := idle;
		
		when exe2 =>
		if counter < 1 then 
			nxt := exe2;
		else 
			nxt := idle;
		end if;
		
		when exe4 =>
		if counter < 3 then 
			nxt := exe4;
		else 
			nxt := idle;
		end if;
	end case;
return nxt;
end next_state;

begin

	process (clk)
	begin
		if clk'event and clk = '0' then
			st <= next_state(st,start,op,din,counter);
		end if;
	end process;
	
	enOP <= '1' when st = getOP else '0';  
	enA <= '1' when st = getA else '0';
	enEXE1 <= '1' when st = exe1 else '0';
	enEXE2 <= '1' when st = exe2 else '0';
	enEXE4 <= '1' when st = exe4 else '0';
		
	process (clk)
	begin
		if enOP = '1' then
			op <= din (2 downto 0);	 
			counter <= 0;
		end if;
		
		if enA = '1' then
			A <= din;
		end if;
		
		if enEXE1 = '1' then
			if op(1 downto 0) = "00" then  
				REGS(conv_integer(op(2))) <= din;	
			else -- "01"
				REGS(conv_integer(op(2))) <= A or REGS(0);
				res <= REGS(conv_integer(op(2)));
			end if;
		end if;	 
		
		if enEXE2 = '1' then
			if counter = 1 then
				REGS(conv_integer(op(2))) <= A + REGS(1);
				res <= REGS(conv_integer(op(2)));
			else 
				counter <= counter + 1;
			end if;
		end if;	 
		
		if enEXE4 = '1' then
			if counter = 3 then
				REGS(conv_integer(op(2))) <= A+REGS(0)+REGS(1);
				res <= REGS(conv_integer(op(2)));
			else							 
				counter <= counter + 1;
			end if;
		end if;
		
		if enEXE1 = '1' or (enEXE2 = '1' and counter = 1) or (enEXE4 = '1' and counter = 3) then
			fine <= '1';
		else
			fine <= '0';
		end if;
	end process;					  
end beh;
