-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity TESTANTONELLA is
end entity;

architecture beh of TESTANTONELLA is
component antonella is
	port (
	op : in std_logic_vector(1 downto 0);
	din : in std_logic_vector(15 downto 0);
	start, clk : in std_logic;
	res : out std_logic_vector(15 downto 0);
	fine : out std_logic
	);	
end component;

signal op : std_logic_vector(1 downto 0);
signal din, res : std_logic_vector(15 downto 0);
signal start, clk, fine : std_logic;

begin
	
	DUT: antonella port map (op, din, start, clk, res, fine);
	
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
	'1' after 131 ns, '0' after 141 ns;
	
	op <= "00" after 11 ns, -- OP "00" aka LD->R0
	"01" after 56 ns, -- OP "01" aka LD->R1
	"10" after 96 ns, -- OP "10" aka AND
	"11" after 131 ns; -- OP "11" aka ADD
	
	din <= conv_std_logic_vector(5, 16) after 11 ns,
	conv_std_logic_vector(6, 16) after 56 ns;
	
end beh;