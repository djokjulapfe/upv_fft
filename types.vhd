--------------------------------------------------------------------------------
-- Title       : Types
-- Project     : FFT
-- File        : types.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  4
-- Version     : 1.0
-- Description : Commonly used types around the project.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! Commonly used types around the project.
package types is

    --! Number of bits per word
    constant word_size : integer := 16;

    --! Number of bits representing the sqrt constans #sqrt2, #sqrt2plus and #sqrt2minus
    constant weight_precision : integer := 8;
    --! 256 * sqrt(2) / 2
    constant sqrt2 : signed(word_size - 1 downto 0) := to_signed(181, word_size);
    --! 256 * sqrt(2 + sqrt(2)) / 2
    constant sqrt2plus : signed(word_size - 1 downto 0) := to_signed(236, word_size);
    --! 256 * sqrt(2 - sqrt(2)) / 2
    constant sqrt2minus : signed(word_size - 1 downto 0) := to_signed(98, word_size);

    --! A type representing complex numbers with #word_size precision
    type complex is record
        --! Real part
        re : signed(word_size - 1 downto 0);
        --! Imaginary part
        im : signed(word_size - 1 downto 0);
    end record;

    --! A #complex with double precision.
    type complex_double is record
        --! Real part
        re : signed(2 * word_size - 1 downto 0);
        --! Imaginary part
        im : signed(2 * word_size - 1 downto 0);
    end record;
    --! Helper type for representing vectors of #complex numbers
    type complex_vector is array (natural range <>) of complex;

    --! Converts a pair of integers to a complex number
    --! @param re_arg The real part of the new complex number
    --! @param im_arg The real part of the new complex number
    --! @return The new complex number
    function pair2complex (
            re_arg, im_arg : integer
        ) return complex;

    --! Adds two #complex numbers
    --! @param a Addant
    --! @param b Adder
    --! @return Addition
    function "+"(
            a, b : complex
        ) return complex;

    --! Adds two #complex_double numbers
    --! @param a Addant
    --! @param b Adder
    --! @return Addition
    function "+"(
            a, b : complex_double
        ) return complex_double;

    --! Subtracts two #complex numbers
    --! @param a Subtractee
    --! @param b Subtractor
    --! @return Substraction
    function "-"(
            a, b : complex
        ) return complex;

    --! Subtracts two #complex_double numbers
    --! @param a Subtractee
    --! @param b Subtractor
    --! @return Substraction
    function "-"(
            a, b : complex_double
        ) return complex_double;

    --! Multiplies two #complex numbers
    --! @param a Multiplicant
    --! @param b Multiplier
    --! @return Multiplication
    function "*"(
            a, b : complex
        ) return complex_double;

    --! @brief Defines a mapping of indices to weight factors for rank 16 radix 2 fft.
    --! @details @f[W(i) = W_{16}^i = e^{-2*i*pi/16}@f]
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
    --! Converts a pair of integers to a complex number
    --! @param re_arg The real part of the new complex number
    --! @param im_arg The real part of the new complex number
    --! @return The new complex number
    function pair2complex (
            re_arg, im_arg : integer
        ) return complex is
    begin
        return (
            re => to_signed(re_arg, word_size),
            im => to_signed(im_arg, word_size)
        );
    end function pair2complex;

    --! Adds two #complex numbers
    --! @param a Addant
    --! @param b Adder
    --! @return Addition
    function "+"(
            a, b : complex
        ) return complex is
    begin
        return (
            re => a.re + b.re,
            im => a.im + b.im
        );
    end function "+";

    --! Adds two #complex_double numbers
    --! @param a Addant
    --! @param b Adder
    --! @return Addition
    function "+"(
            a, b : complex_double
        ) return complex_double is
    begin
        return (
            re => a.re + b.re,
            im => a.im + b.im
        );
    end function "+";

    --! Subtracts two #complex numbers
    --! @param a Subtractee
    --! @param b Subtractor
    --! @return Substraction
    function "-"(
            a, b : complex
        ) return complex is
    begin
        return (
            re => a.re - b.re,
            im => a.im - b.im
        );
    end function "-";

    --! Subtracts two #complex_double numbers
    --! @param a Subtractee
    --! @param b Subtractor
    --! @return Substraction
    function "-"(
            a, b : complex_double
        ) return complex_double is
    begin
        return (
            re => a.re - b.re,
            im => a.im - b.im
        );
    end function "-";

    --! Multiplies two #complex numbers
    --! @param a Multiplicant
    --! @param b Multiplier
    --! @return Multiplication
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