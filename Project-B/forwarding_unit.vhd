library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity forwarding_unit is
	port (ex_mem_RegWrite : in std_logic;
	ex_mem_RegisterRd : in std_logic_vector(4 downto 0);
	mem_wb_RegisterRd : in std_logic_vector(4 downto 0);
	mem_wb_Regwrite : in std_logic;
	id_ex_RegisterRs : in std_logic_vector(4 downto 0);
	id_ex_RegisterRt : in std_logic_vector(4 downto 0);
	
	forwardA : out std_logic_vector(1 downto 0) := "00";
	forwardB : out Std_logic_vector(1 downto 0) := "00"
	);
	end forwarding_unit;
	
architecture mixed of forwarding_unit is

signal s_ForwardA : std_logic_vector(1 downto 0);
signal s_ForwardB : std_logic_vector(1 downto 0);

begin

process (ex_mem_RegWrite, ex_mem_RegisterRd, mem_wb_RegisterRd, mem_wb_Regwrite, id_ex_RegisterRs, id_ex_RegisterRt) is
begin
	s_ForwardA <= "00";
	s_ForwardB <= "00";

	if(ex_mem_RegWrite = '1') and (ex_mem_RegisterRd /= "00000") and (ex_mem_RegisterRd = id_ex_RegisterRs) then
		s_forwardA <= "10";
	end if;
	
	if ((ex_mem_RegWrite = '1') and (ex_mem_RegisterRd /= "00000") and (ex_mem_RegisterRd = id_ex_RegisterRt)) then
		s_forwardB <= "10";
	end if;
	
	if ((mem_wb_Regwrite = '1') and (mem_wb_RegisterRd /= "00000") and (ex_mem_RegisterRd /= id_ex_RegisterRs) and (mem_wb_RegisterRd = id_ex_RegisterRs)) then
		s_forwardA <= "01";
	end if;
	
	if ((mem_wb_Regwrite = '1') and (mem_wb_RegisterRd /= "00000") and (ex_mem_RegisterRd /= id_ex_RegisterRt) and (mem_wb_RegisterRd = id_ex_RegisterRt)) then
		s_forwardB <= "01";
	end if;

end process;
forwardA <= s_ForwardA;
forwardB <= s_ForwardB;
end mixed;