--------------------------------------------------------------------------------
-- Title       : UART Rx
-- Project     : FFT
-- File        : uart_rx.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  8
-- Version     : 1.0
-- Description : REceiver of UART system
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use work.types.all;

--! Receives data bit by bit and puts them in bytes 
entity uart_rx is
    -- UART Receiver
    generic (
        --! Number of bits of std_logic_vector on input
        n : integer := 16; -- must be multpile of 8
                           --! Number of samples per bit
        samples : integer := 16;
        --! Limit value of counter for determining sample rate
        sample_cnt_max : integer := 163 -- 50 MHz, 19200, 16 samples per bit
    );

    port(
        -- Inputs:
        --! Clock signal
        clk : in std_logic;
        --! Reset
        reset : in std_logic;
        --! Serial input
        rx_in  : in  std_logic;
        rx_int : out std_logic;

        -- Outputs:
        --! Data of 2 bytes put into std_logic_vector
        rx_out : out std_logic_vector(n - 1 downto 0);
        --! Flag indicating that output data is ready to be processed
        rx_done : out std_logic

    );
end entity uart_rx;

architecture behavioral of uart_rx is

    --! Counter component
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

    --! States of fsm
    type state_type_rx is (IDLE, START, RCV, STOP);
    --! Registers for storing current and next state
    signal state_reg, next_state : state_type_rx := IDLE;
    --! Counter used for counting clock signals for sample rate
    signal clk_cnt : integer range 0 to sample_cnt_max := 0;
    --! Counter for number of samples
    signal sample_cnt : integer range 0 to samples := 0;
    --! Counter for bits that were received
    signal bits_cnt : integer range 0 to n/2 - 1 := 0;
    --! Registers for lower and higher byte 
    signal rx_out_lower, rx_out_higher           : std_logic_vector(n/2 - 1 downto 0) := (others => '0');
    signal rx_out_lower_prev, rx_out_higher_prev : std_logic_vector(n/2 - 1 downto 0) := (others => '0');
    --! Register for number of two bytes that is received and needs to be converted
    signal rx_out_reg : std_logic_vector(n - 1 downto 0);
    --! Stores previous value of rx_in
    signal rx_in_prev : std_logic := '1';
    --! Flag for falling edge of rx_in  
    signal rx_in_edge : std_logic := '0';
    --! Flag that determines when to sample incoming data
    signal sample_clk, sample_clk_prev : std_logic := '0';
    --! Flag for received bit
    signal bit_rcv : std_logic := '0';
    --! Flag for when #bits_cnt counts to max
    signal bits_cnt_finished : std_logic := '0';
    --! Flags for received lower and higher byte
    signal rx_l_rcv, rx_h_rcv           : std_logic := '0';
    signal rx_l_rcv_prev, rx_h_rcv_prev : std_logic := '0';
    --! Flags to determine if #next_state and #state_reg are START
    signal state_reg_start, next_state_start : std_logic := '0';
    --! Flags to determine if #next_state and #state_reg are RCV
    signal state_reg_rcv, next_state_rcv : std_logic := '0';

