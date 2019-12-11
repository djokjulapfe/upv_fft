library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity fftn_output_serializer is
    generic (
        n             : integer := 16;
        bits_per_data : integer := 8
    );
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        fftn_out   : in  complex_vector(0 to n - 1);
        start      : in  std_logic;
        step       : in  std_logic;
        data       : out std_logic_vector(bits_per_data - 1 downto 0);
        data_ready : out std_logic
    );
end entity fftn_output_serializer;

architecture behav of fftn_output_serializer is

    component counter is
        generic (
            n : integer := 0
        );
        port (
            clk      : in     std_logic;
            reset    : in     std_logic;
            step     : in     std_logic;
            value    : buffer integer range 0 to n;
            finished : out    std_logic
        );
    end component counter;

    constant num_chunks : integer := word_size / bits_per_data;

    signal started : std_logic;

    signal chunk_index   : integer range 0 to num_chunks * 2;
    signal value_index   : integer range 0 to n;
    signal item_finished : std_logic;
    signal all_finished  : std_logic;

    signal data_ready_delay : std_logic;

    signal item_step_mask  : std_logic;
    signal chunk_step_mask : std_logic;

begin

    update_state : process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                started <= '0';
            elsif start = '1' then
                started <= '1';
            elsif all_finished = '1' then
                started <= '0';
            end if;
        end if;
    end process update_state;

    selection : process (clk) is
        variable selection      : signed(bits_per_data - 1 downto 0);
        variable selected_value : complex;
        variable selected_item  : signed(word_size - 1 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data <= (others => '0');
                data_ready <= '0';
                data_ready_delay <= '0';
            else
                selected_value := fftn_out(value_index);
                if chunk_index < num_chunks then
                    selected_item := selected_value.re;

                    selection := selected_item((chunk_index + 1) * bits_per_data - 1
                            downto chunk_index * bits_per_data);
                else
                    selected_item := selected_value.im;

                    selection := selected_item((chunk_index - num_chunks + 1) * bits_per_data - 1
                            downto (chunk_index - num_chunks) * bits_per_data);
                end if;
                data <= std_logic_vector(selection);
                if ((chunk_index /= 2 * num_chunks - 1 and chunk_step_mask = '1') or item_step_mask = '1')
                    and started = '1' then

                    data_ready_delay <= '1';
                else
                    data_ready_delay <= '0';
                end if;
                data_ready <= data_ready_delay;
            end if;
        end if;
    end process selection;

    item_step_mask  <= item_finished and started;
    chunk_step_mask <= step and started;

    item_counter : entity work.counter
        generic map (
            n => n
        )
        port map (
            clk      => clk,
            reset    => reset,
            step     => item_step_mask,
            value    => value_index,
            finished => all_finished
        );

    chunk_counter : entity work.counter
        generic map (
            n => num_chunks * 2
        )
        port map (
            clk      => clk,
            reset    => reset,
            step     => chunk_step_mask,
            value    => chunk_index,
            finished => item_finished
        );

end architecture behav;
