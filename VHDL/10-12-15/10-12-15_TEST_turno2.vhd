-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity testina is
end entity;		 

architecture beh of testina is
component mezzanotte is
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
	DUT: mezzanotte port map (din, start, clk, dout, fine);
	
	process
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
	end process;
	
	start <= '1' after 1 ns, '0' after 11 ns,
	'1' after 56 ns, '0' after 66 ns,
	'1' after 106 ns, '0' after 116 ns,
	'1' after 166 ns, '0' after 176 ns;
	
	din <= conv_std_logic_vector (0, 16) after 11 ns, conv_std_logic_vector (5, 16) after 21 ns, conv_std_logic_vector(7, 16) after 31 ns, -- OP "00" aka AND
	conv_std_logic_vector(1, 16) after 66 ns, conv_std_logic_vector(1, 16) after 76 ns, -- OP "01" aka ADR	   
	conv_std_logic_vector(2, 16) after 116 ns, conv_std_logic_vector(7, 16) after 126 ns, conv_std_logic_vector(3, 16) after 136 ns, -- OP "10" aka ADD
	conv_std_logic_vector(3, 16) after 176 ns, conv_std_logic_vector(0, 16) after 186 ns, conv_std_logic_vector(0, 16) after 196 ns; -- OP "11" aka MIN

end beh;
