library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    -- UART transmitter
    generic( 
        -- n must be a power of two
        n           : integer := 16;
        freq        : integer := 50000000;
        baud_rate   : integer := 19200
        );
        
    port(
        -- Input ports:
        tx_in       : in std_logic_vector (0 to n - 1);     -- bits that need to be transmitted
        tx_start    : in std_logic;                         -- command for tx to be active    
        clk         : in std_logic;                         -- clock of FPGA chip
        reset       : in std_logic;
        
        -- Output ports:
        tx_out      : out std_logic;                        -- serial out
        tx_available: out std_logic                         -- signals if the tx is available for sending
    );
end entity uart_tx;

architecture behavioral of uart_tx is
    -- States:
    type state_type_tx is (IDLE, START, SEND, STOP);
    
    signal state_reg, next_state: state_type_tx := IDLE;
    signal bits_cnt, bits_cnt_prev  : integer := 0;
    signal baud_cnt                 : integer := 0;
    signal baud_clk, baud_clk_prev  : std_logic := '0';
    signal tx_start_prev            : std_logic := '0';
    
begin
    -- Process that controls state transition:
    state_transition: process(clk, reset) is
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                state_reg <= IDLE;
            else
                state_reg <= next_state;
            end if;
            
            baud_clk_prev <= baud_clk;
            tx_start_prev <= tx_start;
            bits_cnt_prev <= bits_cnt;
        end if;
    end process state_transition;
    
     -- Process that controls the counting of bits that are transmitted
    bits_cnt_up: process(state_reg, baud_clk, baud_clk_prev, bits_cnt_prev) is
    begin
        if (baud_clk = '1' and baud_clk_prev = '0') then
            case state_reg is
            when SEND | STOP =>
                bits_cnt <= bits_cnt_prev + 1;
            when others =>
                bits_cnt <= 0;
            end case;
        else
            bits_cnt <= bits_cnt_prev;
        end if;
        
    end process bits_cnt_up;

    -- Counter for baud_clk 
    baud_cnt_up: process(clk, reset, tx_start) is
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                baud_cnt <= 0;
            elsif (tx_start_prev = '0' and tx_start = '1') then
                baud_cnt <= 0;
            elsif (baud_cnt = freq/baud_rate) then
                baud_cnt <= 0;
            else
                baud_cnt <= baud_cnt + 1;
            end if;
            
        end if;
    end process baud_cnt_up;
    
    -- Process that creates baud_clk
    baud_clk_gen: process(baud_cnt) is
    begin
        if (baud_cnt = freq/baud_rate - 1) then
            baud_clk <= '1';
        else 
            baud_clk <= '0';
        end if;  
    
    end process baud_clk_gen;
    
    -- Process that controls the next state logic:
    next_state_logic: process(state_reg, tx_start, bits_cnt, baud_clk, baud_clk_prev) is
    begin
        case state_reg is
        when IDLE =>
            if tx_start = '1' then
                next_state <= START;
            else 
                next_state <= state_reg;
            end if;
        when START =>
            if (baud_clk = '1' and baud_clk_prev = '0') then
                next_state <= SEND;
            else    
                next_state <= START;
            end if;
        when SEND =>
            if bits_cnt < n - 1 then                   -- still have bits left to send
                next_state <= SEND;
            else
                next_state <= STOP;
            end if;
        when STOP =>
            if bits_cnt = n then
                next_state <= IDLE;  
            else
                next_state <= STOP;
            end if;
        end case; 
            
    end process next_state_logic;
    
     -- Process that controls the output
    output_logic: process(state_reg, tx_in, bits_cnt) is
    begin
        case state_reg is
        when IDLE =>
            tx_out       <= '1';                        -- keep the line high in idle state
            tx_available <= '1';                        -- signal that we are not sending anything
        when START =>
            tx_out       <= '0';                        -- send start bit
            tx_available <= '0';                        -- signal that tx isn't available
        when SEND =>
            tx_out       <= tx_in(bits_cnt);            -- send the current bit on the line
            tx_available <= '0';
        when STOP =>
            tx_out       <= '1';                        -- send stop bit
            tx_available <= '0';
        end case;
    
    end process output_logic;
    
    
end behavioral;
    