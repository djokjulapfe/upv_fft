--------------------------------------------------------------------------------
-- Title       : FFTn testbench
-- Project     : FFT
-- File        : types.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  5
-- Version     : 1.0
-- Description : Testbench for rerouter
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity fftn_tb is
end entity fftn_tb;

architecture testbench of fftn_tb is
    constant n : integer := 4;

    signal clk     : std_logic;
    signal fft_in  : complex_vector(0 to n - 1);
    signal fft_out : complex_vector(0 to n - 1);

    constant clk_period : time := 10 ns;

begin

    clk_gen : process
    begin
        clk <= '1';
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process clk_gen;

    main : process
    begin
        fft_in(0) <= pair2complex(1, 0);
        fft_in(1) <= pair2complex(3, 0);
        fft_in(2) <= pair2complex(2, 0);
        fft_in(3) <= pair2complex(4, 0);
        wait;
    end process main;

    DUT : entity work.fftn
        generic map (
            n     => n,
            n_max => 16
        )
        port map (
            clk     => clk,
            fft_in  => fft_in,
            fft_out => fft_out
        );

end architecture testbench;