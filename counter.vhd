library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity counter is
	generic (
		n : integer := 100
	);
	port (
		clk      : in     std_logic;
		reset    : in     std_logic;
		step	 : in     std_logic;
		value    : buffer integer range 0 to n;
		finished : out    std_logic
	);
end entity counter;

architecture behav of counter is
begin

	main : process (clk) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				value <= 0;
				finished <= '0';
			elsif step = '1' then 
				if value = n - 1 then
					value <= 0;
					finished <= '1';
				else
					value <= value + 1;
					finished <= '0';
				end if;
			else
				finished <= '0';
			end if;
		end if;
	end process main;

end architecture behav;