--------------------------------------------------------------------------------
-- Title       : Rerouter testbench
-- Project     : FFT
-- File        : rerouter_tb.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  6
-- Version     : 1.0
-- Description : Testbench for Rerouter 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity rerouter_tb is
end entity rerouter_tb;

architecture testbench of rerouter_tb is

    constant n : integer := 16;

    signal x : complex_vector(0 to n - 1);
    signal y : complex_vector(0 to n - 1);

begin

    main : process is
    begin
        for i in 0 to n - 1 loop
            x(i) <= pair2complex(i, 0);
        end loop;
        wait;
    end process main;

    DUT : entity work.rerouter
        generic map (
            n => n
        )
        port map (
            x => x,
            y => y
        );

end architecture testbench;