library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity input_buffer is
    generic (
        n : integer := 16
    );
    port (
        clk           : in     std_logic;
        reset         : in     std_logic;
        input_ready   : in     std_logic;
        word_in       : in     complex;
        buffered_data : out complex_vector(0 to word_size - 1);
        ready         : out    std_logic
    );
end entity input_buffer;

architecture behav of input_buffer is

    signal internal_buffer : complex_vector(0 to word_size - 1);
    signal counter : integer;

begin

    buffered_data <= internal_buffer;

    main : process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= 0;
                internal_buffer <= (others => pair2complex(0, 0));
                -- In case ready is '1' before reset is called
                ready <= '0';
            else
                if input_ready = '1' then
                    internal_buffer(counter) <= word_in;
                    counter                <= counter + 1;
                end if;
                if counter = n - 1 then
                    counter <= 0;
                    ready   <= '1';
                else
                    ready <= '0';
                end if;
            end if;
        end if;
    end process main;

end architecture behav;
