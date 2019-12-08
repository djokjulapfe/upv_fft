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