library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity fftn is
    generic (
        -- n and n_max must be a power of two
        n     : integer := 16;
        n_max : integer := 16
    );
    port (
        clk     : in  std_logic;
        fft_in  : in  complex_vector(0 to n - 1);
        fft_out : out complex_vector(0 to n - 1)
    );
end entity fftn;

architecture comb of fftn is

    signal fft_upper_half_out : complex_vector(0 to n / 2 - 1);
    signal fft_lower_half_out : complex_vector(0 to n / 2 - 1);
    signal mult_out           : complex_vector(0 to n / 2 - 1);
    signal mid_buffer         : complex_vector(0 to n - 1);
    signal fft_in_rerouted    : complex_vector(0 to n - 1);

begin

    rerout_input : if n = n_max generate
        rerouter : entity work.rerouter
            generic map (
                n => n
            )
            port map (
                x => fft_in,
                y => fft_in_rerouted
            );
    end generate rerout_input;

    no_rerouting : if n /= n_max generate
        fft_in_rerouted <= fft_in;
    end generate no_rerouting;

    multiply : process (clk) is
    begin
        if rising_edge(clk) then
            if n = 2 then
                mid_buffer <= fft_in_rerouted;
            else
                mid_buffer(0 to n / 2 - 1) <= fft_upper_half_out;
                mid_buffer(n / 2 to n - 1) <= mult_out;
            end if;
        end if;
    end process multiply;

    add : process (clk) is
    begin
        if rising_edge(clk) then
            for i in 0 to n / 2 - 1 loop
                fft_out(i)       <= mid_buffer(i) + mid_buffer(n / 2 + i);
                fft_out(n/2 + i) <= mid_buffer(i) - mid_buffer(n / 2 + i);
            end loop;
        end if;
    end process add;

    fft_half : if n > 2 generate
        fft_upper_half : entity work.fftn
            generic map (
                n     => n / 2,
                n_max => n_max
            )
            port map (
                clk     => clk,
                fft_in  => fft_in_rerouted(0 to n / 2 - 1),
                fft_out => fft_upper_half_out
            );
        fft_lower_half : entity work.fftn
            generic map (
                n     => n / 2,
                n_max => n_max
            )
            port map (
                clk     => clk,
                fft_in  => fft_in_rerouted(n / 2 to n - 1),
                fft_out => fft_lower_half_out
            );
    end generate fft_half;

    when_n_is_2 : if n = 2 generate
        fft_upper_half_out(0) <= pair2complex(0, 0);
        fft_lower_half_out(0) <= pair2complex(0, 0);
    end generate when_n_is_2;

    mulitipliers : for i in 0 to n / 2 - 1 generate
        mult_i : entity work.complex_weight
            port map(
                x_in          => fft_lower_half_out(i),
                weight_choice => i * n_max / n,
                y_out         => mult_out(i)
            );
    end generate;

end architecture comb;
