--------------------------------------------------------------------------------
-- Title       : Top level entiy
-- Project     : FFT
-- File        : types.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  4
-- Version     : 1.0
-- Description : This is the main entity that uses all of the others
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

--! Top level entity
entity upv_fft is
    port (
        --! clock
        clk : in std_logic;
        --! UART rx
        uart_in : in std_logic;
        --! UART tx
        uart_out : out std_logic;
        tmp : in complex_vector(0 to 15)
    );
end entity upv_fft;

--! Main architecture of #upv_fft
architecture struct of upv_fft is

    component fftn is
        generic (
            n     : integer := 16;
            n_max : integer := 16
        );
        port (
            clk     : in  std_logic;
            fft_in  : in  complex_vector(0 to n - 1);
            fft_out : out complex_vector(0 to n - 1)
        );
    end component fftn;

    component rerouter is
        generic (
            n : integer := 2
        );
        port (
            x : in  complex_vector(0 to n - 1);
            y : out complex_vector(0 to n - 1)
        );
    end component rerouter;

    constant n                 : integer := 16;
    signal rerouter_output     : complex_vector(0 to n - 1);
    signal input_buffer_output : complex_vector(0 to n - 1);
    signal fft_out : complex_vector(0 to n - 1);

begin

    input_buffer_output <= tmp;

    main_rerouter : entity work.rerouter
        generic map (
            n => n
        )
        port map (
            x => input_buffer_output,
            y => rerouter_output
        );

    main_fftn : entity work.fftn
        generic map (
            n     => n
        )
        port map (
            clk     => clk,
            fft_in  => rerouter_output,
            fft_out => fft_out
        );

end architecture struct;