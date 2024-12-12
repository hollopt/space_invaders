library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity count is
  port(
		clk : in std_logic; --25.27MHz 
		human_speed_enable : out std_logic;
        NESclk : out std_logic;
	    NEScount : out std_logic_vector(6 downto 0)
  );
end count;

architecture synth of count is

signal counter : unsigned(25 downto 0); --
--signal human_speed_counter : unsigned (18 downto 0);



begin

-- wire up outputs 
NESclk <= std_logic(counter(17)); --will be .5MHz, should be enough for the NES controller
NEScount <= std_logic_vector(counter(24 downto 18));
human_speed_enable <= '1' when counter(18 downto 0) >= "01111111111111111111" else '0'; --high every .02s, we can increment things on this scale

--counter!
process (clk) is
begin
    if rising_edge(clk) then
    --count on each rising edge

		counter <= counter + 20b"1";
		
	
    end if;
end process;
end;
