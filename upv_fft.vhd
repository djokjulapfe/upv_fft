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
--use ieee.math_real."log2";

use work.types.all;

--! Top level entity
entity upv_fft is
    port (
        --! clock
        clk   : in std_logic;
        reset : in std_logic;
        --! UART rx
        uart_in : in std_logic;
        --! UART tx
        uart_out : out std_logic
    );
end entity upv_fft;

--! Main architecture of #upv_fft
architecture struct of upv_fft is

    constant n               : integer := 16;
    constant bits_per_data   : integer := 8;
    constant freq            : integer := 50000000;
    constant baud_rate       : integer := 19200;
    constant samples_per_bit : integer := 16;
    constant bits_per_chunk  : integer := 8;

    component fftn is
        generic (
            n     : integer := n;
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
            n : integer := n
        );
        port (
            x : in  complex_vector(0 to n - 1);
            y : out complex_vector(0 to n - 1)
        );
    end component rerouter;

    component input_buffer is
        generic (
            n : integer := n
        );
        port (
            clk           : in     std_logic;
            reset         : in     std_logic;
            input_ready   : in     std_logic;
            word_in       : in     complex;
            buffered_data : buffer complex_vector(0 to word_size - 1);
            ready         : out    std_logic
        );
    end component input_buffer;

    component counter is
        generic (
            n : integer
        );
        port (
            clk      : in     std_logic;
            reset    : in     std_logic;
            step     : in     std_logic;
            value    : buffer integer range 0 to n;
            finished : out    std_logic
        );
    end component counter;

    component fftn_output_serializer is
        generic (
            n             : integer := n;
            bits_per_data : integer := bits_per_chunk
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
    end component fftn_output_serializer;

    component uart_rx is
        generic (
            bits_per_chunk  : integer := bits_per_chunk;
            freq            : integer := freq;
            baud_rate       : integer := baud_rate;
            samples_per_bit : integer := samples_per_bit
        );
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            pin_in : in  std_logic;
            output : out complex;
            done   : out std_logic
        );
    end component uart_rx;

    component uart_tx is
        generic (
            bits_per_data   : integer := bits_per_chunk;
            freq            : integer := freq;
            baud_rate       : integer := baud_rate;
            samples_per_bit : integer := samples_per_bit
        );
        port (
            clk      : in     std_logic;
            reset    : in     std_logic;
            tx_in    : in     std_logic_vector(bits_per_data - 1 downto 0);
            tx_start : in     std_logic;
            tx_out   : out    std_logic;
            tx_done  : buffer std_logic
        );
    end component uart_tx;

    signal rerouter_output           : complex_vector(0 to n - 1);
    signal input_buffer_output       : complex_vector(0 to n - 1);
    signal fft_out                   : complex_vector(0 to n - 1);
    signal input_buffer_ready        : std_logic;
    signal calculating_fftn          : std_logic;
    signal fft_finished              : std_logic;
    signal fftn_counter_should_count : std_logic;

    signal step_output_serializer : std_logic;

    signal serial_in       : complex;
    signal serial_in_done  : std_logic;
    signal serial_out_done : std_logic;

    signal serializer_data_ready : std_logic;
    signal serializer_data       : std_logic_vector(bits_per_data - 1 downto 0);
    signal uart_tx_step          : std_logic;

begin

    calculating_fftn_logic : process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                calculating_fftn <= '0';
            elsif input_buffer_ready = '1' then
                calculating_fftn <= '1';
            elsif fft_finished = '1' then
                calculating_fftn <= '0';
            end if;
        end if;
    end process calculating_fftn_logic;

    main_uart_rx : entity work.uart_rx
        generic map (
            bits_per_chunk  => bits_per_chunk,
            freq            => freq,
            baud_rate       => baud_rate,
            samples_per_bit => samples_per_bit
        )
        port map (
            clk    => clk,
            reset  => reset,
            pin_in => uart_in,
            output => serial_in,
            done   => serial_in_done
        );

    main_input_buffer : entity work.input_buffer
        generic map (
            n => n
        )
        port map (
            clk           => clk,
            reset         => reset,
            input_ready   => serial_in_done,
            word_in       => serial_in,
            buffered_data => input_buffer_output,
            ready         => input_buffer_ready
        );

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
            n => n
        )
        port map (
            clk     => clk,
            reset   => reset,
            fft_in  => rerouter_output,
            fft_out => fft_out
        );

    fftn_counter_should_count <= calculating_fftn and not fft_finished;

    fftn_counter : entity work.counter
        generic map (
            n => 2 * 4--integer(log2(real(n)))
        )
        port map (
            clk      => clk,
            reset    => reset,
            step     => fftn_counter_should_count,
            value    => open,
            finished => fft_finished
        );

    uart_tx_step <= serializer_data_ready or fft_finished;

    step_output_serializer <= serial_out_done or fft_finished;

    main_fftn_output_serializer : entity work.fftn_output_serializer
        generic map (
            n             => n,
            bits_per_data => bits_per_data
        )
        port map (
            clk        => clk,
            reset      => reset,
            fftn_out   => fft_out,
            start      => fft_finished,
            step       => serial_out_done,
            data       => serializer_data,
            data_ready => serializer_data_ready
        );

    main_uart_tx : entity work.uart_tx
        generic map (
            bits_per_data   => bits_per_chunk,
            freq            => freq,
            baud_rate       => baud_rate,
            samples_per_bit => samples_per_bit
        )
        port map (
            clk      => clk,
            reset    => reset,
            tx_in    => serializer_data,
            tx_start => serializer_data_ready,
            tx_out   => uart_out,
            done     => serial_out_done
        );

end architecture struct;