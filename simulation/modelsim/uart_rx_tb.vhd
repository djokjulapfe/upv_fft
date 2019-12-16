library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity uart_rx_tb is
end entity uart_rx_tb;

architecture testbench of uart_rx_tb is

    constant n               : integer := 16;
    constant bits_per_data   : integer := 8;
    constant freq            : integer := 50000000;
    constant baud_rate       : integer := 19200;
    constant samples_per_bit : integer := 162;
    constant bits_per_chunk  : integer := 8;

    signal clk    : std_logic;
    signal reset  : std_logic;
    signal pin_in : std_logic;
    signal output : complex;
    signal done   : std_logic;

    constant clk_period : time := 10 ns;
    constant bit_period : time := 2604 * clk_period;

    constant byte_count : integer := 4;

    constant data : std_logic_vector(0 to byte_count * 8 - 1) :=
        "00110011" &
        "01100010" &
        "01001001" &
        "10101010";

begin

    clk_gen : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_gen;

    main : process is
    begin
        reset  <= '1';
        pin_in <= '1';
        wait for clk_period;

        reset <= '0';
        wait for bit_period;

        for byte_index in 0 to byte_count - 1 loop
            pin_in <= '0';
            wait for bit_period;
            for bit_index in 0 to 7 loop
                pin_in <= data(byte_index * 8 + bit_index);
                wait for bit_period;
            end loop;
            pin_in <= '1';
            wait for bit_period;
            wait for 3 * bit_period;
        end loop;

        wait;
    end process main;

    DUT : entity work.uart_rx
        generic map (
            bits_per_chunk  => bits_per_chunk,
            freq            => freq,
            baud_rate       => baud_rate,
            samples_per_bit => samples_per_bit
        )
        port map (
            clk    => clk,
            reset  => reset,
            pin_in => pin_in,
            output => output,
            done   => done
        );

end architecture testbench;
