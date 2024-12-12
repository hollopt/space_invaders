library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity nes is
	port(
	data : in std_logic;
	clk : in std_logic;
	human_speed_enable : out std_logic;
	copy_register : out std_logic_vector(7 downto 0);
	latch_to_controller : out std_logic;
	clk_to_controller : out std_logic
	);
end nes;

architecture synth of nes is

	component count is 
		port(
			clk : in std_logic;
			human_speed_enable : out std_logic;
			NESclk : out std_logic;
		    NEScount : out std_logic_vector(6 downto 0)
		); 
	end component;

signal latch : std_logic;
signal controller_clk : std_logic;
signal NES_clk : std_logic;
signal NES_count : std_logic_vector(6 downto 0);
signal data_register : std_logic_vector(7 downto 0);
signal data_done : std_logic;

begin

	
	instantiate : count port map(clk => clk, NESclk => NES_clk, NEScount => NES_count, human_speed_enable => human_speed_enable); --
	  latch <= '1' when NES_count(3 downto 0) = "1111" else '0'; -- gets 1 every 256 cycles
      --next 8 cycles we want to read the data
      controller_clk <= NES_clk when unsigned(NES_count(3 downto 0)) <  "1000" else '0';

		
		
	--create shift register to get data, only if controller clk is active
	process(controller_clk) is
	begin
		if rising_edge(controller_clk) then
			--first thing in register gets data, everything else gets shifted up
			data_register(0) <= data;
			data_register(7 downto 1) <= data_register(6 downto 0);
		end if;
	end process;
	
	--data done after nine cycles, aka when we hit cycle 1000
	data_done <= '1' when NES_count(3 downto 0) = "1000" else '0';
	
	
	--now copy this result into another register (only when we're done)
	process(data_done) is 
	begin
		if rising_edge(data_done) then --it's been 8 cycles so our data is done
			copy_register(7 downto 0) <= not data_register;
		end if;
	end process;
	
	latch_to_controller <= latch;
	clk_to_controller <= controller_clk;
	
end;
