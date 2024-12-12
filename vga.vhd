library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- This module generates the signals which run the VGA.
-- It works in tandem with the RGB generator, which specifies
-- a pattern for this module to output.


entity VGA is
    port (
        clk: in std_logic;
        HSYNC: out std_logic;
        VSYNC: out std_logic;
		rows : out unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479
		columns : out unsigned (9 downto 0)  -- max of 799, 10 bits needed. first bit = 0, last = 639
    );
end;

architecture synth of VGA is
signal r : unsigned (9 downto 0);
signal c : unsigned (9 downto 0);
begin
    process(clk) is begin
        if rising_edge(clk) then
            if (c = 799) then
                if (r  = 524) then
                    r  <= "0000000000";
                    c <= "0000000000";
                else
                    r <= r + 1; -- row count is incremented once every 799 clks
                    c <= "0000000000"; -- column count cannot be > 799
                end if;
            else
                c <= c + 1; -- column count is incremented once every clk
            end if;
        end if;
    end process;
	
	rows <= r;
	columns <= c;
    
    HSYNC <= '1' when (c < 656) else -- covers visible area and front porch
             '1' when(c > 751) else -- covers back porch
             '0'; -- covers sync
    
    VSYNC <= '0' when (r = 490) else -- covers half of sync
             '0' when (r = 491) else -- covers half of sync
             '1'; -- covers visible and front/back porches
    
end;
