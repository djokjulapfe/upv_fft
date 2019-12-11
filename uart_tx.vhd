--------------------------------------------------------------------------------
-- Title       : UART Tx
-- Project     : FFT
-- File        : uart_tx.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  8
-- Version     : 1.0
-- Description : Transmitter of UART system
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Transmits the n bit data on input bit by bit
entity uart_tx is
    generic( 
        --! Number of bits of std_logic_vector on input
        n           : integer := 16;
        --! Limit value of counter for finding baud rate
        baud_cnt_max: integer := 2605
        );
        
    port(
        -- Inputs:
        --! Clock signal
        clk         : in std_logic;
        --! Reset
        reset       : in std_logic;
        --! Data that needs to be transmitted
<<<<<<< Updated upstream
        tx_in       : in std_logic_vector (0 to n - 1);
=======
        tx_in       : in std_logic_vector (n - 1 downto 0);
>>>>>>> Stashed changes
        --! Command to start transmittion
        tx_start    : in std_logic;                        

        -- Outputs:
        --! Serial out
        tx_out      : out std_logic;
        --! Flag indicating that transmission is done
        tx_done: out std_logic                         
    );
end entity uart_tx;

architecture behavioral of uart_tx is
    
    --! Counter used to determine the baud rate
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
    type state_type_tx is (IDLE, START, SEND, STOP);
    --! Registers for storing current and next state
    signal state_reg, next_state            : state_type_tx := IDLE;
    --! Counter for counting sent bits
    signal bits_cnt                         : integer range 0 to n - 1 := 0;
    --! Counter for clock ticks for determining baud rate
    signal baud_cnt                         : integer range 0 to baud_cnt_max := 0;
    --! Previous value of command for start of transmission
    signal tx_start_prev                    : std_logic := '0';
    --! Stores lower half of #tx_in
<<<<<<< Updated upstream
    signal tx_in_lower                      : std_logic_vector(0 to n/2 - 1);
    --! Stores higher half of #tx_in
    signal tx_in_higher                     : std_logic_vector(0 to n/2 - 1);
=======
    signal tx_in_lower                      : std_logic_vector(n/2 - 1 downto 0);
    --! Stores higher half of #tx_in
    signal tx_in_higher                     : std_logic_vector(n/2 - 1 downto 0);
>>>>>>> Stashed changes
    --! Flags for determining if the coresponding parts of tx_in are sent
    signal tx_l_sent, tx_h_sent             : std_logic := '0';
    signal tx_l_sent_prev, tx_h_sent_prev   : std_logic := '0';
    --! Flag for detecting the rising edge of #tx_start
    signal tx_start_edge                    : std_logic := '0';
    --! Flag for determining if next bit should be sent
    signal baud_clk, baud_clk_prev          : std_logic := '0';
    --! Flag when #bits_cnt finishes:
    signal bits_cnt_finished                : std_logic;
<<<<<<< Updated upstream
    --! Flag for when #next_state is SEND
    signal next_state_send                  : std_logic := '0';
    
begin
    -- Partition #tx_in in two separate bytes:
    tx_in_lower     <= tx_in(0 to (n - 1)/2);
    tx_in_higher    <= tx_in(n/2 to n - 1);
    
    -- Set flag #tx_done if both lower and higher parts are sent:
    tx_done         <= tx_l_sent and tx_h_sent;
    
    -- Set flag #next_state_send if #next_state is SEND
    next_state_flag_logic: process(next_state, state_reg) is
=======
    --! Flags for when #state_reg and #next_state are SEND
    signal state_reg_send, next_state_send  : std_logic := '0';
    
begin
    -- Partition #tx_in in two separate bytes:
    tx_in_lower     <= tx_in(n/2 - 1 downto 0);
    tx_in_higher    <= tx_in(n - 1 downto n/2);
    
    -- Set flag #tx_done if both lower and higher parts are sent:
    tx_done         <= tx_l_sent and tx_h_sent;
    
    --! Sets flag for #next_state_send if #next_state is SEND
    next_state_send_flag_logic: process(next_state, state_reg) is
>>>>>>> Stashed changes
    begin
        if next_state = SEND and state_reg = START then
            next_state_send <= '1';
        else
            next_state_send <= '0';
        end if;           
<<<<<<< Updated upstream
    end process next_state_flag_logic;
    
    -- Set flag for raising edge of tx_start:
    tx_start_edge   <= tx_start and (not tx_start_prev);
=======
    end process next_state_send_flag_logic;
    
    --! Sets flag for raising edge of tx_start if #state_reg is START
    tx_start_edge_logic: process(state_reg, tx_start, tx_start_prev) is
    begin
        case state_reg is
        when IDLE =>
            tx_start_edge   <= tx_start and (not tx_start_prev);
        when others =>
            rx_start_edge   <= '0';
        end case;
    end process tx_start_edge_logic;
