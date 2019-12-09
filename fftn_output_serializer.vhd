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
        data       : out std_logic_vector(7 downto 0);
        data_ready : out std_logic
    );
end entity fftn_output_serializer;

architecture behav of fftn_output_serializer is

    component counter is
        generic (
            n : integer := n * 4
        );
        port (
            clk      : in     std_logic;
            reset    : in     std_logic;
            step     : in     std_logic;
            value    : buffer integer range 0 to n;
            finished : out    std_logic
        );
    end component counter;

    constant datas_per_word = word_size / bits_per_data;

    signal selected_value : integer range 0 to n;

begin

    selected_value <= counter_value >> 2;

    data <= std_logic_vector(fftn_out(counter_value));

    counter_1 : entity work.counter
        generic map (
            n => n
        )
        port map (
            clk      => clk,
            reset    => reset,
            step     => step,
            value    => counter_value,
            finished => counter_finished
        );

end architecture behav;
