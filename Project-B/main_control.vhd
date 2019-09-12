library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity main_control is
  port( i_instruction : in std_logic_vector(31 downto 0);
  	    o_reg_dest : out std_logic;
  	    o_jump : out std_logic;
  	    o_branch : out std_logic;
  	    o_mem_to_reg : out std_logic;
  	    o_ALU_op : out std_logic_vector(3 downto 0);
  	    o_mem_write : out std_logic;
  	    o_ALU_src : out std_logic;
  	    o_reg_write : out std_logic
  	    );
 end main_control;

architecture mixed of main_control is 


	signal op_code : std_logic_vector(5 downto 0);
	signal func_code : std_logic_vector(5 downto 0);

begin


op_code <= i_instruction(31 downto 26);
func_code <= i_instruction(5 downto 0);

process(op_code, func_code)
begin

	case op_code is -- select instruction cases based on the instruction's OP code
	
		when "000000" => -- R-Type (must check function code)
			case func_code is
				when "100000" => -- ADD
					o_reg_dest <= '1'; -- write to rd
			  	    o_jump <= '0';
			  	    o_branch <= '0'; 
			  	    o_mem_to_reg <= '0'; -- write ALU output to reg file
			  	    o_ALU_op <= "0000"; -- addition operation in ALU
			  	    o_mem_write <= '0'; -- don't write to memory
			  	    o_ALU_src <= '0'; -- select rt data as second input to ALU
			  	    o_reg_write <= '1'; -- write enable to write register file (write rd)

			  	when others => -- any other cases are unimplemented R-type instructions (defaults to NOOP)
					o_reg_dest <= '0';
			  	    o_jump <= '0';
			  	    o_branch <= '0';
			  	    o_mem_to_reg <= '0';
			  	    o_ALU_op <= "0000";
			  	    o_mem_write <= '0';
			  	    o_ALU_src <= '0';
			  	    o_reg_write <= '0';
			end case;	
			
	  	-- TODO: add new instruction cases here

		 -- ADDI
		when "001000" => 
					 o_reg_dest <= '0'; -- not writing to rd
			  	    o_jump <= '0';
			  	    o_branch <= '0'; 
			  	    o_mem_to_reg <= '0'; -- write ALU output to reg file
			  	    o_ALU_op <= "0000"; -- addition operation in ALU
			  	    o_mem_write <= '0'; -- don't write to memory
			  	    o_ALU_src <= '1'; -- select sign extended IMM as second input
			  	    o_reg_write <= '1'; -- write enable to write register file (write rd)
					
		 -- LW			
		when "100011" => 
					 o_reg_dest <= '0'; -- not writing to rd
			  	    o_jump <= '0';
			  	    o_branch <= '0'; 
			  	    o_mem_to_reg <= '1'; -- write ALU output to reg file // should be 1 since we want to see the memory data
			  	    o_ALU_op <= "0000"; -- addition operation in ALU
			  	    o_mem_write <= '0'; -- don't write to memory
			  	    o_ALU_src <= '1'; -- select sign extended IMM as second input
			  	    o_reg_write <= '1'; -- write enable to write register file (write rd)

		 -- SW
		when "101011" => 
					 o_reg_dest <= '-'; -- don't care
			  	    o_jump <= '0';
			  	    o_branch <= '0'; 
			  	    o_mem_to_reg <= '-'; -- don't write ALU output to reg file (don't care)
			  	    o_ALU_op <= "0000"; -- addition operation in ALU
			  	    o_mem_write <= '1'; -- write to memory 
			  	    o_ALU_src <= '1'; -- select sign extended IMM as second input
			  	    o_reg_write <= '0'; -- don't write enable to write register file (write rd)
		
		 -- BEQ
		when "000100" =>
					 o_reg_dest <= '-'; -- dont write to rd, don't care
			  	    o_jump <= '0';
			  	    o_branch <= '1';
			  	    o_mem_to_reg <= '-'; -- don't write ALU output to reg file, don't care
			  	    o_ALU_op <= "0001"; -- subtraction operation in ALU
			  	    o_mem_write <= '0'; -- don't write to memory
			  	    o_ALU_src <= '0'; -- select rt data as second input to ALU
			  	    o_reg_write <= '0'; -- don't write enable to write register file (write rd)
		
		 -- J
		when "000010" =>
					 o_reg_dest <= '-'; -- don't care
			  	    o_jump <= '1';
			  	    o_branch <= '0'; 
			  	    o_mem_to_reg <= '-'; -- write ALU output to reg file
			  	    o_ALU_op <= "----"; -- addition operation in ALU // not sure about the add instruction
			  	    o_mem_write <= '0'; -- don't write to memory
			  	    o_ALU_src <= '-'; -- select rt data as second input to ALU
			  	    o_reg_write <= '0'; -- write enable to write register file (write rd)

	  	when others => -- any other cases are unimplemented instructions (defaults them to NOOP)
			o_reg_dest <= '0';
	  	    o_jump <= '0';
	  	    o_branch <= '0';
	  	    o_mem_to_reg <= '0';
	  	    o_ALU_op <= "0000";
	  	    o_mem_write <= '0';
	  	    o_ALU_src <= '0';
	  	    o_reg_write <= '0';
	end case;

end process;

end mixed;