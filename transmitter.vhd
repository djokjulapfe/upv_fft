library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transmitter is
	port (
		n         : integer := 16;
		baud_rate : integer := 19200;
		freq      : integer := 50000000
	);
	port (
		clk                : in  std_logic;
		reset              : in  std_logic;
		data               : in  complex_vector(0 to n - 1);
		start_transmission : in  std_logic;
		uart_tx            : out std_logic
	);
end entity transmitter;

architecture behav of transmitter is

	constant uart_count_max : integer := freq / baud_rate / 32;

	signal uart_count : integer range 0 to uart_count_max := 0;

	signal uart_clk : std_logic;

begin




end architecture behav;