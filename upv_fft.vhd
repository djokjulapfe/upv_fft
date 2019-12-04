library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity upv_fft is
	port (
		clk      : in  std_logic;
		uart_in  : in  std_logic;
		uart_out : out std_logic
	);
end entity upv_fft;

architecture behav of upv_fft is
begin
	update : process (clk) is
	begin
		if rising_edge(clk) then
			uart_out <= uart_in;
		end if;
	end process;
end architecture behav;