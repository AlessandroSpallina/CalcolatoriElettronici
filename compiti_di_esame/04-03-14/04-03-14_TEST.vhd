-- Copyright (C) 2016 by Spallina Ind.

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;

entity TEST is
end TEST;


architecture BEH of TEST is
component gianni is
	port (
	op : in std_logic_vector(1 downto 0);
	din : in std_logic_vector(31 downto 0);
	nw, clk : in std_logic;
	res : out std_logic_vector(31 downto 0);
	ready : out std_logic
	);
end component;

signal op : std_logic_vector(1 downto 0);
signal din : std_logic_vector(31 downto 0);
signal nw, clk : std_logic;
signal res : std_logic_vector(31 downto 0);
signal ready : std_logic;

begin
	
	DUT: gianni port map (op, din, nw, clk, res, ready);
	
	process
	begin
	clk <= '0';
	wait for 5 ns;
	clk <= '1';
	wait for 5 ns;
	end process;

	nw <= '1' after 1 ns, '0' after 11 ns,
	'1' after 51 ns, '0' after 61 ns,
	'1' after 101 ns, '0' after 111 ns,
	'1' after 161 ns, '0' after 171 ns;
	
	op <= "01" after 11 ns, -- OP "01" aka OR
	"10" after 61 ns, -- OP "10" aka SLT
	"00" after 111 ns, -- OP "00" aka ADD
	"11" after 171 ns; -- OP "11" aka MUL
	
	
	din <= conv_std_logic_vector(5, 32) after 11 ns, conv_std_logic_vector(3, 32) after 21 ns,
	conv_std_logic_vector(2, 32) after 61 ns, conv_std_logic_vector(7, 32) after 71 ns,
	conv_std_logic_vector(4, 32) after 111 ns, conv_std_logic_vector(9, 32) after 121 ns,
	conv_std_logic_vector(1, 32) after 171 ns, conv_std_logic_vector(10, 32) after 181 ns;
	


end BEH;
