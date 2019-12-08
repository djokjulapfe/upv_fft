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
    signal uart_in  : std_logic;
    signal uart_out : std_logic;
    signal tmp      : complex_vector(0 to 15);

    constant clk_period : time := 10 ns;

begin
    clk_gen : process
    begin
        clk <= '1';
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process clk_gen;

    -- main testing
    main : process
    begin
        for i in 0 to 7 loop
            --tmp(i) <= pair2complex(i, 0);
            tmp(2 * i) <= pair2complex(0, 0);
            tmp(2 * i + 1) <= pair2complex(2 * ((i + 1) mod 2) - 1, 0);
        end loop;
        wait;
    end process main;

    DUT : entity work.upv_fft
        port map (
            clk      => clk,
            uart_in  => uart_in,
            uart_out => uart_out,
            tmp      => tmp
        );

end architecture testbench;