library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- this is a copypaste of the crab module except I changed the name of the entity and the bits in the ROM

entity winner is
    port (
        clk: in std_logic;
		status: in std_logic_vector(1 downto 0); -- state, 00 is start
		rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
		columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
        win_rgb: out std_logic_vector(5 downto 0)
    );
end;

architecture synth of winner is

signal address: unsigned(7 downto 0); -- 8 bit
signal data: std_logic_vector(53 downto 0);
signal rgbit: std_logic;
signal shipbase: unsigned(18 downto 0);

begin
address <= rows(9 downto 2) - unsigned(shipbase (8 downto 1)); -- row counter minus basepixel y coordinate
shipbase <= 10d"200" & 9d"110";

process (clk)is begin
	if rising_edge(clk) then
		
		case address is
		when "00000000" => data <= "100000100011111000100000100001000001001111111001000001";
		when "00000001" => data <= "100000100100000100100000100001000001000001000001100001";
		when "00000010" => data <= "100000100100000100100000100001000001000001000001100001";
		when "00000011" => data <= "010001000100000100100000100001000001000001000001010001";
		when "00000100" => data <= "001010000100000100100000100001000001000001000001010001";
		when "00000101" => data <= "000100000100000100100000100001000001000001000001001001";
		when "00000110" => data <= "000100000100000100100000100001001001000001000001001001";
		when "00000111" => data <= "000100000100000100100000100001001001000001000001000101";
		when "00001000" => data <= "000100000100000100100000100001001001000001000001000101";
		when "00001001" => data <= "000100000100000100100000100001001001000001000001000011";
		when "00001010" => data <= "000100000100000100010001000001001001000001000001000011";
		when "00001011" => data <= "000100000011111000001110000000110110001111111001000001";
		when others => data <= "000000000000000000000000000000000000000000000000000000";
		end case;
		
		if (status = "10" ) then
			-- now we have a std_logic_vector. one bit is the export color
			if (columns = 216 + unsigned(shipbase(18 downto 9))) then -- I'm not addingf the full x coordinate because I want everything to stay in 4 pixel squares. drop the last 2 bits of 18 downto 9.
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(53);
				elsif (columns = 8 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(52);
				elsif (columns = 12 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(51);
				elsif (columns = 16 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(50);
				elsif (columns = 20 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(49);
				elsif (columns = 24 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(48);
				elsif (columns = 28 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(47);
				elsif (columns = 32 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(46);
				elsif (columns = 36 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(45);
				elsif (columns = 40 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(44);
				elsif (columns = 44 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(43);
				elsif (columns = 48 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(42);
				elsif (columns = 52 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(41);
				elsif (columns = 56 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(40);
				elsif (columns = 60 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(39);
				elsif (columns = 64 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(38);
				elsif (columns = 68 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(37);
				elsif (columns = 72 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(36);
				elsif (columns = 76 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(35);
				elsif (columns = 80 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(34);
				elsif (columns = 84 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(33);
				elsif (columns = 88 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(32);
				elsif (columns = 92 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(31);
				elsif (columns = 96 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(30);
				elsif (columns = 100 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(29);
				elsif (columns = 104 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(28);
				elsif (columns = 108 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(27);
				elsif (columns = 112 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(26);
				elsif (columns = 116 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(25);
				elsif (columns = 120 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(24);
				elsif (columns = 124 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(23);
				elsif (columns = 128 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(22);
				elsif (columns = 132 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(21);
				elsif (columns = 136 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(20);
				elsif (columns = 140 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(19);
				elsif (columns = 144 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(18);
				elsif (columns = 148 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(17);
				elsif (columns = 152 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(16);
				elsif (columns = 156 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(15);
				elsif (columns = 160 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(14);
				elsif (columns = 164 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(13);
				elsif (columns = 168 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(12);
				elsif (columns = 172 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(11);
				elsif (columns = 176 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(10);
				elsif (columns = 180 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(9);
				elsif (columns = 184 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(8);
				elsif (columns = 188 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(7);
				elsif (columns = 192 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(6);
				elsif (columns = 196 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(5);
				elsif (columns = 200 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(4);
				elsif (columns = 204 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(3);
				elsif (columns = 208 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(2);
				elsif (columns = 212 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(1);
							
				elsif (columns = 219 + unsigned(shipbase(18 downto 9))) then
					rgbit <= '0';
			end if;
		end if;
			
			win_rgb <= rgbit & rgbit & rgbit & rgbit & rgbit & rgbit;
	end if;
end process;


end;
