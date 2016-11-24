-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity TESTADIFFICILE is
end TESTADIFFICILE;

architecture beh of TESTADIFFICILE is
component difficile is
	port (		  
	din : in std_logic_vector(15 downto 0);
	start, clk : in std_logic;
	res : out std_logic_vector(15 downto 0);
	fine : out std_logic
	);
end component;

signal din, res : std_logic_vector(15 downto 0);
signal start, clk, fine : std_logic;
begin								
	
	DUT: difficile port map (din, start, clk, res, fine);
	
	process 
	begin
	clk <= '0';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
	end process;
	
	start <= '1' after 1 ns, '0' after 11 ns;
	
	din	<= "0000000000000"&"100" after 11 ns, conv_std_logic_vector(7, 16) after 21 ns;	
	-- + altri test, mi secca :D

end beh;