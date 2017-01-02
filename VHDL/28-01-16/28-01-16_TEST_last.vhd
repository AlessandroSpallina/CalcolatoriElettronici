-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;				  
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity TESTAMARIANGELA is
end TESTAMARIANGELA;

architecture beh of TESTAMARIANGELA is
component mariangela is
	port (
	din : in std_logic_vector(15 downto 0);
	start, clk : in std_logic;
	dout : out std_logic_vector(15 downto 0);
	fine : out std_logic
	);
end component;

signal din, dout : std_logic_vector(15 downto 0);
signal start, clk, fine : std_logic;

begin
	DUT : mariangela port map (din, start, clk, dout, fine);
	
	process
	begin
	clk <= '0';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
	end process;

	start <= '1' after 1 ns, '0' after 11 ns,
	'1' after 46 ns, '0' after 56 ns,
	'1' after 86 ns, '0' after 96 ns,
	'1' after 136 ns, '0' after 146 ns;
	
	din <= conv_std_logic_vector(0, 16) after 11 ns, conv_std_logic_vector(5, 16) after 21 ns, -- SET
	conv_std_logic_vector(4, 16) after 56 ns, conv_std_logic_vector(4, 16) after 66 ns, -- SET
	conv_std_logic_vector(1, 16) after 96 ns, conv_std_logic_vector(2, 16) after 106 ns, conv_std_logic_vector(7, 16) after 116 ns, -- AND (A,B)
	conv_std_logic_vector(2, 16) after 146 ns, conv_std_logic_vector(7, 16) after 156 ns, conv_std_logic_vector(2, 16) after 166 ns; -- ADD
	-- mi secca troppo provare il resto :D
	



end beh;