library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity start2 is
    port (
        clk: in std_logic;
		status: in std_logic_vector(1 downto 0); -- state, 00 is start
		rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
		columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
        srt2_rgb: out std_logic_vector(5 downto 0)
    );
end;

architecture synth of start2 is

-- The following is a ROM made for displaying start. It might not actually synthesize as a ROM.
-- the address is the row. the row is the top 8 bits of "rows" - "basepixel y coordinate". top 8 because it's all 10 divided by 4 to meet sizing goal.
-- the data out is a 76 bit standard logic vector
signal address: unsigned(7 downto 0); -- 8 bit
signal data : std_logic_vector(123 downto 0);
signal rgbit: std_logic;
signal basepixel: unsigned(18 downto 0);

begin
address <= rows(9 downto 2) - unsigned(basepixel (8 downto 1)); -- row counter minus basepixel y coordinate
basepixel <= 10d"75" & 9d"110";

process (clk) is begin
	if rising_edge(clk)then

		case address is
		when "00000000" => data <= "1111111111110000110000000001000010000000000100000000011000000000111111000000000000111111110000001110000000000000000011110000"; 
		when "00000001" => data <= "0011111111000000111000000011000011000000001100000000011000000000111111110000000001111111111000001111100000000000001111111100"; 
		when "00000010" => data <= "0001111110000000111000000011000011000000001100000001111110000000111111111000000001111000011100001111111000000000011111111110"; 
		when "00000011" => data <= "0000111100000000111100000011000011000000001100000001111110000000111000111100000011110000000100001111111110000000011100011110"; 
		when "00000100" => data <= "0000111100000000111100000111000011100000011100000011111111000000111000011110000011100000000000001110011111000000111000000111"; 
		when "00000101" => data <= "0000111100000000111110000111000011100000011100000011100111000000111000001110000011100000000000001110000111100000111000000011"; 
		when "00000110" => data <= "0000111100000000111110000111000011100000011100000111000011100000111000000111000011100000000000001110000001110000111000000001"; 
		when "00000111" => data <= "0000111100000000111111000111000011100000011100000111000011100000111000000111000011100000000000001110000001110000111000000001"; 
		when "00001000" => data <= "0000111100000000111111000111000011100000011100000111000011100000111000000011000011100000000000001110000111100000111100000000";
		when "00001001" => data <= "0000111100000000111111100111000011100000011100001111000011110000111000000011000011100000000000001110011111000000111110000000";
		when "00001010" => data <= "0000111100000000111111100111000011100000011100001111000011110000111000000011000011110000000000001111111110000000011111000000";
		when "00001011" => data <= "0000111100000000111011110111000011110000111100001111111111110000111000000011000011111111000000001111111000000000001111100000";
		when "00001100" => data <= "0000111100000000111011110111000001110000111000001111111111110000111000000011000011111111110000001111111000000000000111111000";
		when "00001101" => data <= "0000111100000000111001111111000001110000111000001111111111110000111000000011000011111111000000001110111100000000000001111110";
		when "00001110" => data <= "0000111100000000111001111111000001110000111000001111000011110000111000000011000011110000000000001110011110000000000000011111";
		when "00001111" => data <= "0000111100000000111000111111000000110000110000001110000001110000111000000011000011100000000000001110001110000000100000001111";
		when "00010000" => data <= "0000111100000000111000111111000000111001110000001110000001110000111000000111000011100000000000001110000111000000100000000111";
		when "00010001" => data <= "0000111100000000111000011111000000111001110000001110000001110000111000000111000011100000000000001110000011000000110000000111";
		when "00010010" => data <= "0000111100000000111000011111000000011001100000001110000001110000111000001110000011100000000000001110000011100000110000000111";
		when "00010011" => data <= "0000111100000000111000001111000000011001100000001110000001110000111000011110000011100000000000001100000001100000111000000111";
		when "00010100" => data <= "0000111100000000110000001111000000011111100000001100000000110000111000111100000011110000000100001100000000110000111110001111";
		when "00010101" => data <= "0001111110000000110000000111000000001111000000001100000000110000111111111000000001111000011100001100000000110000011111111110";
		when "00010110" => data <= "0011111111000000110000000111000000001111000000001100000000110000111111110000000001111111111000001000000000010000001111111100";
		when "00010111" => data <= "1111111111110000100000000011000000000110000000001000000000010000111111000000000000111111110000001000000000010000000011110000";
		when others => data <=     "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
		end case; 


