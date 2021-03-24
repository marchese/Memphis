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
signal tmp_write_adr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
signal tmp_read_adr : std_logic_vector(ADDRESS_LENGTH-1 downto 0);
signal s_dat_o : std_logic_vector(DATA_LENGTH-1 downto 0);
signal s_tx : std_logic := '0';
signal s_credit_out : std_logic := '0';

begin

	proc_report: process (reset, clock)
		variable msg : integer := 0;
	begin
		if rising_edge(clock) then
			if rx = '1' and s_credit_out = '1' then
				msg := msg + 1;
				report "Peripheral receiving msg(" & integer'image(msg) & ") = 0x" & to_hstring(unsigned(data_in));
			end if;
		end if;
	end process proc_report;

	-- Write to memory
	credit_out <= s_credit_out;
	write: process(reset, clock)
	begin
		if reset = '1' then
			tmp_write_adr <= (others => '0');
			s_credit_out <= '1';
		elsif rising_edge(clock) then
			if rx = '1' then
				buff(to_integer(unsigned(tmp_write_adr))) <= data_in;
			end if;
		end if;
	end process write;

	-- Read from memory
	data_out <= s_dat_o when credit_in = '1' else (others => '0');
	tx <= s_tx when credit_in = '1' and rx = '1' else '0';
	read: process(reset, clock)
	begin
		if reset = '1' then
			tmp_read_adr <= (others => '0');
		elsif rising_edge(clock) then
			if credit_in = '1' then
				s_dat_o <= buff(to_integer(unsigned(tmp_read_adr)));
				--s_tx <= '1';
			end if;
		end if;
	end process read;

end architecture main;