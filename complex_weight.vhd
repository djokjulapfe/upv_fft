--------------------------------------------------------------------------------
-- Title       : Complex weight
-- Project     : FFT
-- File        : complex_weight.vhd
-- Authors     : Djordje & Dusan
-- Created     : Sun Dec  5
-- Version     : 1.0
-- Description : Multiplication component used after lower rank FFT components
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;
use work.weights.all;

--! Multiplies a #complex number by a weight
entity complex_weight is
    generic (
        n             : integer := 16;
        weight_choice : integer := 0
    );
    port (
        x_in  : in  complex;
        y_out : out complex
    );
end entity complex_weight;

--! Main architecture of #complex_weight
architecture dataflow of complex_weight is

    --! Result of multiplication
    signal mult_out : complex_double;

begin

    mult_out <= x_in * W(weight_choice * 2 * num_weights / n);

    -- Weights are stored with 2^weight_precision multiplication factor so the result must be 
    -- shifted by weight_precision to the right
    y_out <= (
            re => mult_out.re(word_size + weight_precision - 1 downto weight_precision),
            im => mult_out.im(word_size + weight_precision - 1 downto weight_precision)
    );

end architecture dataflow;
