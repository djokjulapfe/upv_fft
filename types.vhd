library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is

    -- number of bits per word
    constant word_size : integer := 16;

    -- 256 * sqrt(2) / 2
    constant sqrt2 : signed(word_size - 1 downto 0) := to_signed(181, word_size);
    -- 256 * sqrt(2 + sqrt(2)) / 2
    constant sqrt2plus : signed(word_size - 1 downto 0) := to_signed(236, word_size);
    -- 256 * sqrt(2 - sqrt(2)) / 2
    constant sqrt2minus : signed(word_size - 1 downto 0) := to_signed(98, word_size);

    type complex is record
        r, i : signed(word_size - 1 downto 0);
    end record;
    type complex_vector is array (natural range <>) of complex;

    constant W : complex_vector(0 to 7) := (
            (to_signed(256, word_size), to_signed(0, word_size)),
            (sqrt2plus, -sqrt2minus),
            (sqrt2, -sqrt2),
            (sqrt2minus, -sqrt2plus),
            (to_signed(0, word_size), -to_signed(256, word_size)),
            (-sqrt2minus, -sqrt2plus),
            (-sqrt2, -sqrt2),
            (-sqrt2plus, -sqrt2minus)
        );
end package types;
