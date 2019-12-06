library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity rerouter is
	generic (
		n : integer := 2
	);
	port (
		x : in  complex_vector(0 to n - 1);
		y : out complex_vector(0 to n - 1)
	);
end entity rerouter;

architecture struct of rerouter is

	signal upper_route : complex_vector(0 to n / 2 - 1);
	signal lower_route : complex_vector(0 to n / 2 - 1);

	signal upper_rerouted : complex_vector(0 to n / 2 - 1);
	signal lower_rerouted : complex_vector(0 to n / 2 - 1);

begin

	setup_routes : process (x) is
	begin
		for i in 0 to n / 2 - 1 loop
			upper_route(i) <= x(2 * i);
			lower_route(i) <= x(2 * i + 1);
		end loop;
	end process setup_routes;

	output_routes : process (upper_rerouted, lower_rerouted) is
	begin
		y(0 to n / 2 - 1) <= upper_rerouted;
		y(n / 2 to n - 1) <= lower_rerouted;
	end process output_routes;

	simple_case : if n = 2 generate
		upper_rerouted <= upper_route;
		lower_rerouted <= lower_route;
	end generate simple_case;

	other_cases : if n /= 2 generate
		upper_rerouter : entity work.rerouter
			generic map (
				n => n / 2
			)
			port map (
				x => upper_route,
				y => upper_rerouted
			);
		lower_rerouter : entity work.rerouter
			generic map (
				n => n / 2
			)
			port map (
				x => lower_route,
				y => lower_rerouted
			);
	end generate other_cases;

end architecture struct;