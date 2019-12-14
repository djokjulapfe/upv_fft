--------------------------------------------------------------------------------
-- Title       : FFTn
-- Project     : FFT
-- File        : fftn.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  4
-- Version     : 1.0
-- Description : Implementation of the radix 2 FFT algorithm [1]
-- Resources   : [1] https://riptutorial.com/algorithm/example/27088/radix-2-fft
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

--! Generates a design for calculating the descrete fourier transform
entity fftn is
    generic (
        --! Rank of the current fftn component
        n : integer := 16
    );
    port (
        --! Clock
        clk : in std_logic;
        --! Reset
        reset : in std_logic;
        --! Signal to be processed
        fft_in : in complex_vector(0 to n - 1);
        --! The spectrum calculated using FFT
        fft_out : out complex_vector(0 to n - 1)
    );
end entity fftn;

--! Main architecture of the radix 2 fft algorithm
architecture comb of fftn is

    --! Output of the upper fftn block of order n / 2
    signal fft_upper_half_out : complex_vector(0 to n / 2 - 1);
    --! Output of the lower fftn block of order n / 2
    signal fft_lower_half_out : complex_vector(0 to n / 2 - 1);
    --! Output of the lower fftn block multiplied with corresponding weights
    signal mult_out : complex_vector(0 to n / 2 - 1);
    --! Buffer storing the result of the lower order fftn blocks before the addition step
    signal mid_buffer : complex_vector(0 to n - 1);

begin

    -- Updates the #mid_buffer with new data
    update_buffer : process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                mid_buffer <= (others => pair2complex(0, 0));
            else
                if n = 2 then
                    mid_buffer <= fft_in;
                else
                    mid_buffer(0 to n / 2 - 1) <= fft_upper_half_out;
                    mid_buffer(n / 2 to n - 1) <= mult_out;
                end if;
            end if;
        end if;
    end process update_buffer;

    -- Combines the #mid_buffer data to the final output of the fftn block
    cross_combine : process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                fft_out <= (others => pair2complex(0, 0));
            else
                for i in 0 to n / 2 - 1 loop
                    fft_out(i)       <= mid_buffer(i) + mid_buffer(n / 2 + i);
                    fft_out(n/2 + i) <= mid_buffer(i) - mid_buffer(n / 2 + i);
                end loop;
            end if;
        end if;
    end process cross_combine;

    -- Generates the upper and lower fftn blocks of rank n / 2
    fft_half : if n > 2 generate
        fft_upper_half : entity work.fftn
            generic map (
                n => n / 2
            )
            port map (
                clk     => clk,
                reset   => reset,
                fft_in  => fft_in(0 to n / 2 - 1),
                fft_out => fft_upper_half_out
            );
        fft_lower_half : entity work.fftn
            generic map (
                n => n / 2
            )
            port map (
                clk     => clk,
                reset   => reset,
                fft_in  => fft_in(n / 2 to n - 1),
                fft_out => fft_lower_half_out
            );
    end generate fft_half;

    -- In case n == 2, there is no need for lower rank fftn blocks
    when_n_is_2 : if n = 2 generate
        fft_upper_half_out(0) <= pair2complex(0, 0);
        fft_lower_half_out(0) <= pair2complex(0, 0);
    end generate when_n_is_2;

    -- Instantiates multipliers for weights
    mulitipliers : for i in 0 to n / 2 - 1 generate
        mult_i : entity work.complex_weight
            generic map (
                weight_choice => i,
                n             => n
            )
            port map(
                x_in  => fft_lower_half_out(i),
                y_out => mult_out(i)
            );
    end generate;

end architecture comb;
