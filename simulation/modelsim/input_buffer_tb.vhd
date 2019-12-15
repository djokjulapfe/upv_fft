library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity input_buffer_tb is
end entity input_buffer_tb;


architecture testbench of input_buffer_tb is

    signal clk           : std_logic;
    signal reset         : std_logic;
    signal input_ready   : std_logic;
    signal word_in       : complex;
    signal buffered_data : complex_vector(0 to word_size - 1);
    signal ready         : std_logic;

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

        reset       <= '1';
        input_ready <= '0';
        word_in     <= pair2Complex(1, 0);
        wait for clk_period;
        reset <= '0';

        wait for 10 * clk_period;

        for i in 0 to 15 loop
            input_ready <= '1';
            wait for clk_period;
            input_ready <= '0';
            wait for 10 * clk_period;
        end loop;

        wait;
    end process main;


    DUT : entity work.input_buffer
        generic map (
            n => 16
        )
        port map (
            clk           => clk,
            reset         => reset,
            input_ready   => input_ready,
            word_in       => word_in,
            buffered_data => buffered_data,
            ready         => ready
        );

end architecture testbench;