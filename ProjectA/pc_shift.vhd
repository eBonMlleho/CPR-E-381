library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- shifts the input "i_to_shift" by 2, and appends pcVal followed by the shifted input to the output the result in "o_shifted"
entity pc_shift is
  port( i_to_shift : in std_logic_vector(25 downto 0);
		pcVal : in std_logic_vector(3 downto 0);
  	    o_shifted : out std_logic_vector(31 downto 0));
 end pc_shift;

architecture mixed of pc_shift is 

begin

o_shifted <= pcVal & i_to_shift & "00";

end mixed;