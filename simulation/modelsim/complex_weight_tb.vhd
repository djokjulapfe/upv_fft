--------------------------------------------------------------------------------
-- Title       : Complex weight testbench
-- Project     : FFT
-- File        : types.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  5
-- Version     : 1.0
-- Description : Testbench for Complex weight
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity complex_weight_tb is
end entity complex_weight_tb;

architecture testbench of complex_weight_tb is

    signal x1_in, x2_in   : complex;
    signal weight_choice  : integer range 0 to 7;
    signal y1_out, y2_out : complex;

    constant clk_period : time := 10 ns;

begin

    main : process is
    begin
        x1_in <= pair2complex(100, 0);
        x2_in <= pair2complex(256, 256);

        weight_choice <= 0;
        wait for clk_period;
        weight_choice <= 1;
        wait for clk_period;
        weight_choice <= 2;
        wait for clk_period;
        weight_choice <= 3;
        wait for clk_period;
        weight_choice <= 4;
        wait for clk_period;
        weight_choice <= 5;
        wait for clk_period;
        weight_choice <= 6;
        wait for clk_period;
        weight_choice <= 7;
        wait;
    end process main;
    
    DUT1 : entity work.complex_weight
        port map (
            x_in          => x1_in,
            weight_choice => weight_choice,
            y_out         => y1_out
        );
    DUT2 : entity work.complex_weight
        port map (
            x_in          => x2_in,
            weight_choice => weight_choice,
            y_out         => y2_out
        );

end architecture testbench;