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
-- CREATED		"Thu Nov 02 07:44:32 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY Single_Cycle_MIPS_Processor IS 
	PORT
	(
		Clock :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		const4 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END Single_Cycle_MIPS_Processor;

ARCHITECTURE bdf_type OF Single_Cycle_MIPS_Processor IS 

COMPONENT alu
	PORT(ALU_OP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 ALU_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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

COMPONENT sign_extender_16_32
	PORT(i_to_extend : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT pc_shift
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
		 pcVal : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sll_2
	PORT(i_to_shift : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_shifted : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT adder_32
	PORT(i_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux21_32bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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

COMPONENT pc_reg
	PORT(CLK : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 i_next_PC : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 o_PC : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT and_2
	PORT(i_A : IN STD_LOGIC;
		 i_B : IN STD_LOGIC;
		 o_F : OUT STD_LOGIC
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

COMPONENT mux21_5bit
	PORT(i_sel : IN STD_LOGIC;
		 i_0 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 i_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 o_mux : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	ALU_out :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	instruc :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	PC4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	pcOut :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_28 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_29 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC_VECTOR(0 TO 31);
SIGNAL	SYNTHESIZED_WIRE_18 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_19 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_20 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_21 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_22 :  STD_LOGIC_VECTOR(0 TO 3);
SIGNAL	SYNTHESIZED_WIRE_24 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_25 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_26 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_27 :  STD_LOGIC;


BEGIN 
SYNTHESIZED_WIRE_15 <= '0';
SYNTHESIZED_WIRE_16 <= "1111";
SYNTHESIZED_WIRE_17 <= "00000000000000000000000000000000";
SYNTHESIZED_WIRE_22 <= "1111";



b2v_inst : alu
PORT MAP(ALU_OP => SYNTHESIZED_WIRE_0,
		 i_A => SYNTHESIZED_WIRE_1,
		 i_B => SYNTHESIZED_WIRE_2,
		 shamt => instruc(10 DOWNTO 6),
		 zero => SYNTHESIZED_WIRE_20,
		 ALU_out => ALU_out);


b2v_inst1 : main_control
PORT MAP(i_instruction => instruc,
		 o_reg_dest => SYNTHESIZED_WIRE_27,
		 o_jump => SYNTHESIZED_WIRE_24,
		 o_branch => SYNTHESIZED_WIRE_19,
		 o_mem_to_reg => SYNTHESIZED_WIRE_10,
		 o_mem_write => SYNTHESIZED_WIRE_21,
		 o_ALU_src => SYNTHESIZED_WIRE_12,
		 o_reg_write => SYNTHESIZED_WIRE_3,
		 o_ALU_op => SYNTHESIZED_WIRE_0);


b2v_inst10 : register_file
PORT MAP(CLK => Clock,
		 w_en => SYNTHESIZED_WIRE_3,
		 reset => reset,
		 rs_sel => instruc(25 DOWNTO 21),
		 rt_sel => instruc(20 DOWNTO 16),
		 w_data => SYNTHESIZED_WIRE_4,
		 w_sel => SYNTHESIZED_WIRE_5,
		 rs_data => SYNTHESIZED_WIRE_1,
		 rt_data => SYNTHESIZED_WIRE_29);


b2v_inst11 : sign_extender_16_32
PORT MAP(i_to_extend => instruc(15 DOWNTO 0),
		 o_extended => SYNTHESIZED_WIRE_28);


b2v_inst12 : pc_shift
PORT MAP(i_to_shift => instruc(25 DOWNTO 0),
		 pcVal => PC4(31 DOWNTO 28),
		 o_shifted => SYNTHESIZED_WIRE_26);


b2v_inst13 : sll_2
PORT MAP(i_to_shift => SYNTHESIZED_WIRE_28,
		 o_shifted => SYNTHESIZED_WIRE_7);


b2v_inst14 : adder_32
PORT MAP(i_A => PC4,
		 i_B => SYNTHESIZED_WIRE_7,
		 o_F => SYNTHESIZED_WIRE_9);


b2v_inst15 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_8,
		 i_0 => PC4,
		 i_1 => SYNTHESIZED_WIRE_9,
		 o_mux => SYNTHESIZED_WIRE_25);




b2v_inst18 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_10,
		 i_0 => ALU_out,
		 i_1 => SYNTHESIZED_WIRE_11,
		 o_mux => SYNTHESIZED_WIRE_4);


b2v_inst19 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_12,
		 i_0 => SYNTHESIZED_WIRE_29,
		 i_1 => SYNTHESIZED_WIRE_28,
		 o_mux => SYNTHESIZED_WIRE_2);


b2v_inst2 : imem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "imem.mif"
			)
PORT MAP(clock => Clock,
		 wren => SYNTHESIZED_WIRE_15,
		 address => pcOut(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_16,
		 data => SYNTHESIZED_WIRE_17,
		 q => instruc);




b2v_inst3 : pc_reg
PORT MAP(CLK => Clock,
		 reset => reset,
		 i_next_PC => SYNTHESIZED_WIRE_18,
		 o_PC => pcOut);


b2v_inst4 : adder_32
PORT MAP(i_A => pcOut,
		 i_B => const4,
		 o_F => PC4);


b2v_inst5 : and_2
PORT MAP(i_A => SYNTHESIZED_WIRE_19,
		 i_B => SYNTHESIZED_WIRE_20,
		 o_F => SYNTHESIZED_WIRE_8);


b2v_inst6 : dmem
GENERIC MAP(depth_exp_of_2 => 10,
			mif_filename => "dmem.mif"
			)
PORT MAP(clock => Clock,
		 wren => SYNTHESIZED_WIRE_21,
		 address => ALU_out(11 DOWNTO 2),
		 byteena => SYNTHESIZED_WIRE_22,
		 data => SYNTHESIZED_WIRE_29,
		 q => SYNTHESIZED_WIRE_11);


b2v_inst8 : mux21_32bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_24,
		 i_0 => SYNTHESIZED_WIRE_25,
		 i_1 => SYNTHESIZED_WIRE_26,
		 o_mux => SYNTHESIZED_WIRE_18);


b2v_inst9 : mux21_5bit
PORT MAP(i_sel => SYNTHESIZED_WIRE_27,
		 i_0 => instruc(20 DOWNTO 16),
		 i_1 => instruc(15 DOWNTO 11),
		 o_mux => SYNTHESIZED_WIRE_5);


END bdf_type;