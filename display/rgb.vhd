library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- this is making crab's basepixel right now, listed as "basepoint"
-- it also tells the vga what to display. 

entity rgb is
    port (
        row: in unsigned (9 downto 0);
        column: in unsigned(9 downto 0);
		rgb_clk: in std_logic;
		crab_rgb: in std_logic_vector(5 downto 0);
		squid_rgb: in std_logic_vector (5 downto 0);
		ship_rgb: in std_logic_vector(5 downto 0);
		win_rgb: in std_logic_vector(5 downto 0);
		bullet_rgb: in std_logic_vector (5 downto 0);
		ebullet_rgb: in std_logic_vector(5 downto 0);
		loss_rgb: in std_logic_vector(5 downto 0);
		str2_rgb: in std_logic_vector (5 downto 0);
		state_logic_vector : in std_logic_vector(1 downto 0);
		str_rgb: in std_logic_vector(5 downto 0);
        RGB: out std_logic_vector(5 downto 0);
		basepoint: out std_logic_vector(18 downto 0); -- right now (12/4) crab and squid both run off this basepoint
		bcounter: out unsigned(26 downto 0);
		fcounter: out unsigned(26 downto 0)
    );
end;

architecture synth of rgb is

signal initialized: std_logic;

begin
-- CRABS SHOUYLD BE MOVING BACK AND FORTH EXACTLY 116 PIXELS. 7 BITS NECESSARY. basepoint should start at 0 and its x value should increment to 104.
-- thus, the top 9 bits of the counter should be 104 ( 001101000 )


process(rgb_clk) is begin
	if rising_edge(rgb_clk) then
--------------------- COUNTERS TO DRIVE ROW MOVEMENT ---------------------------------------
	-- counter initialization: only happens once
		if (initialized = '0') then
			bcounter <= 27d"54525952";
			initialized <= '1';
		end if;
		-- forward counter for rightward movement
			if (fcounter = 54525952) then -- counter is at 27262976 when the top 9 bits make 104, the max pixels the crab row can move over. this is double.
				fcounter <= 27d"0";
			else
				fcounter <= fcounter +1;
			end if;
		-- backward counter for leftward movement
			if (bcounter = 0) then
				bcounter <= 27d"54525952";
			else
				bcounter <= bcounter - 1;
			end if;
		-- chooses which direction the crab row is intended to be moving
			if (fcounter < 27262977) then
				basepoint <= "0" & std_logic_vector(fcounter(26 downto 18)) & "000001110"; -- moving forward. 28 pixels below the top of the screen, binary 14 because y is doubled
			else
				basepoint <= "0" & std_logic_vector(bcounter(26 downto 18)) & "000001110"; -- moving backward
			end if;
	end if;
end process;

----------------- COLOR GENERATION ---------------------------------------------------------------------

-- THIS PART must stay. it keeps the signals low when the VGA is not accepting input
RGB <= "000000" when (column > 639) else 
       "000000" when (row > 479) else
------------------------------------
 		--crab_rgb when (column > unsigned(basepoint(18 downto 9)) and column < unsigned(basepoint(18 downto 9)) + 50 and row > unsigned(basepoint(8 downto 0)) and row < unsigned(basepoint(8 downto 0)) + 33) else
		crab_rgb when (crab_rgb = "111111" and state_logic_vector = "01") else
		squid_rgb when (squid_rgb = "111111" and state_logic_vector = "01") else
		ship_rgb when (ship_rgb = "111111" and state_logic_vector = "01") else
		bullet_rgb when (bullet_rgb = "111111" and state_logic_vector = "01") else
		ebullet_rgb when (ebullet_rgb = "111111" and state_logic_vector = "01") else
		str_rgb when (str_rgb = "111111" and state_logic_vector = "00") else
		str2_rgb when (str2_rgb = "111111" and state_logic_vector = "00") else
		win_rgb when (win_rgb = "111111" and state_logic_vector = "10") else
		loss_rgb when(loss_rgb = "111111" and state_logic_vector = "11") else
		"000000";

end;


-- CURRENT PROBLEMS
-- potential fix: i'm having shipbase originate from the same file asbasepoint, RGB, instead of from top. it had been originating as a signal in top.

-- none of our ROMS are large enough to actually synthesize as memory. They are all currently in LUTs, which is taking up far more memory than would be optimal. 
-- if we were to put all the roms in 1 file and pull data from them there? while they are currently addressed by row, meaning that multiple data sets will attempt to store in the same location, 
-- we can add 2 more bits to the end of the address: 00 means ship, 01 means crab, and 10 means squid,. then, we can concatenate the appropriate bits to the end of the row when attempting to pull info
-- we will also have a second, longer ROm for the start screen info

-- CURRENT GOALS
-- I would like more crabs/squids in a row and for them all to move together. start by making 2 rows work, expand if you have time
-- I would like for each crab / squid to be turned on and off via a std_logic signal. if the signal goes high, that alien is no longer displayed. 