>>>>>>> Stashed changes
    
    --! Counts baud_cnt_max clock rising edges
    clk_counter: counter
        generic map ( 
            n => baud_cnt_max
        )
        port map (
            clk         => clk,
<<<<<<< Updated upstream
            reset       => reset,
=======
            reset       => tx_start_edge,
>>>>>>> Stashed changes
            step        => clk,
            value       => baud_cnt,
            finished    => baud_clk
        );
        
        
<<<<<<< Updated upstream
     --! Counter of bits that are transmitted
    bits_counter: counter
        generic map ( 
            n => n
        )
        port map (
            clk         => clk,
            reset       => next_state_send,
=======
    --! Counter of bits that are transmitted
    bits_counter: counter
        generic map ( 
            n => n/2
        )
        port map (
            clk         => clk,
            reset       => state_reg_send,
>>>>>>> Stashed changes
            step        => baud_clk,
            value       => bits_cnt,
            finished    => bits_cnt_finished
        );
        
    --! Control of state transition
    state_transition: process(clk, reset) is
    begin
        -- Update the state register on clock
        if (rising_edge(clk)) then
            if (reset = '1') then
                state_reg   <= IDLE;
            else
                state_reg   <= next_state;
            end if;
            
            -- Memorise the previous values of baud_clk and tx_start
            baud_clk_prev   <= baud_clk;
            tx_start_prev   <= tx_start;
            tx_l_sent_prev  <= tx_l_sent;
            tx_h_sent_prev  <= tx_h_sent;
<<<<<<< Updated upstream
=======
            state_reg_send  <= next_state_send;
>>>>>>> Stashed changes
        end if;
    end process state_transition;
    
    --! Control of next state logic:
    next_state_logic: process(state_reg, tx_start_edge, bits_cnt, baud_clk, baud_clk_prev, tx_h_sent, tx_l_sent) is
    begin
        case state_reg is
        -- In IDLE state we wait for tx_start_edge to be set
        when IDLE =>
            if tx_start_edge = '1' then
                next_state <= START;
            else 
                next_state <= IDLE;
            end if;
        -- In START we wait for baud_clk to tick (since we transmit start bit)    
        when START =>
            if (baud_clk = '1' and baud_clk_prev = '0') then
                next_state <= SEND;
            else    
                next_state <= START;
            end if;
        -- In SEND we wait for n/2 - 1 bits to be transmitted
        when SEND =>
            if bits_cnt < (n/2 - 1) then
                next_state <= SEND;
            else
                if (baud_clk = '1' and baud_clk_prev = '0') then
                    next_state <= STOP;
                else
                    next_state <= SEND;
                end if;
            end if;
        -- In STOP we either go to IDLE, or to START again, depending on whether both half
        -- of input data were sent
        when STOP =>
            if (baud_clk = '1' and baud_clk_prev = '0') then
                if tx_h_sent = '0' then
                    next_state <= START;
                else
                    next_state <= IDLE;
                end if;
            else
                next_state <= STOP;
            end if;
        end case; 
            
    end process next_state_logic;
    
     --! Control of output
    output_logic: process(state_reg, tx_l_sent, bits_cnt, tx_in_lower, tx_in_higher) is
    begin
        case state_reg is
        -- In IDLE we keep the line high
        when IDLE =>
            tx_out       <= '1';
        -- In START we send the start bit 
        when START =>
            tx_out       <= '0';
        -- In SEND we send the bytes of tx_in
        when SEND =>
            if tx_l_sent = '0' then
                tx_out   <= tx_in_lower(bits_cnt);
            else 
                tx_out   <= tx_in_higher(bits_cnt);
            end if;
        -- In STOP we send the stop bit    
        when STOP =>
            tx_out       <= '1';
        end case;
    
    end process output_logic;
    
    --! Control of flags for sending lower and higher bytes of tx_in
    tx_flags: process(state_reg, tx_l_sent_prev, tx_h_sent_prev, baud_clk, baud_clk_prev) is
    begin
        case state_reg is
        when IDLE =>
            tx_l_sent <= '0';
            tx_h_sent <= '0';
        when START | SEND =>
            tx_l_sent <= tx_l_sent_prev;
            tx_h_sent <= tx_h_sent_prev;
        when STOP =>
            if baud_clk = '1' and baud_clk_prev = '0' then
                if tx_l_sent_prev = '0' then
                    tx_l_sent <= '1';
                    tx_h_sent <= tx_h_sent_prev;
                else 
                    tx_l_sent <= tx_l_sent_prev;
                    tx_h_sent <= '1';
                end if;
            else
                tx_l_sent <= tx_l_sent_prev;
                tx_h_sent <= tx_h_sent_prev;
            end if;    
        end case;        

    end process tx_flags;
    
    
end behavioral;
    