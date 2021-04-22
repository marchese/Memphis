library ieee;
use ieee.std_logic_1164.all;
use work.standards.all;
use ieee.numeric_std.all;

entity test_peripheral is
	generic(
		MEMORY_SIZE		: integer := 16;
		ADDRESS_LENGTH	: integer := 8;
		DATA_LENGTH		: integer := TAM_FLIT
	);
	port(
		clock : in std_logic;
		reset : in std_logic;

		-- NOC interface
		rx : in std_logic;
		tx : out std_logic;
		credit_in : in std_logic;
		credit_out : out std_logic;
		data_in : in regflit;
		data_out : out regflit
	);
end;

architecture main of test_peripheral is

type t_buffer is array (0 to MEMORY_SIZE-1) of std_logic_vector(DATA_LENGTH-1 downto 0);
signal buff : t_buffer := (others => (others => '0'));
signal s_data_out : std_logic_vector(DATA_LENGTH-1 downto 0) := (others => '0');
signal s_tx : std_logic := '0';
signal s_credit_out : std_logic := '0';
signal trigger_ack : std_logic := '0';
signal write_pos : integer := 0;
signal ack_pos : integer := 0;

begin

	-- Write to memory
	credit_out <= s_credit_out;
	write: process(reset, clock)
	begin
		if reset = '1' then
			write_pos <= 0;
			s_credit_out <= '1';
		elsif rising_edge(clock) then
			if rx = '1' then
				buff(write_pos) <= data_in;
				report "Receiving 0x" & to_hstring(unsigned(data_in)) & ", position " & to_string(write_pos);
				write_pos <= write_pos + 1;
			end if;
		end if;
	end process write;

	send_ack: process(reset, clock)
	begin
		if reset = '1' then
			ack_pos <= 0;
			trigger_ack <= '0';
		elsif rising_edge(clock) then
			if write_pos = 2 and data_in = x"00000400" then
				report "Request received";
				report "Sending ACK";
				trigger_ack <= '1';
			end if;

			if trigger_ack = '1' then
				if credit_in = '1' then
					if ack_pos = 12 then
						trigger_ack <= '0';
						ack_pos <= 0;
					else
						ack_pos <= ack_pos + 1;
					end if;
				end if;
			end if;

			if trigger_ack = '1' and credit_in = '1' and tx = '1' then
				report "Sending ACK 0x" & to_hstring(unsigned(s_data_out)) & ", position " & to_string(ack_pos);
			end if;

		end if;
	end process send_ack;

	-- Read from memory
	data_out <= s_data_out when trigger_ack = '1' else (others => '0');
	tx <= '1' when trigger_ack = '1' else '0';

	s_data_out <=	 x"00000100" when ack_pos = 0
				else x"0000000B" when ack_pos = 1
				else x"00000410" when ack_pos = 2
				else x"80000101" when ack_pos = 3
				else x"00000000" when ack_pos = 4
				else (others => '0');

	-- read: process(reset, clock)
	-- begin
	-- 	if reset = '1' then
	-- 		read_pos := 0;
	-- 		s_credit_out <= '1';
	-- 	elsif rising_edge(clock) then
	-- 		if credit_in = '1' and trigger_read = '1' then
	-- 			s_data_out = buff(read_pos);
	-- 			report "Reading 0x" & to_hstring(unsigned(data_in)) & " to position " & to_string(write_pos);
	-- 			write_pos := write_pos + 1;
	-- 		end if;
	-- 	end if;
	-- end process read;

end architecture main;