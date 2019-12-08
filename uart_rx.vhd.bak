library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is 
    -- UART Receiver
    generic (
        -- n must be a number of two:
        n           : integer := 16;    
        samples     : integer := 16;                            -- determines number of samples per bit
        baud_rate   : integer := 19200;
        freq        : integer := 50000000
    ); 
    
    port(
        -- Inputs:
        rx_in       : in std_logic;
        clk         : in std_logic;
        reset       : in std_logic;
        
        -- Outputs:
        rx_out      : out std_logic_vector(0 to n - 1);     -- output number of 16 bits
        rx_available: out std_logic                         -- is receiver being used
    
    );
end entity uart_rx;

architecture behavioral of uart_rx is
    type state_type_rx is (IDLE, START, RCV, STOP);
    
    signal state_reg, next_state        : state_type_rx := IDLE;
    signal sample_cnt                   : integer := 0;
    signal cnt_samples                  : integer := 0;
    signal bits_cnt                     : integer := 0;
    signal rx_reg , rx_reg_prev         : std_logic_vector(0 to n - 1) <= (others => 0);
    signal rx_in_prev                   : std_logic;
    

begin
    state_transtion: process(clk, reset) is
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                state_reg <= IDLE;
            else
                state_reg <= next_state;
            end if;
            
            rx_out      <= rx_reg;
            rx_in_prev  <= rx_in;
            rx_reg_prev <= rx_reg;
         end if;
         
    end process state_transtion;
    
    -- Process for counter for sample_clk:
    sample_cnt_up: process(clk, reset, state_reg, next_state) is
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                sample_cnt <= 0;
            elsif (sample_cnt = freq/(baud_rate*samples) + 1) then
                sample_cnt <= 0;
            elsif state_reg = IDLE and next_state = START then
                sample_cnt <= 0;
            else
                sample_cnt <= sample_cnt + 1;
            end if;
         end if;

    end process sample_cnt_up;

    
    -- Count to n - 1 samples:
    cnt_samples_up: process(clk, sample_cnt, cnt_samples, state_reg, next_state) is
    begin
        if(rising_edge(clk)) then
            if (reset = '1') then
                cnt_samples <= 0;
            elsif cnt_samples = samples - 1 then
                cnt_samples <= 0;
            elsif state_reg = IDLE and next_state = START then
                cnt_samples <= 0;
            else
                if sample_cnt = freq/(baud_rate*samples) then
                    cnt_samples <= cnt_samples + 1;
                end if;
            end if;
        end if;
    end process cnt_samples_up;
    
    -- Process for counting the received bits:
    bits_cnt_up: process(clk, state_reg, cnt_samples, bits_cnt) is
    begin
         if rising_edge(clk) then
            if reset = '1' then
                bits_cnt <= 0;
            elsif bits_cnt = n - 1 then
                bits_cnt <= 0;
            elsif state_reg = IDLE and next_state = START then
                bits_cnt <= 0;
            else
                if cnt_samples = samples - 1 then
                    bits_cnt <= bits_cnt + 1;
                end if;
            end if;
         end if;
    end process bits_cnt_up;
    
    -- Process for next state logic:
    next_state_logic: process(state_reg, rx_in, rx_in_prev, cnt_samples, bits_cnt) is
    begin
        case state_reg is
        when IDLE =>
            if (rx_in = '0' and rx_in_prev = '1') then
                next_state <= START;
            else
                next_state <= IDLE;
            end if;
        when START =>
            if cnt_samples = samples - 1 then
                next_state <= RCV;
            else
                next_state <= START;
            end if;
        when RCV =>
            if bits_cnt = n - 1 then
                next_state <= STOP;
            else
                next_state <= RCV;
            end if;
        when STOP =>
            if cnt_samples = samples - 1 then
                next_state <= IDLE;
            else
                next_state <= STOP;
            end if;
        end case;
        
    end process next_state_logic;

    output_logic: process(state_reg, rx_reg_prev, cnt_samples, rx_in) is
    begin
        case state_reg is
        when IDLE =>
            rx_available <= '1';
            rx_reg  <= rx_reg_prev;
        when START =>
            rx_available <= '0';
            rx_reg <= rx_reg_prev;
        when RCV =>
            rx_available <= '0';
            if cnt_samples = samples/2 then
                rx_reg(0 to n-2) <= rx_reg_prev(1 to n - 1);
                rx_reg(n - 1) <= rx_in;
            else
                rx_reg <= rx_reg_prev;
            end if;
        when STOP =>
            rx_available <= '0';
            rx_reg <= rx_reg_prev;
        end case;
        
    end process output_logic;
    
    
end behavioral;