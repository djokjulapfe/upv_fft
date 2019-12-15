--------------------------------------------------------------------------------
-- Title       : Rerouter
-- Project     : FFT
-- File        : rerouter.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  6
-- Version     : 1.0
-- Description : Component for reordering input of the radix 2 algorithm.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

--! Component for reordering input of the radix 2 algorithm.
entity rerouter is
	generic (
		--! Number of elements in the input and output
		n : integer := 2
	);
	port (
		--! Unordered input
		x : in complex_vector(0 to n - 1);
		--! Orderede output
		y : out complex_vector(0 to n - 1)
	);
end entity rerouter;

--! @brief Main architecture definition of #rerouter
--! @details Rerouting is done in a recursive fashion, where the signals are split by even and odd 
--! indices and then concatanated together.
architecture struct of rerouter is

	--! Even elements of the input signal
	signal upper_route : complex_vector(0 to n / 2 - 1);
	--! Odd elements of the input signal
	signal lower_route : complex_vector(0 to n / 2 - 1);

	--! Output of the upper lower level rerouter
	signal upper_rerouted : complex_vector(0 to n / 2 - 1);
	--! Output of the lower lower level rerouter
	signal lower_rerouted : complex_vector(0 to n / 2 - 1);

begin

	--! Splits the input to two paths by the oddity of items' indices
	setup_routes : process (x) is
	begin
		for i in 0 to n / 2 - 1 loop
			upper_route(i) <= x(2 * i);
			lower_route(i) <= x(2 * i + 1);
		end loop;
	end process setup_routes;

	--! Connects outputs of the lower lever rerouters to the outputs of the component
	output_routes : process (upper_rerouted, lower_rerouted) is
	begin
		y(0 to n / 2 - 1) <= upper_rerouted;
		y(n / 2 to n - 1) <= lower_rerouted;
	end process output_routes;

	--! In case n == 2, there is no rerouting
	simple_case : if n = 2 generate
		upper_rerouted <= upper_route;
		lower_rerouted <= lower_route;
	end generate simple_case;

	--! In case n != 2, generate lower level components
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