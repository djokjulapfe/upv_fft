library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------

entity upv_fft_tb is

end entity upv_fft_tb;

-----------------------------------------------------------

architecture testbench of upv_fft_tb is

    -- Testbench DUT generics


    -- Testbench DUT ports
    signal clk      : std_logic;
    signal uart_in  : std_logic;
    signal uart_out : std_logic;

    -- Other constants
    constant clk_period : time := 10 ns; -- NS

begin
    -----------------------------------------------------------
    -- Clocks
    -----------------------------------------------------------
    CLK_GEN : process
    begin
        clk <= '1';
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process CLK_GEN;

    -----------------------------------------------------------
    -- Testbench Stimulus
    -----------------------------------------------------------

    RND : process
    begin
        wait for clk_period / 2;
        uart_in <= '0';
        wait for clk_period * 10;
        uart_in <= '1';
        wait for clk_period * 5;
    end process RND;

    -----------------------------------------------------------
    -- Entity Under Test
    -----------------------------------------------------------
    DUT : entity work.upv_fft
        port map (
            clk      => clk,
            uart_in  => uart_in,
            uart_out => uart_out
        );

end architecture testbench;