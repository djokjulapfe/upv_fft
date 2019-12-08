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
        tx_available: in std_logic;                     -- is transmitter available?
        clk         : in std_logic;
        reset       : in std_logic;
        
        -- Outputs:
        tx_start    : out std_logic;                    -- signals uart_tx to start transmitting
        tx_number   : out std_logic_vector(0 to n - 1); -- number that needs to be transmitted
    
    );
end entity uart_tx_interface;

architecture behavioral of uart_tx_interface is
    type state_type is (IDLE, SEND_RE, SEND_IM, UPDATE);
    
    signal state_reg, next_reg : state_type := IDLE;
    
    signal index, index_prev: integer range(0 to n) := 0-- tracks the index of fft_out
    signal curr_num         : complex;                  -- current number
    signal re_sent,im_sent  : std_logic := '0';         -- determine if the real and imaginary part are sent
    signal re_sent_prev     : std_logic := '0';
    signal im_sent_prev     : std_logic := '0';
    signal tx_done          : std_logic := '0';
    signal tx_available_prev: std_logic := '0';
                                         

begin

    state_transition: process(clk, reset) is
    begin
        if rising_edge(clk) then
            state_reg <= IDLE;
        else
            state_reg <= next_state;
                
            re_sent_prev <= re_sent;
            im_sent_prev <= im_sent;
            tx_available_prev <= tx_available;
            index_prev <= index;
            curr_num <= fft_out(index);
        end if;
        
    end state_transition;
    
    next_state_logic: process(state_reg) is
    begin
        case state_reg is
        when IDLE =>
            if tx_start = '1' then
                next_state <= SEND_RE;
            else
                next_state <= IDLE;
            end if;
        when SEND_RE =>
            if re_sent = '1' then
                next_state <= SEND_IM;
            else
                next_state <= SEND_RE;
            end if;
        when SEND_IM =>
            if im_sent = '1' then
                next_state <= UPDATE;
            else
                next_state <= SEND_IM
            end if;
        when UPDATE =>
            if tx_done = '1' then
                next_state <= IDLE;
            else 
                next_state <= SEND_RE;
            end if;
        end case;
    
    end process next_state_logic;
    
    re_sent_logic: process(state_reg, tx_available, index, re_sent_prev, tx_available_prev) is
    begin
        case state_reg is
        when SEND_RE =>
            if tx_available_prev = '0' and tx_available = '1' then
                re_sent <= '1';
            else
                re_sent <= '0';
            end if;
        when UPDATE =>
            if index < n then
                re_sent <= '0';
            else
                re_sent <= '1';
            end if;
        when others =>
            re_sent <= re_sent_prev;
        end case;
    
    end process re_sent_logic;
         
    im_sent_logic: process(state_reg, tx_available, index, im_sent_prev, tx_available_prev) is
    begin
        case state_reg is
        when SEND_IM =>
            if tx_available_prev = '0' and tx_available = '1' then
                im_sent <= '1';
            else
                im_sent <= '0';
            end if;
        when UPDATE =>
            if index < n then
                im_sent <= '0';
            else
                im_sent <= '1';
            end if;
        when others =>
            im_sent <= im_sent_prev;
        end case;
    
    end process im_sent_logic;
    
    index_cnt_up: process(clk, next_state) is
    begin
        if rising_edge(clk) then
            if next_state = UPDATE and index < n then
                index <= index + 1;
            else
                index <= index_prev;
            end if;
        end if;
               
    end process index_cnt_up;
    
    tx_start_logic: process(state_reg) is
    begin
        case state_reg is
        when SEND_RE =>
            if re_sent = '0' and tx_available = '1' then
                tx_start <= '1';
            else
                tx_start <= '0';
            end if;
        when SEND_IM => 
            if im_sent = '0' and tx_available = '0' then
                tx_start <= '1';
            else
                tx_start <= '0';
            end if;
        when others =>
            tx_start <= '0';
        end case;
        
    end tx_start_logic;
    
    tx_number_logic: process(state_reg, index, fft_out) is
    begin
        case state_reg is
        when SEND_RE =>
            tx_number <= curr_num.re;
        when SEND_IM =>
            tx_number <= curr_num.im;
        end case;
    
    end process tx_number_logic;
    
end behavioral;