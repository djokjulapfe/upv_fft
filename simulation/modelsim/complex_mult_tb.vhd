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
    signal a, b : complex;
    signal x    : complex;

    -- Other constants
    constant clk_period : time := 10 ns; -- NS

begin

    -----------------------------------------------------------
    -- Testbench Stimulus
    -----------------------------------------------------------

    main : process
    begin
        a <= (r => 3, i => -4);
        b <= (r => -2, i => 3);
        wait for clk_period;
        a <= (r => 1, i => 3);
        b <= (r => 2, i => 4);
        wait;
    end process main;

    -----------------------------------------------------------
    -- Entity Under Test
    -----------------------------------------------------------
    DUT : entity work.complex_mult
        port map (
            a => a,
            b => b,
            x => x
        );

end architecture testbench;
