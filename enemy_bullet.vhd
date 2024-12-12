library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity enemy_bullets is
    port (
        clock: in std_logic;
			rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
			columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
			ebullet_rgb: out std_logic_vector(5 downto 0);
			status: in std_logic_vector(12 downto 0);
					basepixel: in std_logic_vector(18 downto 0); -- left crab
			--basepixel1: in std_logic_vector(18 downto 0); -- left crab
			--basepixel2: in std_logic_vector(18 downto 0); -- middle left crab
			--basepixel3: in std_logic_vector(18 downto 0); -- middle right crab
			--basepixel4: in std_logic_vector(18 downto 0); -- right crab
			--basepixel5: in std_logic_vector(18 downto 0); -- left squid
			---basepixel6: in std_logic_vector(18 downto 0); -- middle squid
			--basepixel7: in std_logic_vector(18 downto 0); -- right squid
--			enemy_bullet_alive : in std_logic_vector(6 downto 0);
			enemy_bullet_alive : in std_logic; -- a 1 means that enemy's bullet still exists. 
			firing : out unsigned(6 downto 0) --1 hot for which alien is firing
    );
end;

architecture synth of enemy_bullets is
--signal firing: unsigned(6 downto 0); -- a 1 hot system where 1 means that enemy has fired a bullet. bit 0 is the top left crab, 1 is the next crab... 4 is the leftmost squid and 6 is the rightmost squid.
signal counter1: unsigned (16 downto 0); -- 17 bit counter to be sampled once per second.
signal counter2: unsigned (24 downto 0); -- 25 bit counter that resets every second (when counter 1 = 25100000)
signal enemy_number: unsigned(2 downto 0); -- the binary number describing which of the 7 enemies shoots a bullet

begin

process (clock) is begin
	if rising_edge(clock) then
--------------------- GENERATE AN ENEMY TO FIRE --------------------
	-- first, make the counter which we will sample to determine which enemy is firing:
		if (counter1 = 131071) then -- reset when it reaches max value
			counter1 <= 17d"0";
		else
			counter1 <= counter1 +1;
		end if;
	-- then, we must generate an enemy to fire a bullet at a rate of one per second. (1 clock out of 25,100,000)
		if (counter2 = 4183333) then -- it will get there in 1 second. to make enemies shoot faster, make this number smaller.
			counter2 <= 25d"0";
			-- take three bits of counter 1 to make a 3 bit number between 0 and 7.
			enemy_number(0) <= counter1(4);
			enemy_number(1) <= counter1(7);
			enemy_number(2) <= counter1(13);	
		else
			counter2 <= counter2 +1;
		end if;


-- this is the logic that picks who fires. Firing is only possible for living enemies. As enemies die, it becomes less likely than any enemy at all will fire. **

			firing <= "0000001" when (enemy_number = "001" and status(1) = '0') else -- enemy_number initializes to 000, so we can't use "000" to mean that anyone fires
					"0000010" when (enemy_number = "010" and status(2) = '0') else
					"0000100" when (enemy_number = "011" and status(3) = '0') else
					"0001000" when (enemy_number = "100" and status(4) = '0') else
					"0010000" when (enemy_number = "101" and status(5) = '0') else
					"0100000" when (enemy_number = "110" and status(6) = '0') else
					"1000000" when (enemy_number = "111" and status(7) = '0'); -- when enemy_number gets "000", nobody shoots anything.

-- ** we'll see if this works first. Then, as more enemies die, it would make sense to speed up counter 2. this increases the chance that a living enemy will actually fire

--------------------- MAKE THE ENEMY FIRE --------------------

	-- HERE'S THE PLAN: Generate a basepixel for each enemy so that, if we choose to speed up firing, multiple bullets can be onscreen at once. EX: basepixel 1 corresponds to crab 1 in "aliens_ship_dead" and "firing"
	-- The code below can handle as many bullets onscreen as you choose to have. The tradeoff is that we need 7 different basepixels.
		if(enemy_bullet_alive = '1') then
			ebullet_rgb <= "111111" when ((columns(9 downto 2) = unsigned(basepixel(18 downto 11))) and rows > ((unsigned(basepixel(7 downto 0) & '0') - 1)) and rows < ((unsigned(basepixel(7 downto 0) & '0') + 12))) else
						  "000000";
		end if;
	
	end if;
	
end process;
end;
