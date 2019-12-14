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
-- Generated on "12/10/2019 12:42:52"
                                                            
-- Vhdl Test Bench template for design  :  uart_rx
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY uart_rx_vhd_tst IS
END uart_rx_vhd_tst;
ARCHITECTURE uart_rx_arch OF uart_rx_vhd_tst IS
-- constants   
CONSTANT clk_period : time :=  10 ns;                                              
-- signals                                                   
SIGNAL clk : STD_LOGIC;
SIGNAL reset : STD_LOGIC;
SIGNAL rx_done : STD_LOGIC;
SIGNAL rx_in : STD_LOGIC;
SIGNAL rx_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
COMPONENT uart_rx
	PORT (
	clk : IN STD_LOGIC;
	reset : IN STD_LOGIC;
	rx_done : OUT STD_LOGIC;
	rx_in : IN STD_LOGIC;
	rx_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : uart_rx
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	reset => reset,
	rx_done => rx_done,
	rx_in => rx_in,
	rx_out => rx_out
	);
clk_gen : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
	clk <= '1';
	wait for clk_period/2;
	clk <= '0';
	wait for clk_period/2;
END PROCESS clk_gen;                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN   
	-- drive input high                                                      
   rx_in <= '1';
	reset <= '1';
	wait for clk_period * 500 + clk_period/2;
	reset <= '0';
	wait for clk_period * 500;
	-- send start bit
	rx_in <= '0';
	wait for 2604*clk_period;

	rx_in <= '1';
	wait for 2604*clk_period;
	rx_in <= '0';
	wait for 2604*clk_period;
	rx_in <= '0';
	wait for 2604*clk_period;
	rx_in <= '1';
	wait for 2604*clk_period;
	rx_in <= '1';
	wait for 2604*clk_period;
	rx_in <= '0';
	wait for 2604*clk_period;
	rx_in <= '0';
	wait for 2604*clk_period;
	rx_in <= '1';
	wait for 2604*clk_period;
	
	-- send stop bit
	rx_in <= '1';
	wait for 26040*clk_period;
	-- send start bit
	rx_in <= '0';
	wait for 2604*clk_period;
	
	rx_in <= '1';
	wait for 2604*clk_period; 
	rx_in <= '0';
	wait for 2604*clk_period;
	rx_in <= '1';
	wait for 2604*clk_period;
	rx_in <= '0';
	wait for 2604*clk_period;
	rx_in <= '1';
	wait for 2604*clk_period;
	rx_in <= '0';
	wait for 2604*clk_period;
	rx_in <= '1';
	wait for 2604*clk_period;
	rx_in <= '0';
	wait for 2604*clk_period;
	
	-- drive input high
	rx_in <= '1';
	
	wait for 26040*clk_period;

	-- send start bit
	rx_in <= '0';
	wait for 2604*clk_period;
	
	rx_in <= '1';
	wait for 2604*clk_period; 
	rx_in <= '0';
	wait for 2604*clk_period;
	rx_in <= '1';
	wait for 2604*clk_period;
	rx_in <= '0';
	wait for 2604*clk_period;
	rx_in <= '1';
	wait for 2604*clk_period;
	rx_in <= '0';
	wait for 2604*clk_period;
	rx_in <= '1';
	wait for 2604*clk_period;
	rx_in <= '0';
	wait for 2604*clk_period;
	
	rx_in <= '1';
WAIT;                                                        
END PROCESS always;                                          
END uart_rx_arch;
