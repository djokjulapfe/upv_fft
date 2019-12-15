library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity fftn_output_serializer_tb is
end entity fftn_output_serializer_tb;

architecture testbench of fftn_output_serializer_tb is

    constant n             : integer := 16;
    constant bits_per_data : integer := 8;

    signal clk        : std_logic;
    signal reset      : std_logic;
    signal fftn_out   : complex_vector(0 to n - 1);
    signal start      : std_logic;
    signal step       : std_logic;
    signal data       : std_logic_vector(bits_per_data - 1 downto 0);
    signal data_ready : std_logic;

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
        -- init
        reset <= '1';
        step  <= '0';
        start <= '0';
        for i in 0 to n - 1 loop
            fftn_out(i) <= pair2complex(i, 2 * i);
        end loop;

        wait for clk_period;

        reset <= '0';
        wait for clk_period * 5;
        start <= '1';
        wait for clk_period;
        start <= '0';
        wait for clk_period * 5;

        for i in 0 to 16 * 5 loop
            step <= '1';
            wait for clk_period;
            step <= '0';
            wait for clk_period * 5;
        end loop;

        wait;
    end process main;


    DUT : entity work.fftn_output_serializer
        generic map (
            n             => n,
            bits_per_data => bits_per_data
        )
        port map (
            clk        => clk,
            reset      => reset,
            fftn_out   => fftn_out,
            start      => start,
            step       => step,
            data       => data,
            data_ready => data_ready
        );

end architecture testbench;
