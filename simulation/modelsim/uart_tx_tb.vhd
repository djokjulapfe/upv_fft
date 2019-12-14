library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity uart_tx_tb is
end entity uart_tx_tb;

architecture testbench of uart_tx_tb is
    constant n : integer := 4;

	signal clk      : std_logic;
	signal reset    : std_logic;
	signal tx_in    : std_logic_vector(8 - 1 downto 0);
	signal tx_start : std_logic;
	signal tx_out   : std_logic;
	signal tx_done  : std_logic;    

    constant clk_period : time := 10 ns;

begin

    clk_gen : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_gen;

    main : process
    begin
    	reset <= '1';
    	tx_in <= "01000100";
    	tx_start <= '0';
    	wait for clk_period * 100;
    	reset <= '0';
		wait for clk_period * 500;
		tx_start <= '1';
		wait for clk_period * 100;
		tx_start <= '0';
      wait;
    end process main;

	DUT : entity work.uart_tx
		port map (
			clk      => clk,
			reset    => reset,
			tx_in    => tx_in,
			tx_start => tx_start,
			tx_out   => tx_out,
			tx_done  => tx_done
		);

end architecture testbench;