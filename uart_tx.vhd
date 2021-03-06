library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity uart_tx is
    generic (
        bits_per_data   : integer := 8;
        freq            : integer := 50000000;
        baud_rate       : integer := 19200;
        samples_per_bit : integer := 16
    );
    port (
        clk      : in std_logic;
        reset    : in std_logic;
        tx_in    : in std_logic_vector(bits_per_data - 1 downto 0);
        tx_start : in std_logic;

        tx_out : out    std_logic;
        done   : buffer std_logic
    );
end entity uart_tx;


architecture behav of uart_tx is

    component counter is
        generic (
            n : integer := 100
        );
        port (
            clk      : in     std_logic;
            reset    : in     std_logic;
            step     : in     std_logic;
            value    : buffer integer range 0 to n;
            finished : out    std_logic
        );
    end component counter;

    constant sample_cnt_max : integer := freq / baud_rate / samples_per_bit;
    constant uart_tx_delay  : integer := 16 * sample_cnt_max;

    signal sample_cnt_finished : std_logic;
    signal sample_clk          : std_logic;
    signal sample_reset        : std_logic;
    signal bits_counter_reset  : std_logic;
    signal bits_counter_step   : std_logic;
    signal current_bit         : integer;
    signal started             : std_logic;
    signal ptx_start           : std_logic;
    signal tx_done             : std_logic;

begin

    start : process (clk) is
    begin
        if rising_edge(clk) then
            ptx_start <= tx_start;
            if reset = '1' then
                started <= '0';
            elsif tx_start = '0' and ptx_start = '1' then
                started <= '1';
            elsif tx_done = '1' then
                started <= '0';
            end if;
        end if;
    end process start;

    sample_clk_update : process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                sample_clk        <= '1';
                bits_counter_step <= '0';
            else
                bits_counter_step <= '0';
                tx_done           <= '0';
                if sample_cnt_finished = '1' then
                    sample_clk <= not sample_clk;
                    if sample_clk = '0' then
                        bits_counter_step <= '1';
                        if current_bit = bits_per_data + 1 then
                            tx_done <= '1';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process sample_clk_update;

    transmission : process (clk, sample_clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' or tx_done = '1' then
                tx_out <= '1';
            elsif current_bit = 0 and started = '1' then
                tx_out <= '0';
            elsif current_bit > bits_per_data and started = '1' then
                tx_out <= '1';
            elsif current_bit /= 0 and started = '1' then
                tx_out <= tx_in(current_bit - 1);
            end if;
        end if;
    end process transmission;

    sample_reset       <= reset or tx_start;
    bits_counter_reset <= reset or tx_start;

    sample_counter : entity work.counter
        generic map (
            n => samples_per_bit * sample_cnt_max / 2
        )
        port map (
            clk      => clk,
            reset    => sample_reset,
            step     => started,
            value    => open,
            finished => sample_cnt_finished
        );

    bits_counter : entity work.counter
        generic map (
            n => bits_per_data + 2
        )
        port map (
            clk      => clk,
            reset    => bits_counter_reset,
            step     => bits_counter_step,
            value    => current_bit,
            finished => done
        );

end architecture behav;
