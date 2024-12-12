library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- this is a copypaste of the crab module except I changed the name of the entity and the bits in the ROM

entity ship is
    port (
        crab_clk: in std_logic;
		shipbase: in std_logic_vector(18 downto 0); -- comes from top and NES logic
		rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
		columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
		ship_dead : in std_logic;
        ship_rgb: out std_logic_vector(5 downto 0)
    );
end;

architecture synth of ship is

signal address: unsigned(7 downto 0); -- 8 bit
signal data : std_logic_vector(10 downto 0);
signal rgbit: std_logic;

begin
address <= rows(9 downto 2) - unsigned(shipbase(8 downto 1)); -- row counter minus basepixel y coordinate

process (crab_clk)is begin
	if rising_edge(crab_clk) then
		
			case address is
				when "00000000" => data <= "00000100000";
				when "00000001" => data <= "00001110000";
				when "00000010" => data <= "00001110000";
				when "00000011" => data <= "01111111110";
				when "00000100" => data <= "11111111111";
				when "00000101" => data <= "11111111111";
				when "00000110" => data <= "11111111111";
				when "00000111" => data <= "11111111111";
				when others => data <= "00000000000";
			end case;
		
		if ship_dead = '0' then
			-- now we have a std_logic_vector. one bit is the export color
			if (columns = 44 + unsigned(shipbase(18 downto 9))) then -- I'm not addingf the full x coordinate because I want everything to stay in 4 pixel squares. drop the last 2 bits of 18 downto 9.
					rgbit <= data(0); --displayed from 0 to 4 clocks
				elsif (columns = 4 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(10);
				elsif (columns = 8 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(9);
				elsif (columns = 12 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(8);
				elsif (columns = 16 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(7);
				elsif (columns = 20 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(6);
				elsif (columns = 24 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(5);
				elsif (columns = 28 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(4);
				elsif (columns = 32 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(3);
				elsif (columns = 36 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(2);
				elsif (columns = 40 + unsigned(shipbase(18 downto 9))) then
					rgbit <= data(1);
				elsif (columns = 47 + unsigned(shipbase(18 downto 9))) then
					rgbit <= '0';
			end if;
		end if;
			
			ship_rgb <= rgbit & rgbit & rgbit & rgbit & rgbit & rgbit;
	end if;
end process;


end;
