library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux41_32bit is
  port( inp_00, inp_01, inp_10, inp_11 : in std_logic_vector(31 downto 0);
  		i_sel : in std_logic_vector(1 downto 0);
  	    o_put : out std_logic_vector(31 downto 0));
 end mux41_32bit;

architecture behavior of mux41_32bit is 

begin

with i_sel select
o_put <= inp_00 when "00",
	inp_01 when "01",
	inp_10 when "10",			
	inp_11 when others;

end behavior;