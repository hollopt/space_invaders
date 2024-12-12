library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bullet is
    port (
        crab_clk: in std_logic;
		exists: in std_logic; -- a 1 means someone has fired a bullet
		rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
		columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
        bullet_rgb: out std_logic_vector(5 downto 0);
		basepixel: in std_logic_vector(18 downto 0) -- concatenation of a 10 bit x coordinate and a 9 bit y coordinate
    );
end;

architecture synth of bullet is

begin

process (crab_clk) is begin
	if rising_edge(crab_clk)then
		if (exists = '1') then
			
			-- display a bullet with a stationary column and a row which can change with basepixel
			bullet_rgb <= "111111" when ((columns(9 downto 2) = unsigned(basepixel(18 downto 11))) and rows > ((unsigned(basepixel(7 downto 0) & '0') - 1)) and rows < ((unsigned(basepixel(7 downto 0) & '0') + 12))) else
						  "000000";
		-- basepixel is multiplied by 2. that just works here.
		
		end if;
	end if;
end process;

end;
