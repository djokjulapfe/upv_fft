--------------------------------------------------------------------------------
-- Title       : upw_fft testbench
-- Project     : FFT
-- File        : types.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  4
-- Version     : 1.0
-- Description : Testbench for the upw_fft
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity upv_fft_tb is
end entity upv_fft_tb;

architecture testbench of upv_fft_tb is

    signal clk             : std_logic;
    signal reset           : std_logic;
    signal uart_in         : std_logic;
    signal uart_out        : std_logic;
    signal tmp             : complex;
    signal fake_uart_ready : std_logic;
    signal fake_uart_step  : std_logic;

    constant clk_period : time := 10 ns;

begin
    clk_gen : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_gen;

    -- main testing
    main : process
    begin
        reset           <= '1';
        fake_uart_ready <= '0';
        fake_uart_step  <= '0';
        wait for clk_period;
        reset <= '0';
        wait for clk_period * 5;

        for i in 0 to 15 loop
            tmp             <= pair2complex(i, 2 * i);
            fake_uart_ready <= '1';
            wait for clk_period;
            fake_uart_ready <= '0';
            wait for clk_period * 100;
        end loop;

        for i in 0 to 4 * 16 - 1 loop
            fake_uart_step <= '1';
            wait for clk_period;
            fake_uart_step <= '0';
            wait for clk_period * 50;
        end loop;

        wait;
    end process main;

    DUT : entity work.upv_fft
        port map (
            clk             => clk,
            reset           => reset,
            uart_in         => uart_in,
            uart_out        => uart_out,
            tmp             => tmp,
            fake_uart_ready => fake_uart_ready,
            fake_uart_step  => fake_uart_step
        );

end architecture testbench;