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

    signal clk      : std_logic;
    signal reset    : std_logic;
    signal uart_in  : std_logic;
    signal uart_out : std_logic;

    constant clk_period : time := 10 ns;
    constant bit_period : time := 2604 * clk_period;

    constant byte_count : integer := 16 * 2;

    constant data : std_logic_vector(0 to byte_count * 8 - 1) :=
        "00000000" &
        "00000001" &
        "11111111" &
        "11111111" &
        "00000000" &
        "00000001" &
        "11111111" &
        "11111111" &
        "00000000" &
        "00000001" &
        "11111111" &
        "11111111" &
        "00000000" &
        "00000001" &
        "11111111" &
        "11111111" &
        "00000000" &
        "00000001" &
        "11111111" &
        "11111111" &
        "00000000" &
        "00000001" &
        "11111111" &
        "11111111" &
        "00000000" &
        "00000001" &
        "11111111" &
        "11111111" &
        "00000000" &
        "00000001" &
        "11111111" &
        "11111111";

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
        reset   <= '1';
        uart_in <= '1';
        wait for clk_period;
        reset <= '0';
        wait for bit_period;

        for byte_index in 0 to byte_count - 1 loop
            uart_in <= '0';
            wait for bit_period;
            for bit_index in 0 to 7 loop
                uart_in <= data(byte_index * 8 + bit_index);
                wait for bit_period;
            end loop;
            uart_in <= '1';
            wait for bit_period;
            wait for 2 * bit_period;
        end loop;

        wait;
    end process main;

    DUT : entity work.upv_fft
        port map (
            clk      => clk,
            reset    => reset,
            uart_in  => uart_in,
            uart_out => uart_out
        );

end architecture testbench;