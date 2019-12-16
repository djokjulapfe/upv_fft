
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity uart_rx is
    generic (
        bits_per_chunk  : integer := 8;
        freq            : integer := 50000000;
        baud_rate       : integer := 19200;
        samples_per_bit : integer := 16
    );
    port (
        -- Inputs:
        --! Clock signal
        clk : in std_logic;
        --! Reset
        reset : in std_logic;
        --! Serial input
        pin_in : in std_logic;

        -- Outputs:
        --! Data of 2 bytes put into std_logic_vector
        output : out complex;
        --! Flag indicating that output data is ready to be processed
        done : out std_logic
    );
end entity uart_rx;

architecture behav of uart_rx is

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

    constant sample_cnt_max  : integer := freq / baud_rate / samples_per_bit;
    constant max_chunk_count : integer := word_size / bits_per_chunk;

    signal ppin_in             : std_logic;
    signal rx_start            : std_logic;
    signal rx_done             : std_logic;
    signal started             : std_logic;
    signal sample_reset        : std_logic;
    signal sample_cnt_finished : std_logic;
    signal sample_clk          : std_logic;
    signal bits_counter_reset  : std_logic;
    signal bits_counter_step   : std_logic;
    signal current_bit         : integer;
    signal chunk_counter_reset : std_logic;
    signal chunk_counter_step  : std_logic;
    signal current_chunk       : integer;
    signal input_buffer        : signed(word_size - 1 downto 0);

begin

    output <= (
            re => input_buffer,
            im => (others => '0')
    );

    start : process (clk) is
    begin
        if rising_edge(clk) then
            ppin_in  <= pin_in;
            rx_start <= '0';
            if reset = '1' then
                started <= '0';
            elsif pin_in = '0' and ppin_in = '1' and started = '0' then
                rx_start <= '1';
                started  <= '1';
            elsif rx_done = '1' then
                started <= '0';
            end if;
        end if;
    end process start;

    sample_clk_update : process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                sample_clk        <= '0';
                bits_counter_step <= '0';
            else
                bits_counter_step <= '0';
                if sample_cnt_finished = '1' then
                    sample_clk <= not sample_clk;
                    if sample_clk = '0' then
                        bits_counter_step <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process sample_clk_update;

    read_input : process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                input_buffer <= (others => '0');
            else
                if bits_counter_step = '1' and current_bit /= 0 then
                    input_buffer(current_chunk * bits_per_chunk + current_bit - 1) <= pin_in;
                end if;
            end if;
        end if;
    end process read_input;

    sample_reset        <= reset or rx_start;
    bits_counter_reset  <= reset or rx_start;

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
            n => bits_per_chunk + 1
        )
        port map (
            clk      => clk,
            reset    => bits_counter_reset,
            step     => bits_counter_step,
            value    => current_bit,
            finished => rx_done
        );

    chunk_counter : entity work.counter
        generic map (
            n => max_chunk_count
        )
        port map (
            clk      => clk,
            reset    => reset,
            step     => rx_done,
            value    => current_chunk,
            finished => done
        );

end architecture behav;