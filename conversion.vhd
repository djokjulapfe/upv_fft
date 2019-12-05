library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

package conversion is
	function pair2complex (
			r_arg, i_arg : integer
		) return complex;
end package conversion;

package body conversion is
	function pair2complex (
			r_arg, i_arg : integer
		) return complex is
	begin
		return (
			r => to_signed(r_arg, word_size),
			i => to_signed(i_arg, word_size)
		);
	end function pair2complex;
end package body conversion;
