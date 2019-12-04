library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

-----------------------------------------------------------

entity complex_mult_tb is

end entity complex_mult_tb;

-----------------------------------------------------------

architecture testbench of complex_mult_tb is

	-- Testbench DUT generics


	-- Testbench DUT ports
	signal clk  : std_logic;
	signal a, b : complex;
	signal x    : complex;

	-- Other constants
	constant clk_period : time := 10 ns; -- NS

begin
	-----------------------------------------------------------
	-- Clocks
	-----------------------------------------------------------
	clk_gen : process
	begin
		clk <= '1';
		wait for clk_period / 2;
		clk <= '0';
		wait for clk_period / 2;
	end process CLK_GEN;

	-----------------------------------------------------------
	-- Testbench Stimulus
	-----------------------------------------------------------

	main : process
	begin
		a <= (r => 3, i => -4);
		b <= (r => -2, i => 3);
		wait;
	end process main;

	-----------------------------------------------------------
	-- Entity Under Test
	-----------------------------------------------------------
	DUT : entity work.complex_mult
		port map (
			clk => clk,
			a   => a,
			b   => b,
			x   => x
		);

end architecture testbench;
