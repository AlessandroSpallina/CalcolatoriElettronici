-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;


entity TESTONE is
end TESTONE;

architecture beh of TESTONE is
component sedici_bit is
	port ( 
	din : in std_logic_vector(15 downto 0);	
	start, clk : in std_logic;
	res : out std_logic_vector(15 downto 0);
	fine : out std_logic
	);
end component;

signal start, clk, fine : std_logic;
signal din, res : std_logic_vector(15 downto 0);

begin
	DUT: sedici_bit port map (din, start, clk, res, fine);
	
	process	
	begin
	clk <= '0';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
	end process;		  
	
	start <= '1' after 1 ns, '0' after 11 ns,
	'1' after 51 ns, '0' after 61 ns,
	'1' after 111 ns, '0' after 121 ns,
	'1' after 181 ns, '0' after 191 ns;
			
	
	din <= "00000000000000"&"00" after 11 ns, "0000000000000000" after 21 ns, -- NOT
	"00000000000000"&"01" after 61 ns, "0000000000000001" after 71 ns, "0000000000000010" after 81 ns, -- OR	  
	"00000000000000"&"10" after 121 ns, "0000000000000011" after 131 ns, "0000000000000101" after 141 ns, -- ADD
	"00000000000000"&"11" after 191 ns, "0000000000000110" after 201 ns, "0000000000011111" after 211 ns; -- MAC
	
	
	
	
	
	
	
end beh;
