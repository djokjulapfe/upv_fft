library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity complex_mult is
	port (
		clk  : in  std_logic;
		a, b : in  complex;
		x    : out complex
	);
end entity complex_mult;

architecture behav of complex_mult is
begin
	execute : process (clk) is
	begin
		if rising_edge(clk) then
			x.r <= a.r * b.r - a.i * b.i;
			x.i <= a.r * b.i + a.i * b.r;
		end if;
	end process execute;
end architecture behav;
