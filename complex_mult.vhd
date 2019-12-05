library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity complex_mult is
    port (
        a, b : in  complex;
        x    : out complex
    );
end entity complex_mult;

architecture behav of complex_mult is
begin
    execute : process (a, b) is
        variable res_r : signed(2 * word_size - 1 downto 0);
        variable res_i : signed(2 * word_size - 1 downto 0);
    begin
        res_r := a.r * b.r - a.i * b.i;
        res_i := a.r * b.i + a.i * b.r;
        x.r   <= res_r(word_size - 1 downto 0);
        x.i   <= res_i(word_size - 1 downto 0);
    end process execute;
end architecture behav;
