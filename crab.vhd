library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity crab is
    port (
        crab_clk: in std_logic;
		dead: in std_logic_vector(6 downto 0); -- 1 means dead, 0 means alive. eventually evolve to a std_logic_vector with 1 bit per crab in the row
		rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
		columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
        crab_rgb: out std_logic_vector(5 downto 0);
		basepixel: in std_logic_vector(18 downto 0) -- concatenation of a 10 bit x coordinate and a 9 bit y coordinate
    );
end;

architecture synth of crab is

-- The following is a ROM made for displaying crabs. It might not actually synthesize as a ROM
-- the address is the row. the row is the top 8 bits of "rows" - "basepixel y coordinate". top 8 because it's all 10 divided by 4 to meet sizing goal.
-- the data out is an 11 bit standard logic vector
signal address: unsigned(7 downto 0); -- 8 bit
signal data : std_logic_vector(10 downto 0);
signal rgbit: std_logic;

begin
address <= rows(9 downto 2) - unsigned(basepixel (8 downto 1)); -- row counter minus basepixel y coordinate
process (crab_clk) is begin
	if rising_edge(crab_clk)then
		case address is
			when "00000000" => data <= "00100000100";
			when "00000001" => data <= "00010001000";
			when "00000010" => data <= "00111111100";
			when "00000011" => data <= "01101110110";
			when "00000100" => data <= "11111111111"; 
			when "00000101" => data <= "10111111101";
			when "00000110" => data <= "10100000101";
			when "00000111" => data <= "00011011000";
			when others => data <= "00000000000";
		end case;
		
		-- THIS IS THE FIRST, ORIGINAL CRAB.
		-- now we have a std_logic_vector. one bit is the export color
		if (dead(0) = '0') then -- if alive, then
			if (columns = 44 + unsigned(basepixel(18 downto 9))) then -- I'm not adding the full x coordinate because I want everything to stay in 4 pixel squares. drop the last 2 bits of 18 downto 9.
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(basepixel(18 downto 9))) then -- back when the crab didn't move far enough, I was taking bits 18 downto 11. that's only 8 out of 10 column bits.
					rgbit <= data(10);
				elsif (columns = 8 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(9);
				elsif (columns = 12 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(8);
				elsif (columns = 16 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(7);
				elsif (columns = 20 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(6);
				elsif (columns = 24 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(5);
				elsif (columns = 28 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(4);
				elsif (columns = 32 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(3);
				elsif (columns = 36 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(2);
				elsif (columns = 40 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(1);
				elsif (columns = 47 + unsigned(basepixel(18 downto 9))) then
					rgbit <= '0';
			end if;
		--else -- if dead, then
			--rgbit <= '0'; -- recall that, according to RGB_generator, crab_rgb only displays when rgbit = '1'.
		end if;
		
		-- THIS IS SPACE FOR A SECOND, EXPERIMENTAL CRAB
		if (dead(1) = '0') then
			if (columns = 44 + unsigned(basepixel(18 downto 9)) + 160) then -- adding additional x bits to push it to the right
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= data(10);
				elsif (columns = 8 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= data(9);
				elsif (columns = 12 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= data(8);
				elsif (columns = 16 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= data(7);
				elsif (columns = 20 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= data(6);
				elsif (columns = 24 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= data(5);
				elsif (columns = 28 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= data(4);
				elsif (columns = 32 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= data(3);
				elsif (columns = 36 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= data(2);
				elsif (columns = 40 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= data(1);
				elsif (columns = 47 + unsigned(basepixel(18 downto 9)) + 160) then
					rgbit <= '0';
			end if;
		end if;
		
				-- WE'VE GOT CRABS BABY
		if (dead(2) = '0') then
			if (columns = 44 + unsigned(basepixel(18 downto 9)) + 320) then -- adding additional x bits to push it to the right
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= data(10);
				elsif (columns = 8 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= data(9);
				elsif (columns = 12 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= data(8);
				elsif (columns = 16 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= data(7);
				elsif (columns = 20 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= data(6);
				elsif (columns = 24 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= data(5);
				elsif (columns = 28 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= data(4);
				elsif (columns = 32 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= data(3);
				elsif (columns = 36 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= data(2);
				elsif (columns = 40 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= data(1);
				elsif (columns = 47 + unsigned(basepixel(18 downto 9)) + 320) then
					rgbit <= '0';
			end if;
		end if;
				-- FOURTH CRAB FOR THE CRAB HARVEST
		if (dead(3) = '0') then
			if (columns = 44 + unsigned(basepixel(18 downto 9)) + 480) then -- adding additional x bits to push it to the right
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= data(10);
				elsif (columns = 8 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= data(9);
				elsif (columns = 12 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= data(8);
				elsif (columns = 16 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= data(7);
				elsif (columns = 20 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= data(6);
				elsif (columns = 24 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= data(5);
				elsif (columns = 28 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= data(4);
				elsif (columns = 32 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= data(3);
				elsif (columns = 36 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= data(2);
				elsif (columns = 40 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= data(1);
				elsif (columns = 47 + unsigned(basepixel(18 downto 9)) + 480) then
					rgbit <= '0';
			end if;
		end if;
		
		-----------------edit begins
		-- fifth CRAB (EDIT)
		if (dead(4) = '0') then
			if (columns = 44 + unsigned(basepixel(18 downto 9)) + 80) then -- adding additional x bits to push it to the right
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= data(10);
				elsif (columns = 8 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= data(9);
				elsif (columns = 12 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= data(8);
				elsif (columns = 16 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= data(7);
				elsif (columns = 20 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= data(6);
				elsif (columns = 24 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= data(5);
				elsif (columns = 28 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= data(4);
				elsif (columns = 32 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= data(3);
				elsif (columns = 36 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= data(2);
				elsif (columns = 40 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= data(1);
				elsif (columns = 47 + unsigned(basepixel(18 downto 9)) + 80) then
					rgbit <= '0';
			end if;
		end if;
		
		--6th
		if (dead(5) = '0') then
			if (columns = 44 + unsigned(basepixel(18 downto 9)) + 240) then -- adding additional x bits to push it to the right
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= data(10);
				elsif (columns = 8 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= data(9);
				elsif (columns = 12 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= data(8);
				elsif (columns = 16 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= data(7);
				elsif (columns = 20 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= data(6);
				elsif (columns = 24 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= data(5);
				elsif (columns = 28 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= data(4);
				elsif (columns = 32 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= data(3);
				elsif (columns = 36 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= data(2);
				elsif (columns = 40 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= data(1);
				elsif (columns = 47 + unsigned(basepixel(18 downto 9)) + 240) then
					rgbit <= '0';
			end if;
		end if;
		
		--7th
		if (dead(6) = '0') then
			if (columns = 44 + unsigned(basepixel(18 downto 9)) + 400) then -- adding additional x bits to push it to the right
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(basepixel(18 downto 9)) + 400) then
					rgbit <= data(10);
				elsif (columns = 8 + unsigned(basepixel(18 downto 9)) + 400) then
					rgbit <= data(9);
				elsif (columns = 12 + unsigned(basepixel(18 downto 9)) +400) then
					rgbit <= data(8);
				elsif (columns = 16 + unsigned(basepixel(18 downto 9)) + 400) then
					rgbit <= data(7);
				elsif (columns = 20 + unsigned(basepixel(18 downto 9)) +400) then
					rgbit <= data(6);
				elsif (columns = 24 + unsigned(basepixel(18 downto 9)) + 400) then
					rgbit <= data(5);
				elsif (columns = 28 + unsigned(basepixel(18 downto 9)) + 400) then
					rgbit <= data(4);
				elsif (columns = 32 + unsigned(basepixel(18 downto 9)) + 400) then
					rgbit <= data(3);
				elsif (columns = 36 + unsigned(basepixel(18 downto 9)) + 400) then
					rgbit <= data(2);
				elsif (columns = 40 + unsigned(basepixel(18 downto 9)) + 400) then
					rgbit <= data(1);
				elsif (columns = 47 + unsigned(basepixel(18 downto 9)) + 400) then
					rgbit <= '0';
			end if;
		end if;
		
		crab_rgb <= rgbit & rgbit & rgbit & rgbit & rgbit & rgbit;
		
	end if;
end process;

end;
