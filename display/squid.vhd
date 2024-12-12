library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- this is a copypaste of the crab module except it makes its own basepixel instead of getting it from RGB_gen

entity squid is
    port (
        crab_clk: in std_logic;
		basepix: out std_logic_vector(18 downto 0); -- concatenation of a 10 bit x coordinate and a 9 bit y coordinate. 18 downto 9 is x
		dead: in std_logic_vector(4 downto 0);
		rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
		columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
		back: in unsigned (26 downto 0);
		forth: in unsigned(26 downto 0);
        squid_rgb: out std_logic_vector(5 downto 0)
    );
end;

architecture synth of squid is

-- the address is the row. the row is the top 8 bits of "rows" - "basepixel y coordinate". top 8 because it's all 10 divided by 4 to meet sizing goal.
-- the data out is an 11 bit standard logic vector
signal address: unsigned(7 downto 0); -- 8 bit
signal data : std_logic_vector(10 downto 0);
signal rgbit: std_logic;
--signal basepix : std_logic_vector(18 downto 0);

signal initialized: std_logic;


begin
--basepix <= std_logic_vector((unsigned(basepixel(18 downto 9)) + 10d"60") & (unsigned(basepixel(8 downto 0)) + 9d"74")); -- shift it away from crab
address <= rows(9 downto 2) - unsigned(basepix (8 downto 1)); -- row counter minus basepixel y coordinate
process (crab_clk) is begin
	if rising_edge(crab_clk)then
			
		-- chooses which direction the crab row is intended to be moving. reversed from crab, aka starts at the far right position
			if (forth > 27262977) then
				basepix <= "0" & std_logic_vector(back(26 downto 18) - 13631488) & "001001010"; -- moving forward. 148 pixels below top of screen.
			else
				basepix <= "0" & std_logic_vector(forth(26 downto 18) + 13631488) & "001001010"; -- moving backward
			end if;
			
	-- get the data
		case address is
			when "00000000" => data <= "00001110000";
			when "00000001" => data <= "00111111100";
			when "00000010" => data <= "01111111110";
			when "00000011" => data <= "01101110110";
			when "00000100" => data <= "01111111110";
			when "00000101" => data <= "00011011000";
			when "00000110" => data <= "01100000110";
			when "00000111" => data <= "11000000011";
			when others => data <= "00000000000";
		end case;
		
		-- now we have a std_logic_vector. one bit is the export color
		
		-- LEAD SQUID
	if (dead(0) = '0') then
		if (columns = 44 + unsigned(basepix(18 downto 9)) + 80) then -- I'm not addingf the full x coordinate because I want everything to stay in 4 pixel squares. drop the last 2 bits of 18 downto 9.
				rgbit <= data(0); --displayed from 0 to 4 clocks
			elsif (columns = 4 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= data(10);
			elsif (columns = 8 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= data(9);
			elsif (columns = 12 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= data(8);
			elsif (columns = 16 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= data(7);
			elsif (columns = 20 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= data(6);
			elsif (columns = 24 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= data(5);
			elsif (columns = 28 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= data(4);
			elsif (columns = 32 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= data(3);
			elsif (columns = 36 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= data(2);
			elsif (columns = 40 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= data(1);
			elsif (columns = 47 + unsigned(basepix(18 downto 9)) + 80) then
				rgbit <= '0';
			end if;
		end if;
			
		-- SECOND SQUID
	if(dead(1) = '0') then
		if (columns = 44 + unsigned(basepix(18 downto 9)) + 240) then -- I'm not addingf the full x coordinate because I want everything to stay in 4 pixel squares. drop the last 2 bits of 18 downto 9.
				rgbit <= data(0); --displayed from 0 to 4 clocks
			elsif (columns = 4 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= data(10);
			elsif (columns = 8 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= data(9);
			elsif (columns = 12 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= data(8);
			elsif (columns = 16 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= data(7);
			elsif (columns = 20 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= data(6);
			elsif (columns = 24 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= data(5);
			elsif (columns = 28 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= data(4);
			elsif (columns = 32 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= data(3);
			elsif (columns = 36 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= data(2);
			elsif (columns = 40 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= data(1);
			elsif (columns = 47 + unsigned(basepix(18 downto 9)) + 240) then
				rgbit <= '0';
			end if;
		end if;
			
		-- THIRD SQUID
		if(dead(2) = '0') then
			if (columns = 44 + unsigned(basepix(18 downto 9)) + 400) then -- I'm not addingf the full x coordinate because I want everything to stay in 4 pixel squares. drop the last 2 bits of 18 downto 9.
				rgbit <= data(0); --displayed from 0 to 4 clocks
			elsif (columns = 4 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= data(10);
			elsif (columns = 8 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= data(9);
			elsif (columns = 12 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= data(8);
			elsif (columns = 16 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= data(7);
			elsif (columns = 20 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= data(6);
			elsif (columns = 24 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= data(5);
			elsif (columns = 28 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= data(4);
			elsif (columns = 32 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= data(3);
			elsif (columns = 36 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= data(2);
			elsif (columns = 40 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= data(1);
			elsif (columns = 47 + unsigned(basepix(18 downto 9)) + 400) then
				rgbit <= '0';
			end if;
		end if;
			--4th squid --edit begins
		if (dead(3) = '0') then
			if (columns = 44 + unsigned(basepix(18 downto 9)) + 160) then -- I'm not addingf the full x coordinate because I want everything to stay in 4 pixel squares. drop the last 2 bits of 18 downto 9.
				rgbit <= data(0); --displayed from 0 to 4 clocks
			elsif (columns = 4 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= data(10);
			elsif (columns = 8 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= data(9);
			elsif (columns = 12 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= data(8);
			elsif (columns = 16 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= data(7);
			elsif (columns = 20 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= data(6);
			elsif (columns = 24 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= data(5);
			elsif (columns = 28 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= data(4);
			elsif (columns = 32 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= data(3);
			elsif (columns = 36 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= data(2);
			elsif (columns = 40 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= data(1);
			elsif (columns = 47 + unsigned(basepix(18 downto 9)) + 160) then
				rgbit <= '0';
			end if;
		end if;
		
		--5th squid
		if (dead(4) = '0') then
			if (columns = 44 + unsigned(basepix(18 downto 9)) + 320) then -- I'm not addingf the full x coordinate because I want everything to stay in 4 pixel squares. drop the last 2 bits of 18 downto 9.
				rgbit <= data(0); --displayed from 0 to 4 clocks
			elsif (columns = 4 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= data(10);
			elsif (columns = 8 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= data(9);
			elsif (columns = 12 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= data(8);
			elsif (columns = 16 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= data(7);
			elsif (columns = 20 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= data(6);
			elsif (columns = 24 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= data(5);
			elsif (columns = 28 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= data(4);
			elsif (columns = 32 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= data(3);
			elsif (columns = 36 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= data(2);
			elsif (columns = 40 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= data(1);
			elsif (columns = 47 + unsigned(basepix(18 downto 9)) + 320) then
				rgbit <= '0';
			end if;
		end if;
			
			squid_rgb <= rgbit & rgbit & rgbit & rgbit & rgbit & rgbit;
	end if;
end process;


end;
