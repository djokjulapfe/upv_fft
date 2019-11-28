library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux is
	port (
		a, b, c, d : in  std_logic;
		s0, s1     : in  std_logic;
		x          : out std_logic
	);
end entity mux;

architecture behav of mux is
begin
	x <=
		a when s0 = '0' and s1 = '0' else
		b when s0 = '0' and s1 = '1' else
		c when s0 = '1' and s1 = '0' else
		d;
end architecture behav;