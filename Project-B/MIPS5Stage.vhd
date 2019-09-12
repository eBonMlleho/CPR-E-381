-- Copyright (C) 2016  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 16.1.0 Build 196 10/24/2016 SJ Standard Edition"
-- CREATED		"Thu Nov 16 10:18:30 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY MIPS5Stage IS 
	PORT
	(
		Clock :  IN  STD_LOGIC;
		Reset :  IN  STD_LOGIC;
		const4 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END MIPS5Stage;

ARCHITECTURE bdf_type OF MIPS5Stage IS 

COMPONENT adder_32
	PORT(i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu
	PORT(ALU_OP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mem_wb
	PORT(CLK : IN STD_LOGIC;
		 wb_flush : IN STD_LOGIC;
		 wb_stall : IN STD_LOGIC;
		 memwb_reset : IN STD_LOGIC;
		 mem_reg_dest : IN STD_LOGIC;
		 mem_mem_to_reg : IN STD_LOGIC;
		 mem_reg_write : IN STD_LOGIC;
		 mem_ALU_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_dmem_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_write_reg_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 wb_reg_dest : OUT STD_LOGIC;
		 wb_mem_to_reg : OUT STD_LOGIC;
		 wb_reg_write : OUT STD_LOGIC;
		 wb_ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_dmem_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 wb_write_reg_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dmem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT ex_mem
	PORT(CLK : IN STD_LOGIC;
		 mem_flush : IN STD_LOGIC;
		 mem_stall : IN STD_LOGIC;
		 exmem_reset : IN STD_LOGIC;
		 ex_reg_dest : IN STD_LOGIC;
		 ex_mem_to_reg : IN STD_LOGIC;
		 ex_mem_write : IN STD_LOGIC;
		 ex_reg_write : IN STD_LOGIC;
		 ex_ALU_out : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rt_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_write_reg_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 mem_reg_dest : OUT STD_LOGIC;
		 mem_mem_to_reg : OUT STD_LOGIC;
		 mem_mem_write : OUT STD_LOGIC;
		 mem_reg_write : OUT STD_LOGIC;
		 mem_ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 mem_write_reg_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc_reg
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 stall : IN STD_LOGIC;
		 i_next_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc_shift
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
		 pcVal : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT forwarding_unit
	PORT(ex_mem_RegWrite : IN STD_LOGIC;
		 mem_wb_Regwrite : IN STD_LOGIC;
		 ex_mem_RegisterRd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 id_ex_RegisterRs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 id_ex_RegisterRt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 mem_wb_RegisterRd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 forwardA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 forwardB : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_32bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT if_id
	PORT(CLK : IN STD_LOGIC;
		 id_flush : IN STD_LOGIC;
		 id_stall : IN STD_LOGIC;
		 ifid_reset : IN STD_LOGIC;
		 if_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 if_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT and_2
	PORT(i_A : IN STD_LOGIC;
		 i_B : IN STD_LOGIC;
		 o_F : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT mux21_5bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT register_file
	PORT(CLK : IN STD_LOGIC;
		 w_en : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 w_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 w_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 rs_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux41_32bit
	PORT(i_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 inp_00 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 inp_01 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 inp_10 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 inp_11 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_put : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sign_extender_16_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sll_2
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT main_control
	PORT(i_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_reg_dest : OUT STD_LOGIC;
		 o_jump : OUT STD_LOGIC;
		 o_branch : OUT STD_LOGIC;
		 o_mem_to_reg : OUT STD_LOGIC;
		 o_mem_write : OUT STD_LOGIC;
		 o_ALU_src : OUT STD_LOGIC;
		 o_reg_write : OUT STD_LOGIC;
		 o_ALU_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT branch_comparator
	PORT(i_rs_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_rt_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_equal : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT id_ex
	PORT(CLK : IN STD_LOGIC;
		 ex_flush : IN STD_LOGIC;
		 ex_stall : IN STD_LOGIC;
		 idex_reset : IN STD_LOGIC;
		 id_reg_dest : IN STD_LOGIC;
		 id_branch : IN STD_LOGIC;
		 id_mem_to_reg : IN STD_LOGIC;
		 id_mem_write : IN STD_LOGIC;
		 id_ALU_src : IN STD_LOGIC;
		 id_reg_write : IN STD_LOGIC;
		 id_ALU_op : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 id_extended_immediate : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_pc_plus_4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_rd_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 id_rs_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_rs_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 id_rt_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 id_rt_sel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_reg_dest : OUT STD_LOGIC;
		 ex_branch : OUT STD_LOGIC;
		 ex_mem_to_reg : OUT STD_LOGIC;
		 ex_mem_write : OUT STD_LOGIC;
		 ex_ALU_src : OUT STD_LOGIC;
		 ex_reg_write : OUT STD_LOGIC;
		 ex_ALU_op : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		 ex_extended_immediate : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_instruction : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_pc_plus_4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rd_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_rs_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rs_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ex_rt_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ex_rt_sel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

COMPONENT imem
GENERIC (depth_exp_of_2 : INTEGER;
			mif_filename : STRING
			);
	PORT(clock : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 byteena : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	ALU_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	id_ins :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	PC_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	pcOut :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_85 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_86 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_87 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_88 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_89 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_21 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_22 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_23 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_90 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_26 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_27 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_91 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_31 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_92 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_93 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_34 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_35 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_36 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_37 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_38 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_39 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_94 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_42 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_95 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_44 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_46 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_96 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_48 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_49 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_50 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_51 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_54 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_97 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_58 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_98 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_62 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_99 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_67 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_100 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_101 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_102 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_72 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_74 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_75 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_76 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_77 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_78 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_82 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_83 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_84 :  STD_LOGIC_VECTOR(0 TO 31);


BEGIN 
SYNTHESIZED_WIRE_85 <= '0';
SYNTHESIZED_WIRE_13 <= "1111";
SYNTHESIZED_WIRE_88 <= '0';
SYNTHESIZED_WIRE_26 <= '0';
SYNTHESIZED_WIRE_94 <= '0';
SYNTHESIZED_WIRE_102 <= '0';
SYNTHESIZED_WIRE_82 <= '0';
SYNTHESIZED_WIRE_83 <= "1111";
SYNTHESIZED_WIRE_84 <= "00000000000000000000000000000000";




b2v_inst1 : adder_32
PORT MAP(i_A => pcOut,
		 i_B => const4,
		 o_F => SYNTHESIZED_WIRE_95);


b2v_inst10 : alu
PORT MAP(ALU_OP => SYNTHESIZED_WIRE_0,
		 i_A => SYNTHESIZED_WIRE_1,
		 i_B => SYNTHESIZED_WIRE_2,
		 shamt => id_ins(10 DOWNTO 6),
		 ALU_out => SYNTHESIZED_WIRE_21);


b2v_inst11 : mem_wb
PORT MAP(CLK => Clock,
		 wb_flush => SYNTHESIZED_WIRE_85,
		 wb_stall => SYNTHESIZED_WIRE_85,
		 memwb_reset => Reset,
		 mem_reg_dest => SYNTHESIZED_WIRE_5,
		 mem_mem_to_reg => SYNTHESIZED_WIRE_6,
		 mem_reg_write => SYNTHESIZED_WIRE_86,
		 mem_ALU_out => ALU_out,
		 mem_dmem_out => SYNTHESIZED_WIRE_8,
		 mem_instruction => SYNTHESIZED_WIRE_9,
		 mem_pc_plus_4 => SYNTHESIZED_WIRE_10,
		 mem_write_reg_sel => SYNTHESIZED_WIRE_87,
		 wb_mem_to_reg => SYNTHESIZED_WIRE_37,
		 wb_reg_write => SYNTHESIZED_WIRE_91,
		 wb_ALU_out => SYNTHESIZED_WIRE_38,
		 wb_dmem_out => SYNTHESIZED_WIRE_39,
		 wb_write_reg_sel => SYNTHESIZED_WIRE_93);


b2v_inst12 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => Clock,
		 wren => SYNTHESIZED_WIRE_12,
		 address => ALU_out(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_13,
		 data => SYNTHESIZED_WIRE_14,
		 q => SYNTHESIZED_WIRE_8);


b2v_inst13 : ex_mem
PORT MAP(CLK => Clock,
		 mem_flush => SYNTHESIZED_WIRE_88,
		 mem_stall => SYNTHESIZED_WIRE_88,
		 exmem_reset => Reset,
		 ex_reg_dest => SYNTHESIZED_WIRE_89,
		 ex_mem_to_reg => SYNTHESIZED_WIRE_18,
		 ex_mem_write => SYNTHESIZED_WIRE_19,
		 ex_reg_write => SYNTHESIZED_WIRE_20,
		 ex_ALU_out => SYNTHESIZED_WIRE_21,
		 ex_instruction => SYNTHESIZED_WIRE_22,
		 ex_pc_plus_4 => SYNTHESIZED_WIRE_23,
		 ex_rt_data => SYNTHESIZED_WIRE_90,
		 ex_write_reg_sel => SYNTHESIZED_WIRE_25,
		 mem_reg_dest => SYNTHESIZED_WIRE_5,
		 mem_mem_to_reg => SYNTHESIZED_WIRE_6,
		 mem_mem_write => SYNTHESIZED_WIRE_12,
		 mem_reg_write => SYNTHESIZED_WIRE_86,
		 mem_ALU_out => ALU_out,
		 mem_instruction => SYNTHESIZED_WIRE_9,
		 mem_pc_plus_4 => SYNTHESIZED_WIRE_10,
		 mem_rt_data => SYNTHESIZED_WIRE_14,
		 mem_write_reg_sel => SYNTHESIZED_WIRE_87);


b2v_inst14 : pc_reg
PORT MAP(CLK => Clock,
		 reset => Reset,
		 stall => SYNTHESIZED_WIRE_26,
		 i_next_PC => SYNTHESIZED_WIRE_27,
		 o_PC => pcOut);


b2v_inst15 : pc_shift
PORT MAP(i_to_shift => id_ins(25 DOWNTO 0),
		 pcVal => PC_4(31 DOWNTO 28),
		 o_shifted => SYNTHESIZED_WIRE_36);


b2v_inst16 : forwarding_unit
PORT MAP(ex_mem_RegWrite => SYNTHESIZED_WIRE_86,
		 mem_wb_Regwrite => SYNTHESIZED_WIRE_91,
		 ex_mem_RegisterRd => SYNTHESIZED_WIRE_87,
		 id_ex_RegisterRs => SYNTHESIZED_WIRE_31,
		 id_ex_RegisterRt => SYNTHESIZED_WIRE_92,
		 mem_wb_RegisterRd => SYNTHESIZED_WIRE_93,
		 forwardA => SYNTHESIZED_WIRE_58,
		 forwardB => SYNTHESIZED_WIRE_62);


b2v_inst17 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_34,
		 i_0 => SYNTHESIZED_WIRE_35,
		 i_1 => SYNTHESIZED_WIRE_36,
		 o_mux => SYNTHESIZED_WIRE_27);


b2v_inst18 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_37,
		 i_0 => SYNTHESIZED_WIRE_38,
		 i_1 => SYNTHESIZED_WIRE_39,
		 o_mux => SYNTHESIZED_WIRE_97);



b2v_inst2 : if_id
PORT MAP(CLK => Clock,
		 id_flush => SYNTHESIZED_WIRE_94,
		 id_stall => SYNTHESIZED_WIRE_94,
		 ifid_reset => Reset,
		 if_instruction => SYNTHESIZED_WIRE_42,
		 if_pc_plus_4 => SYNTHESIZED_WIRE_95,
		 id_instruction => id_ins,
		 id_pc_plus_4 => PC_4);



b2v_inst21 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_44,
		 i_0 => SYNTHESIZED_WIRE_95,
		 i_1 => SYNTHESIZED_WIRE_46,
		 o_mux => SYNTHESIZED_WIRE_35);


b2v_inst22 : and_2
PORT MAP(i_A => SYNTHESIZED_WIRE_96,
		 i_B => SYNTHESIZED_WIRE_48,
		 o_F => SYNTHESIZED_WIRE_44);


b2v_inst23 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_49,
		 i_0 => SYNTHESIZED_WIRE_50,
		 i_1 => SYNTHESIZED_WIRE_51,
		 o_mux => SYNTHESIZED_WIRE_2);



b2v_inst25 : mux21_5bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_89,
		 i_0 => SYNTHESIZED_WIRE_92,
		 i_1 => SYNTHESIZED_WIRE_54,
		 o_mux => SYNTHESIZED_WIRE_25);






b2v_inst3 : register_file
PORT MAP(CLK => Clock,
		 w_en => SYNTHESIZED_WIRE_91,
		 reset => Reset,
		 rs_sel => id_ins(25 DOWNTO 21),
		 rt_sel => id_ins(20 DOWNTO 16),
		 w_data => SYNTHESIZED_WIRE_97,
		 w_sel => SYNTHESIZED_WIRE_93,
		 rs_data => SYNTHESIZED_WIRE_100,
		 rt_data => SYNTHESIZED_WIRE_101);


b2v_inst30 : mux41_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_58,
		 inp_00 => SYNTHESIZED_WIRE_98,
		 inp_01 => SYNTHESIZED_WIRE_97,
		 inp_10 => ALU_out,
		 inp_11 => SYNTHESIZED_WIRE_98,
		 o_put => SYNTHESIZED_WIRE_1);


b2v_inst31 : mux41_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_62,
		 inp_00 => SYNTHESIZED_WIRE_90,
		 inp_01 => SYNTHESIZED_WIRE_97,
		 inp_10 => ALU_out,
		 inp_11 => SYNTHESIZED_WIRE_90,
		 o_put => SYNTHESIZED_WIRE_50);


b2v_inst4 : sign_extender_16_32
PORT MAP(i_to_extend => id_ins(15 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_99);


b2v_inst5 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_99,
		 o_shifted => SYNTHESIZED_WIRE_67);


b2v_inst6 : adder_32
PORT MAP(i_A => PC_4,
		 i_B => SYNTHESIZED_WIRE_67,
		 o_F => SYNTHESIZED_WIRE_46);


b2v_inst7 : main_control
PORT MAP(i_instruction => id_ins,
		 o_reg_dest => SYNTHESIZED_WIRE_72,
		 o_jump => SYNTHESIZED_WIRE_34,
		 o_branch => SYNTHESIZED_WIRE_96,
		 o_mem_to_reg => SYNTHESIZED_WIRE_74,
		 o_mem_write => SYNTHESIZED_WIRE_75,
		 o_ALU_src => SYNTHESIZED_WIRE_76,
		 o_reg_write => SYNTHESIZED_WIRE_77,
		 o_ALU_op => SYNTHESIZED_WIRE_78);


b2v_inst8 : branch_comparator
PORT MAP(i_rs_data => SYNTHESIZED_WIRE_100,
		 i_rt_data => SYNTHESIZED_WIRE_101,
		 o_equal => SYNTHESIZED_WIRE_48);


b2v_inst9 : id_ex
PORT MAP(CLK => Clock,
		 ex_flush => SYNTHESIZED_WIRE_102,
		 ex_stall => SYNTHESIZED_WIRE_102,
		 idex_reset => Reset,
		 id_reg_dest => SYNTHESIZED_WIRE_72,
		 id_branch => SYNTHESIZED_WIRE_96,
		 id_mem_to_reg => SYNTHESIZED_WIRE_74,
		 id_mem_write => SYNTHESIZED_WIRE_75,
		 id_ALU_src => SYNTHESIZED_WIRE_76,
		 id_reg_write => SYNTHESIZED_WIRE_77,
		 id_ALU_op => SYNTHESIZED_WIRE_78,
		 id_extended_immediate => SYNTHESIZED_WIRE_99,
		 id_instruction => id_ins,
		 id_pc_plus_4 => PC_4,
		 id_rd_sel => id_ins(15 DOWNTO 11),
		 id_rs_data => SYNTHESIZED_WIRE_100,
		 id_rs_sel => id_ins(25 DOWNTO 21),
		 id_rt_data => SYNTHESIZED_WIRE_101,
		 id_rt_sel => id_ins(20 DOWNTO 16),
		 ex_reg_dest => SYNTHESIZED_WIRE_89,
		 ex_mem_to_reg => SYNTHESIZED_WIRE_18,
		 ex_mem_write => SYNTHESIZED_WIRE_19,
		 ex_ALU_src => SYNTHESIZED_WIRE_49,
		 ex_reg_write => SYNTHESIZED_WIRE_20,
		 ex_ALU_op => SYNTHESIZED_WIRE_0,
		 ex_extended_immediate => SYNTHESIZED_WIRE_51,
		 ex_instruction => SYNTHESIZED_WIRE_22,
		 ex_pc_plus_4 => SYNTHESIZED_WIRE_23,
		 ex_rd_sel => SYNTHESIZED_WIRE_54,
		 ex_rs_data => SYNTHESIZED_WIRE_98,
		 ex_rs_sel => SYNTHESIZED_WIRE_31,
		 ex_rt_data => SYNTHESIZED_WIRE_90,
		 ex_rt_sel => SYNTHESIZED_WIRE_92);



b2v_inst98 : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => Clock,
		 wren => SYNTHESIZED_WIRE_82,
		 address => pcOut(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_83,
		 data => SYNTHESIZED_WIRE_84,
		 q => SYNTHESIZED_WIRE_42);


END bdf_type;