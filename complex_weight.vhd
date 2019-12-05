library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.types.all;

entity complex_weight is
    port (
        x_in          : in  complex;
        weight_choice : in  integer range 0 to 7;
        y_out         : out complex
    );
end entity complex_weight;

architecture dataflow of complex_weight is

    signal selected_weight : complex;
    signal mult_out        : complex_double;

begin

    selected_weight <= W(weight_choice);
    mult_out        <= x_in * selected_weight;

    y_out <= (
            re => mult_out.re(word_size + weight_precision - 1 downto weight_precision),
            im => mult_out.im(word_size + weight_precision - 1 downto weight_precision)
    );

end architecture dataflow;
