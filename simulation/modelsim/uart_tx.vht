-- Copyright (C) 2019  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "12/09/2019 23:21:26"
                                                            
-- Vhdl Test Bench template for design  :  uart_tx
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY uart_tx_vhd_tst IS
END uart_tx_vhd_tst;
ARCHITECTURE uart_tx_arch OF uart_tx_vhd_tst IS
-- constants 
CONSTANT clk_period : time := 0.02 ns;                                                
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL reset : STD_LOGIC;
SIGNAL tx_done : STD_LOGIC;
SIGNAL tx_in : STD_LOGIC_VECTOR(0 TO 15);
SIGNAL tx_out : STD_LOGIC;
SIGNAL tx_start : STD_LOGIC;
COMPONENT uart_tx
	PORT (
	clk : IN STD_LOGIC;
	reset : IN STD_LOGIC;
	tx_done : OUT STD_LOGIC;
	tx_in : IN STD_LOGIC_VECTOR(0 TO 15);
	tx_out : OUT STD_LOGIC;
	tx_start : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : uart_tx
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	reset => reset,
	tx_done => tx_done,
	tx_in => tx_in,
	tx_out => tx_out,
	tx_start => tx_start
	);
clk_gen : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        clk <= '1';
	WAIT FOR clk_period/2;
	clk <= '0';
	WAIT FOR clk_period/2;                                                    
END PROCESS clk_gen;                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        tx_start <= '0';
	tx_in <= "1001111001010011";
	WAIT FOR clk_period + clk_period/10;
	tx_start <= '1';
	WAIT FOR clk_period;
	tx_start <= '0';
WAIT;                                                        
END PROCESS always;                                          
END uart_tx_arch;
