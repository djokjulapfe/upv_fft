library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is

    -- number of bits per word
    constant word_size : integer := 16;

    -- number of bits representing the next three constants
    constant weight_precision : integer := 8; 
    -- 256 * sqrt(2) / 2
    constant sqrt2 : signed(word_size - 1 downto 0) := to_signed(181, word_size);
    -- 256 * sqrt(2 + sqrt(2)) / 2
    constant sqrt2plus : signed(word_size - 1 downto 0) := to_signed(236, word_size);
    -- 256 * sqrt(2 - sqrt(2)) / 2
    constant sqrt2minus : signed(word_size - 1 downto 0) := to_signed(98, word_size);

    type complex is record
        re, im : signed(word_size - 1 downto 0);
    end record;
    type complex_double is record
        re, im : signed(2 * word_size - 1 downto 0);
    end record;
    type complex_vector is array (natural range <>) of complex;


    function pair2complex (
            re_arg, im_arg : integer
        ) return complex;
    function "+"(
            a, b : complex
        ) return complex;
    function "+"(
            a, b : complex_double
        ) return complex_double;
    function "-"(
            a, b : complex
        ) return complex;
    function "-"(
            a, b : complex_double
        ) return complex_double;
    function "*"(
            a, b : complex
        ) return complex_double;

    -- W(i) = W_8^i
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

package body types is
    function pair2complex (
            re_arg, im_arg : integer
        ) return complex is
    begin
        return (
            re => to_signed(re_arg, word_size),
            im => to_signed(im_arg, word_size)
        );
    end function pair2complex;

    function "+"(
            a, b : complex
        ) return complex is
    begin
        return (
            re => a.re + b.re,
            im => a.im + b.im
        );
    end function "+";

    function "+"(
            a, b : complex_double
        ) return complex_double is
    begin
        return (
            re => a.re + b.re,
            im => a.im + b.im
        );
    end function "+";

    function "-"(
            a, b : complex
        ) return complex is
    begin
        return (
            re => a.re - b.re,
            im => a.im - b.im
        );
    end function "-";

    function "-"(
            a, b : complex_double
        ) return complex_double is
    begin
        return (
            re => a.re - b.re,
            im => a.im - b.im
        );
    end function "-";

    function "*"(
            a, b : complex
        ) return complex_double is
    begin
        return (
            a.re * b.re - a.im * b.im,
            a.re * b.im + a.im * b.re
        );
    end function "*";
end package body types;