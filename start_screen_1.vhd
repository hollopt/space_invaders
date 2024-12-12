library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity start is
    port (
        clk: in std_logic;
		status: in std_logic_vector(1 downto 0); -- state, 00 is start
		rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
		columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
        crab_rgb: out std_logic_vector(5 downto 0)
		--basepixel: in std_logic_vector(18 downto 0) -- concatenation of a 10 bit x coordinate and a 9 bit y coordinate
    );
end;

architecture synth of start is

-- The following is a ROM made for displaying start. It might not actually synthesize as a ROM.
-- the address is the row. the row is the top 8 bits of "rows" - "basepixel y coordinate". top 8 because it's all 10 divided by 4 to meet sizing goal.
-- the data out is a 76 bit standard logic vector
signal address: unsigned(7 downto 0); -- 8 bit
signal data : std_logic_vector(75 downto 0);
signal rgbit: std_logic;
signal basepixel: unsigned(18 downto 0);

begin
address <= rows(9 downto 2) - unsigned(basepixel (8 downto 1)); -- row counter minus basepixel y coordinate
basepixel <= 10d"175" & 9d"32";

process (clk) is begin
	if rising_edge(clk)then

		case address is
			when "00000000" => data <= "0001111110000000111111111100000000111111110000000011111111000000111111111111"; 
			when "00000001" => data <= "0111111111100000111111111110000001111111111000000111111111100000111111111111"; 
			when "00000010" => data <= "1111111111110000111111111111000001111111111000000111111111100000111111111111"; 
			when "00000011" => data <= "1111000011110000111000001111000011110000111100001111100011110000111000000000"; 
			when "00000100" => data <= "1110000001110000111000000111000011100000011100001111000001110000111000000000"; 
			when "00000101" => data <= "1110000000110000111000000111000011100000011100001111000000110000111000000000"; 
			when "00000110" => data <= "1110000000110000111000000111000011100000011100001110000000110000111000000000"; 
			when "00000111" => data <= "1110000000000000111000000111000011100000011100001110000000000000111000000000"; 
			when "00001000" => data <= "1111000000000000111000000111000011100000011100001110000000000000111000000000";
			when "00001001" => data <= "1111110000000000111000000111000011100000011100001110000000000000111000000000";
			when "00001010" => data <= "1111111100000000111000001111000011100000011100001110000000000000111000000000";
			when "00001011" => data <= "0111111110000000111111111111000011111111111100001110000000000000111111111000";
			when "00001100" => data <= "0011111111100000111111111110000011111111111100001110000000000000111111111000";
			when "00001101" => data <= "0000111111110000111111111100000011111111111100001110000000000000111111111000";
			when "00001110" => data <= "0000001111110000111000000000000011110000111100001110000000000000111000000000";
			when "00001111" => data <= "0000000011110000111000000000000011100000011100001110000000000000111000000000";
			when "00010000" => data <= "1100000001110000111000000000000011100000011100001110000000000000111000000000";
			when "00010001" => data <= "1100000001110000111000000000000011100000011100001110000000110000111000000000";
			when "00010010" => data <= "1110000001110000111000000000000011100000011100001111000000110000111000000000";
			when "00010011" => data <= "1110000001110000111000000000000011100000011100001111000001110000111000000000";
			when "00010100" => data <= "1111000011110000111000000000000011100000011100001111100011110000111000000000";
			when "00010101" => data <= "1111111111110000111000000000000011100000011100000111111111100000111111111111";
			when "00010110" => data <= "0111111111100000111000000000000011100000011100000111111111100000111111111111";
			when "00010111" => data <= "0001111110000000111000000000000011100000011100000011111111000000111111111111";
			when others => data <=     "0000000000000000000000000000000000000000000000000000000000000000000000000000";
		end case; 

-- TEMPORARY DISPLAY CONDITION -----
		if (status = "00" ) then -- you've killed everything, then
			if (columns = 304 + unsigned(basepixel(18 downto 9))) then -- I'm not adding the full x coordinate because I want everything to stay in 4 pixel squares. drop the last 2 bits of 18 downto 9.
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(basepixel(18 downto 9))) then -- back when the crab didn't move far enough, I was taking bits 18 downto 11. that's only 8 out of 10 column bits.
					rgbit <= data(75);
				elsif (columns = 8 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(74);
				elsif (columns = 12 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(73);
				elsif (columns = 16 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(72);
				elsif (columns = 20 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(71);
				elsif (columns = 24 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(70);
				elsif (columns = 28 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(69);
				elsif (columns = 32 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(68);
				elsif (columns = 36 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(67);
				elsif (columns = 40 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(66);
				elsif (columns = 44 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(65);
				elsif (columns = 48 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(64);
				elsif (columns = 52 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(63);
				elsif (columns = 56 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(62);
				elsif (columns = 60 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(61);
				elsif (columns = 64 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(60);
				elsif (columns = 68 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(59);
				elsif (columns = 72 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(58);
				elsif (columns = 76 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(57);
				elsif (columns = 80 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(56);
				elsif (columns = 84 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(55);
				elsif (columns = 88 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(54);
				elsif (columns = 92 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(53);
				elsif (columns = 96 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(52);
				elsif (columns = 100 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(51);
				elsif (columns = 104 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(50);
				elsif (columns = 108 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(49);
				elsif (columns = 112 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(48);
				elsif (columns = 116 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(47);
				elsif (columns = 120 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(46);
				elsif (columns = 124 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(45);
				elsif (columns = 128 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(44);
				elsif (columns = 132 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(43);
				elsif (columns = 136 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(42);
				elsif (columns = 140 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(41);
				elsif (columns = 144 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(40);
				elsif (columns = 148 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(39);
				elsif (columns = 152 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(38);
				elsif (columns = 156 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(37);
				elsif (columns = 160 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(36);
				elsif (columns = 164 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(35);
				elsif (columns = 168 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(34);
				elsif (columns = 172 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(33);
				elsif (columns = 176 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(32);
				elsif (columns = 180 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(31);
				elsif (columns = 184 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(30);
				elsif (columns = 188 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(29);
				elsif (columns = 192 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(28);
				elsif (columns = 196 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(27);
				elsif (columns = 200 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(26);
				elsif (columns = 204 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(25);
				elsif (columns = 208 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(24);
				elsif (columns = 212 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(23);
				elsif (columns = 216 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(22);
				elsif (columns = 220 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(21);
				elsif (columns = 224 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(20);
				elsif (columns = 228 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(19);
				elsif (columns = 232 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(18);
				elsif (columns = 236 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(17);
				elsif (columns = 240 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(16);
				elsif (columns = 244 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(15);
				elsif (columns = 248 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(14);
				elsif (columns = 252 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(13);
				elsif (columns = 256 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(12);
				elsif (columns = 260 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(11);
				elsif (columns = 264 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(10);
				elsif (columns = 268 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(9);
				elsif (columns = 272 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(8);
				elsif (columns = 276 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(7);
				elsif (columns = 280 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(6);
				elsif (columns = 284 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(5);
				elsif (columns = 288 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(4);
				elsif (columns = 292 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(3);
				elsif (columns = 296 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(2);
				elsif (columns = 300 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(1);
				
				elsif (columns = 307 + unsigned(basepixel(18 downto 9))) then
					rgbit <= '0';
			end if;
			 crab_rgb <= rgbit & rgbit & rgbit & rgbit & rgbit & rgbit;
		end if;

end if;
end process;
end;