-- TEMPORARY DISPLAY CONDITION -----
		if (status = "00" ) then -- you've killed everything, then
			if (columns = 496 + unsigned(basepixel(18 downto 9))) then -- I'm not adding the full x coordinate because I want everything to stay in 4 pixel squares. drop the last 2 bits of 18 downto 9.
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(basepixel(18 downto 9))) then -- back when the crab didn't move far enough, I was taking bits 18 downto 11. that's only 8 out of 10 column bits.
					rgbit <= data(123);
				elsif (columns = 8 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(122);
				elsif (columns = 12 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(121);
				elsif (columns = 16 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(120);
				elsif (columns = 20 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(119);
				elsif (columns = 24 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(118);
				elsif (columns = 28 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(117);
				elsif (columns = 32 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(116);
				elsif (columns = 36 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(115);
				elsif (columns = 40 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(114);
				elsif (columns = 44 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(113);
				elsif (columns = 48 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(112);
				elsif (columns = 52 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(111);
				elsif (columns = 56 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(110);
				elsif (columns = 60 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(109);
				elsif (columns = 64 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(108);
				elsif (columns = 68 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(107);
				elsif (columns = 72 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(106);
				elsif (columns = 76 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(105);
				elsif (columns = 80 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(104);
				elsif (columns = 84 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(103);
				elsif (columns = 88 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(102);
				elsif (columns = 92 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(101);
				elsif (columns = 96 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(100);
				elsif (columns = 100 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(99);
				elsif (columns = 104 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(98);
				elsif (columns = 108 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(97);
				elsif (columns = 112 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(96);
				elsif (columns = 116 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(95);
				elsif (columns = 120 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(94);
				elsif (columns = 124 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(93);
				elsif (columns = 128 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(92);
				elsif (columns = 132 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(91);
				elsif (columns = 136 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(90);
				elsif (columns = 140 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(89);
				elsif (columns = 144 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(88);
				elsif (columns = 148 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(87);
				elsif (columns = 152 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(86);
				elsif (columns = 156 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(85);
				elsif (columns = 160 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(84);
				elsif (columns = 164 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(83);
				elsif (columns = 168 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(82);
				elsif (columns = 172 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(81);
				elsif (columns = 176 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(80);
				elsif (columns = 180 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(79);
				elsif (columns = 184 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(78);
				elsif (columns = 188 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(77);
				elsif (columns = 192 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(76);
				elsif (columns = 196 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(75);
				elsif (columns = 200 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(74);
				elsif (columns = 204 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(73);
				elsif (columns = 208 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(72);
				elsif (columns = 212 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(71);
				elsif (columns = 216 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(70);
				elsif (columns = 220 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(69);
				elsif (columns = 224 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(68);
				elsif (columns = 228 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(67);
				elsif (columns = 232 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(66);
				elsif (columns = 236 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(65);
				elsif (columns = 240 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(64);
				elsif (columns = 244 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(63);
				elsif (columns = 248 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(62);
				elsif (columns = 252 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(61);
				elsif (columns = 256 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(60);
				elsif (columns = 260 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(59);
				elsif (columns = 264 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(58);
				elsif (columns = 268 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(57);
				elsif (columns = 272 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(56);
				elsif (columns = 276 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(55);
				elsif (columns = 280 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(54);
				elsif (columns = 284 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(53);
				elsif (columns = 288 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(52);
				elsif (columns = 292 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(51);
				elsif (columns = 296 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(50);
				elsif (columns = 300 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(49);
				elsif (columns = 304 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(48);
				elsif (columns = 308 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(47);
				elsif (columns = 312 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(46);
				elsif (columns = 316 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(45);
				elsif (columns = 320 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(44);
				elsif (columns = 324 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(43);
				elsif (columns = 328 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(42);
				elsif (columns = 332 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(41);
				elsif (columns = 336 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(40);
				elsif (columns = 340 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(39);
				elsif (columns = 344 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(38);
				elsif (columns = 348 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(37);
				elsif (columns = 352 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(36);
				elsif (columns = 356 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(35);
				elsif (columns = 360 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(34);
				elsif (columns = 364 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(33);
				elsif (columns = 368 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(32);
				elsif (columns = 372 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(31);
				elsif (columns = 376 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(30);
				elsif (columns = 380 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(29);
				elsif (columns = 384 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(28);
				elsif (columns = 388 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(27);
				elsif (columns = 392 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(26);
				elsif (columns = 396 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(25);
				elsif (columns = 400 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(24);
				elsif (columns = 404 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(23);
				elsif (columns = 408 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(22);
				elsif (columns = 412 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(21);
				elsif (columns = 416 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(20);
				elsif (columns = 420 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(19);
				elsif (columns = 424 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(18);
				elsif (columns = 428 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(17);
				elsif (columns = 432 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(16);
				elsif (columns = 436 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(15);
				elsif (columns = 440 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(14);
				elsif (columns = 444 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(13);
				elsif (columns = 448 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(12);
				elsif (columns = 452 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(11);
				elsif (columns = 456 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(10);
				elsif (columns = 460 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(9);
				elsif (columns = 464 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(8);
				elsif (columns = 468 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(7);
				elsif (columns = 472 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(6);
				elsif (columns = 476 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(5);
				elsif (columns = 480 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(4);
				elsif (columns = 484 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(3);
				elsif (columns = 488 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(2);
				elsif (columns = 492 + unsigned(basepixel(18 downto 9))) then
					rgbit <= data(1);
				elsif (columns = 499 + unsigned(basepixel(18 downto 9))) then
					rgbit <= '0';
			end if;
			 srt2_rgb <= rgbit & rgbit & rgbit & rgbit & rgbit & rgbit;
		end if;

end if;
end process;
end;