begin

    rx_int <= not rx_in;

    --! Sets flag #rx_done if both bytes were received
    rx_done <= rx_l_rcv and rx_h_rcv;

    --! #rx_out is made of #rx_out_lower and #rx_out_higher
    rx_out(n/2 - 1 downto 0) <= rx_out_lower;
    rx_out(n - 1 downto n/2) <= rx_out_higher;


    --! Control of output 
    --rx_out <= rx_out_reg;

    --! Sets #rx_in_edge if falling edge is detected in IDLE state
    rx_in_edge_logic : process(state_reg, rx_in, rx_in_prev) is
    begin
        case state_reg is
            when IDLE | STOP =>
                rx_in_edge <= rx_in_prev and (not rx_in);
            when others =>
                rx_in_edge <= '0';
        end case;
    end process rx_in_edge_logic;

    --! Counter of #sample_cnt_max clock rising edges
    clk_counter : counter
        generic map (
            n => sample_cnt_max
        )
        port map (
            clk      => clk,
            reset    => rx_in_edge,
            step     => clk,
            value    => clk_cnt,
            finished => sample_clk
        );

    --! Counter of samples that are taken
    sample_counter : counter
        generic map (
            n => samples
        )
        port map (
            clk      => clk,
            reset    => state_reg_start,
            step     => sample_clk,
            value    => sample_cnt,
            finished => bit_rcv
        );

    --! Counter of bits that are received    
    bits_counter : counter
        generic map (
            n => n/2
        )
        port map (
            clk      => clk,
            reset    => state_reg_rcv,
            step     => bit_rcv,
            value    => bits_cnt,
            finished => bits_cnt_finished
        );


    --! Sets flag #next_state_start if #next_state is START
    next_state_start_flag_logic : process(next_state, state_reg) is
    begin
        if next_state = START and (state_reg = IDLE or state_reg = STOP) then
            next_state_start <= '1';
        else
            next_state_start <= '0';
        end if;
    end process next_state_start_flag_logic;

    --! Sets flag #next_state_rcv if #next_state is RCV
    next_state_rcv_flag_logic : process(next_state, state_reg) is
    begin
        if next_state = RCV and state_reg = START then
            next_state_rcv <= '1';
        else
            next_state_rcv <= '0';
        end if;
    end process next_state_rcv_flag_logic;


    --! Control of state transition        
    state_transtion : process(clk, reset) is
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                state_reg <= IDLE;
            else
                state_reg <= next_state;
            end if;

            state_reg_start    <= next_state_start;
            state_reg_rcv      <= next_state_rcv;
            rx_in_prev         <= rx_in;
            rx_out_lower_prev  <= rx_out_lower;
            rx_out_higher_prev <= rx_out_higher;
            rx_l_rcv_prev      <= rx_l_rcv;
            rx_h_rcv_prev      <= rx_h_rcv;
        end if;

    end process state_transtion;

    -- Process for next state logic:
    next_state_logic : process(state_reg, rx_in_edge, bit_rcv, bits_cnt_finished) is
    begin
        case state_reg is
            -- In IDLE we wait for line to be driven low so that we can start
            when IDLE =>
                if rx_in_edge = '1' then
                    next_state <= START;
                else
                    next_state <= IDLE;
                end if;
            -- In START wait for start bit to be received, then go to RCV 
            when START =>
                if bit_rcv = '1' then
                    next_state <= RCV;
                else
                    next_state <= START;
                end if;
            -- In RCV we receive the bits on the line 
            when RCV =>
                if bits_cnt_finished = '1' then
                    next_state <= STOP;
                else
                    next_state <= RCV;
                end if;
            -- In STOP we get the stop bit and move to IDLE 
            when STOP =>
                if rx_in_edge = '1' then
                    next_state <= START;
                elsif bit_rcv = '1' then
                    next_state <= IDLE;
                else
                    next_state <= STOP;
                end if;
        end case;

    end process next_state_logic;


    --! Control of received data
    rx_data_logic : process(state_reg, rx_l_rcv, sample_cnt, rx_out_lower_prev, rx_out_higher_prev, rx_in, bits_cnt) is
    begin
        -- Update bytes based on which byte we are receiving
        rx_out_lower  <= rx_out_lower_prev;
        rx_out_higher <= rx_out_higher_prev;

        if state_reg = RCV then
            if rx_l_rcv = '0' then
                if sample_cnt = n/2 then
                    rx_out_lower(bits_cnt) <= rx_in;
                end if;
            else
                if sample_cnt = n/2 then
                    rx_out_higher(bits_cnt) <= rx_in;
                end if;
            end if;
        end if;
    end process rx_data_logic;

    --! Updates #rx_l_rcv and #rx_h_rcv flags
    rx_flags : process(state_reg, rx_l_rcv_prev, rx_h_rcv_prev, bit_rcv, rx_in_edge) is
    begin
        case state_reg is
            when IDLE =>
                if rx_l_rcv_prev = '1' and rx_h_rcv_prev = '1' then
                    rx_l_rcv <= '0';
                    rx_h_rcv <= '0';
                else
                    rx_l_rcv <= rx_l_rcv_prev;
                    rx_h_rcv <= rx_h_rcv_prev;
                end if;
            when START | RCV =>
                rx_l_rcv <= rx_l_rcv_prev;
                rx_h_rcv <= rx_h_rcv_prev;
            when STOP =>
                if bit_rcv = '1' or rx_in_edge = '1' then
                    if rx_l_rcv_prev = '0' then
                        rx_l_rcv <= '1';
                        rx_h_rcv <= rx_h_rcv_prev;
                    else
                        rx_l_rcv <= rx_l_rcv_prev;
                        rx_h_rcv <= '1';
                    end if;
                else
                    rx_l_rcv <= rx_l_rcv_prev;
                    rx_h_rcv <= rx_h_rcv_prev;
                end if;
        end case;

    end process rx_flags;


end behavioral;