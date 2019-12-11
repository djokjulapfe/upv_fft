library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_tb is
end entity counter_tb;

architecture testbench of counter_tb is

	constant n : integer := 10;

	signal clk      : std_logic;
	signal reset    : std_logic;
	signal step     : std_logic;
	signal value    : integer range 0 to n;
	signal finished : std_logic;

	constant clk_period : time := 10 ns;

begin

	clk_gen : process is
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clk_gen;

	main : process is
	begin
		reset <= '1';
		wait for clk_period;
		reset <= '0';
		step  <= '1';
		wait for clk_period * 7;
		reset <= '1';
		wait for clk_period * 2;
		reset <= '0';
		wait for clk_period * 7;
		step <= '0';
		wait for clk_period * 7;
		step <= '1';
		wait for clk_period * 7;
		reset <= '1';
		wait for clk_period * 2;
		reset <= '0';
		wait;
	end process main;

	DUT : entity work.counter
		generic map (
			n => n
		)
		port map (
			clk      => clk,
			reset    => reset,
			step     => step,
			value    => value,
			finished => finished
		);

end architecture testbench;
