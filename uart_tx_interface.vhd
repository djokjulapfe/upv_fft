library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity uart_tx_interface is
    -- Prepares the complex_vector and sends number by number to uart_tx
    generic(
        -- n must be a power of 2
        n   : integer := 16
    );
    
    port(
        -- Inputs:
        fft_out     : in complex_vector(0 to n - 1);    -- array of complex numbers
        tx_send     : in std_logic;                     -- command to send the complex_vector
        tx_available: in std_logic;                     -- is transmitter available?
        clk         : in std_logic;
        reset       : in std_logic;
        
        -- Outputs:
        tx_start    : out std_logic;                    -- signals uart_tx to start transmitting
        tx_number   : out std_logic_vector(0 to n - 1); -- number that needs to be transmitted  
        tx_done     : out std_logic                     -- are we done transimitting
    
    );
end entity uart_tx_interface;

architecture behavioral of uart_tx_interface is
    
    type state_type is (IDLE, SEND_RE, SEND_IM, UPDATE, CLEANUP);
    signal state_reg, next_state : state_type := IDLE;
    
    signal index            : integer range(0 to n);    -- tracks the index of fft_out
    signal curr_num         : complex;                  -- current number
    signal re_sent,im_sent  : std_logic := '0';         -- determine if the real and imaginary part are sent
                                         

begin

    curr_num <= fft_out(index)
    
    state_transition: process(clk, reset) is
    begin
        if (rising_edge(clk)) then
            if reset = '1' then
                state_reg <= IDLE;
            else
                state_reg <= next_state;    
            end if;
        end if;
    
    end process state_transition;
    
    next_state_logic: process(state_reg, re_sent, im_sent, index, tx_available, tx_send) is
    begin
        case state_reg is
        when IDLE => 
            if (tx_send = '1') then         -- we get a command to send files
                next_state <= SEND_RE;
            else
                next_state <= IDLE;
            end if;
        when SEND_RE =>
            if (re_sent = '1' and tx_available = '1') then
                next_state <= SEND_IM;
            else
                next_state <= SEND_RE;
        when SEND_IM =>
            if(im_sent = '1' and tx_available = '1')
    
    end process next_state_logic;
    
    
end behavioral;