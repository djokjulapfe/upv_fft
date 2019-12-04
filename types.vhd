library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
	-- number of bytes per word
	constant b : integer := 16;
	type complex is record
		r, i: integer;
	end record;
	type complex_vector is array (natural range <>) of complex;
end package types;
