------------------------------------------------------------------------------------------------
--
--  DISTRIBUTED MEMPHIS  - version 5.0
--
--  Research group: GAPH-PUCRS    -    contact   fernando.moraes@pucrs.br
--
--  Distribution:  September 2013
--
--  Source name:  test_bench.vhd
--
--  Brief description:  Test bench.
--
------------------------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.memphis_pkg.all;
use work.standards.all;

--! @file
--! @ingroup vhdl_group
--! @{
--! @}

--! @brief entity brief description
 
--! @detailed detailed description
entity test_bench is
        
        --constant	log_file            : string := "output_master.txt"; --! port description
        constant	mlite_description   : string := "RTL";
     	constant	ram_description     : string := "RTL";
     	constant	router_description  : string := "RTL";
end;

architecture test_bench of test_bench is
	
	
        signal clock                      : std_logic := '0';
        signal reset                      : std_logic;
        
		-- IO signals connecting App Injector and Memphis
		signal memphis_injector_tx 		: std_logic;
 		signal memphis_injector_credit_i 	: std_logic;
	 	signal memphis_injector_data_out 	: regflit;
	 	
	 	signal memphis_injector_rx 		: std_logic;
 		signal memphis_injector_credit_o 	: std_logic;
	 	signal memphis_injector_data_in 	: regflit;
	 	
	 	-- Create the signals of your IO component here:
		signal memphis_test_peripheral_tx		: std_logic;
 		signal memphis_test_peripheral_credit_i	: std_logic;
	 	signal memphis_test_peripheral_data_out	: regflit;
	 	signal memphis_test_peripheral_rx		: std_logic;
 		signal memphis_test_peripheral_credit_o	: std_logic;
	 	signal memphis_test_peripheral_data_in	: regflit;

		signal memphis_wb_peripheral_tx		: std_logic;
 		signal memphis_wb_peripheral_credit_i	: std_logic;
	 	signal memphis_wb_peripheral_data_out	: regflit;
	 	signal memphis_wb_peripheral_rx		: std_logic;
 		signal memphis_wb_peripheral_credit_o	: std_logic;
	 	signal memphis_wb_peripheral_data_in	: regflit;

		signal wb_clock    : std_logic;
		signal wb_reset    : std_logic;
		signal wb_address  : std_logic_vector(7 downto 0);
		signal wb_data_i   : std_logic_vector(TAM_FLIT-1 downto 0);
		signal wb_data_o   : std_logic_vector(TAM_FLIT-1 downto 0);
		signal wb_write_en : std_logic;
		signal wb_stb      : std_logic;
		signal wb_ack      : std_logic;
		signal wb_cyc      : std_logic;
		signal wb_stall    : std_logic;
		
begin

	-- Peripheral 1 - Instantiation of App Injector 
	App_Injector : entity work.app_injector
	port map(
		clock        => clock,
		reset        => reset,
		
		rx			 => memphis_injector_tx,
		data_in		 => memphis_injector_data_out,
		credit_out   => memphis_injector_credit_i,
		
		tx			 => memphis_injector_rx,
		data_out	 => memphis_injector_data_in,
		credit_in	 => memphis_injector_credit_o
	);
	
	-- Peripheral 2 - Instantiate your IO component here:
	Test_Peripheral : entity work.test_peripheral
	port map(
		clock		=> clock,
		reset		=> reset,
		rx			=> memphis_test_peripheral_tx,
		data_in		=> memphis_test_peripheral_data_out,
		credit_out	=> memphis_test_peripheral_credit_i,
		tx			=> memphis_test_peripheral_rx,
		data_out	=> memphis_test_peripheral_data_in,
		credit_in	=> memphis_test_peripheral_credit_o
	);
	
   network_interface : entity work.network_interface
   port map (
      clock => clock,
      reset => reset,
      rx => memphis_wb_peripheral_tx,
      tx => memphis_wb_peripheral_rx,
      credit_in => memphis_wb_peripheral_credit_o,
      credit_out => memphis_wb_peripheral_credit_i,
      data_in => memphis_wb_peripheral_data_out,
      data_out => memphis_wb_peripheral_data_in,

      per_clock => wb_clock,
      per_reset => wb_reset,
      address => wb_address,
      data_i => wb_data_i,
      data_o => wb_data_o,
      write_en  => wb_write_en,
      stb => wb_stb,
      ack => wb_ack,
      cyc => wb_cyc,
      stall => wb_stall
   );

   wb_memory : entity work.wb_256x2_bytes_memory
   port map(
      clock => wb_clock,
      reset => wb_reset,
      adr_i => wb_address,
      dat_i => wb_data_o,
      dat_o => wb_data_i,
      we_i  => wb_write_en,
      stb_i => wb_stb,
      ack_o => wb_ack,
      cyc_i => wb_cyc,
      stall_o => wb_stall
   );


   --
   --  Memphis instantiation 
   --
   	Memphis : entity work.Memphis
	port map(
		clock 				=> clock,
		reset 				=> reset,
		
		-- Peripheral 1 - App Injector
		memphis_app_injector_tx 		=> memphis_injector_tx,
		memphis_app_injector_credit_i => memphis_injector_credit_i,
		memphis_app_injector_data_out => memphis_injector_data_out,
		
		memphis_app_injector_rx		=> memphis_injector_rx,
		memphis_app_injector_credit_o	=> memphis_injector_credit_o,
		memphis_app_injector_data_in 	=> memphis_injector_data_in,
		
		-- Peripheral 2 - Connect your IO component to Memphis here: 
		memphis_test_peripheral_tx			=> memphis_test_peripheral_tx,
		memphis_test_peripheral_credit_i	=> memphis_test_peripheral_credit_i,
		memphis_test_peripheral_data_out	=> memphis_test_peripheral_data_out,
		memphis_test_peripheral_rx			=> memphis_test_peripheral_rx,
		memphis_test_peripheral_credit_o	=> memphis_test_peripheral_credit_o,
		memphis_test_peripheral_data_in		=> memphis_test_peripheral_data_in,
		
		memphis_wb_peripheral_tx			=> memphis_wb_peripheral_tx,
		memphis_wb_peripheral_credit_i		=> memphis_wb_peripheral_credit_i,
		memphis_wb_peripheral_data_out		=> memphis_wb_peripheral_data_out,
		memphis_wb_peripheral_rx			=> memphis_wb_peripheral_rx,
		memphis_wb_peripheral_credit_o		=> memphis_wb_peripheral_credit_o,
		memphis_wb_peripheral_data_in		=> memphis_wb_peripheral_data_in
	);
	   
	   
	   
	reset     <= '1', '0' after 100 ns;
	-- 100 MHz
	clock     <= not clock after 5 ns;
	

end test_bench;
