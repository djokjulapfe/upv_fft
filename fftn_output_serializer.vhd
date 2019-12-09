library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity fftn_output_serializer is
	generic (
		n : integer := 16
	);
	port (
		clk        : in  std_logic;
		reset      : in  std_logic;
		fftn_out   : in  complex_vector(0 to n - 1);
		start      : in  std_logic;
		data       : out std_logic_vector(word_size - 1 downto 0);
		data_ready : out std_logic
	);
end entity fftn_output_serializer;

architecture behav of fftn_output_serializer is

begin

	-- TODO: implement

end architecture behav;
