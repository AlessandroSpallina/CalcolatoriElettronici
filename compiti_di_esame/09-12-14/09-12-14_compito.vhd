-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity antonella is
	port (
	op : in std_logic_vector(1 downto 0);
	din : in std_logic_vector(15 downto 0);
	start, clk : in std_logic;
	res : out std_logic_vector(15 downto 0);
	fine : out std_logic
	);
end antonella;

architecture beh of antonella is
type stati is (idle, getOP, codOP, exeLD, exeAND, exeADD);
type memory is array (0 to 1) of std_logic_vector(15 downto 0);

signal st : stati;			
signal REG : memory;
signal OPE : std_logic_vector(1 downto 0); -- sto salvando su un registro OP poichè assumo che in ingresso il valore di OP sia presente solo per un ciclo di clock
signal enOP, enLD, enAND, enADD : std_logic;  
-- signal enCOD : std_logic; non serve a niente, vedi segnali di controllo sotto :D
signal counter : integer range 2 downto 0;



	function next_state (st: stati; start : std_logic; ope : std_logic_vector(1 downto 0); counter : integer range 2 downto 0) 
	return stati is
	variable nxt : stati;
	begin
	
	case st is
		when idle =>
		if start = '1' then nxt := getOP;
		else nxt := idle;
		end if;
		
		when getOP =>
		nxt := codOP;
		
		when codOP =>
		case ope is
			when "00" | "01" => nxt := exeLD;
			when "10" => nxt := exeAND;
			when others => nxt := exeADD;
		end case;
		
		when exeLD =>
		nxt := idle;
		
		when exeAND =>
		if counter < 1 then nxt := exeAND;
		else nxt := idle;
		end if;
		
		when exeADD =>
		if counter < 2 then nxt := exeADD;
		else nxt := idle;
		end if;
	end case;
	return nxt;
	end next_state;

begin
	
	-- CU
	process (clk) is
	begin
		if clk'event and clk = '0' then 
			st <= next_state(st, start, ope, counter);
		end if;
	end process;
	
	-- State Control Bits
	enOP <= '1' when st = getOP else '0';
	-- enCOD <= '1' when st = codOP else '0'; non serve a niente, poichè la decodifica la faccio nella funct next_state
	enLD <= '1' when st = exeLD else '0';
	enAND <= '1' when st = exeAND else '0';
	enADD <= '1' when st = exeADD else '0';
		
	-- DATAPATH
	process (clk) is
	begin
		if enOP = '1' then
			ope <= op; 
			counter <= 0;
		end if;
		
		if enLD = '1' then
			REG(conv_integer(ope)) <= din;
		end if;
		
		if enAND = '1' then
			if counter = 1 then 
				REG(1) <= REG(0) and REG(1);
			else
				counter <= counter + 1;
			end if;
		end if;	
		
		
		if enADD = '1' then
			if counter = 2 then
				res <= REG(0) + REG(1);
			else
				counter <= counter +1;
			end if;
		end if;
		
		if enLD = '1' or (enAND = '1' and counter = 1) or (enADD = '1' and counter = 2) then
			fine <= '1';
		else 
			fine <= '0';
		end if;
	end process;
end beh;