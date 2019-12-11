--------------------------------------------------------------------------------
-- Title       : Input Buffer
-- Project     : FFT
-- File        : input_buffer.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  8
-- Version     : 1.0
-- Description : Stores the input data in a buffer
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

--! Stores the input data in a buffer
entity input_buffer is
    generic (
        --! number of elements to store
        n : integer := 16
    );
    port (
        --! clock
        clk : in std_logic;
        --! reset
        reset : in std_logic;
        --! Flag indicating the there is input
        input_ready : in std_logic;
        --! Value to be stored
        word_in : in complex;
        --! Current state of the buffer
        buffered_data : buffer complex_vector(0 to word_size - 1);
        --! Flag indicating n values have been stored.
        ready : buffer std_logic
    );
end entity input_buffer;

architecture behav of input_buffer is

    --! Points to the location where to store the next value
    signal counter : integer range 0 to n - 1;

begin

    --buffered_data <= internal_buffer;

    main : process (clk) is
        variable new_counter_value : integer range 0 to n - 1;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter       <= 0;
                ready         <= '0';
                buffered_data <= (others => pair2complex(0, 0));
            else
                if ready = '1' then
                    ready <= '0';
                end if;
                if input_ready = '1' then
                    buffered_data(counter) <= word_in;
                    if counter = n - 1 then
                        new_counter_value := 0;
                    else
                        new_counter_value := counter + 1;
                    end if;
                    if new_counter_value = 0 then
                        ready <= '1';
                    end if;
                    counter <= new_counter_value;
                end if;
            --if counter = n - 1 then
            --    counter <= 0;
            --    ready   <= '1';
            --else
            --    ready <= '0';
            --end if;
            end if;
        end if;
    end process main;

end architecture behav;
