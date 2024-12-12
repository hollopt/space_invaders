library iEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- the top module currently contains the code needed to run 
-- graphics generated in RGB_generator on the VGA. 


entity top is 
	port (
		clk : in std_logic;
		RGB_out : out std_logic_vector(5 downto 0); -- 6 bits 
		HSYNC : out std_logic;
		VSYNC : out std_logic;
		
		NES_data: in std_logic;
		latch : out std_logic;
		NESclk : out std_logic;
		bullet_alive : out std_logic
		--aliens_ship_dead : out std_logic_vector(5 downto 0)
		 --10 bits x then y
	);
end;

architecture synth of top is

--------- VGA RELATED COMPONENTS ------------

component finalPLL is
    port(
        ref_clk_i: in std_logic;
        rst_n_i: in std_logic;
        outcore_o: out std_logic; -- this only goes to upduino pins. do not use internally
        outglobal_o: out std_logic -- this is the usable clock
    );
end component;
	
	component VGA is
		port (
			clk: in std_logic;
			HSYNC: out std_logic;
			VSYNC: out std_logic;
			rows : out unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479
			columns : out unsigned (9 downto 0)  -- max of 799, 10 bits needed. first bit = 0, last = 639
		);
	end component;
	
	component rgb is
		port (
			row: in unsigned(9 downto 0); 
			column: in unsigned(9 downto 0);
			crab_rgb: in std_logic_vector(5 downto 0);
			squid_rgb: in std_logic_vector(5 downto 0);
			ship_rgb: in std_logic_vector(5 downto 0);
			bullet_rgb: in std_logic_vector (5 downto 0);
			ebullet_rgb: in std_logic_vector(5 downto 0);
			str_rgb: in std_logic_vector(5 downto 0);
			str2_rgb: in std_logic_vector (5 downto 0);
			win_rgb: in std_logic_vector(5 downto 0);
			state_logic_vector : in std_logic_vector(1 downto 0);
			RGB: out std_logic_vector(5 downto 0); -- 6 bits 
			rgb_clk: in std_logic;
			loss_rgb: in std_logic_vector(5 downto 0);
			basepoint: out std_logic_vector(18 downto 0);
			--shipbase: out std_logic_vector(18 downto 0)
			bcounter: out unsigned(26 downto 0);
			fcounter: out unsigned(26 downto 0)
		);
	end component;
	
	component winner is
		port (
			clk: in std_logic;
			status: in std_logic_vector(1 downto 0); -- state, 00 is start
			rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
			columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
			win_rgb: out std_logic_vector(5 downto 0)
		);
	end component;
	
	component loss is
		port (
			clk: in std_logic;
			status: in std_logic_vector(1 downto 0); -- state, 00 is start
			rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
			columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
			loss_rgb: out std_logic_vector(5 downto 0)
		);
	end component;
	
	component crab is
		port (
			crab_clk: in std_logic;
			basepixel: in std_logic_vector(18 downto 0); -- concatenation of a 10 bit x coordinate and a 9 bit y coordinate
			dead: in std_logic_vector(6 downto 0); -- 1 means dead, 0 means alive. eventually evolve to a std_logic_vector with 1 bit per crab in the row
			rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
			columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
			crab_rgb: out std_logic_vector(5 downto 0)
		);
	end component;
	
	component squid is
		port (
			crab_clk: in std_logic;
			basepix: out std_logic_vector(18 downto 0); -- concatenation of a 10 bit x coordinate and a 9 bit y coordinate
			dead: in std_logic_vector(4 downto 0);
			rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
			columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
			back: in unsigned (26 downto 0);
			forth: in unsigned(26 downto 0);
			squid_rgb: out std_logic_vector(5 downto 0)
		);
	end component;
	
	component ship is
		port (
			crab_clk: in std_logic;
			shipbase: in std_logic_vector(18 downto 0); -- concatenation of a 10 bit x coordinate and a 9 bit y coordinate
			rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
			columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
			ship_dead : in std_logic;
			ship_rgb: out std_logic_vector(5 downto 0)
		);
	end component;
	
	component bullet is
		port (
			crab_clk: in std_logic;
			exists: in std_logic; -- 1 means someone has fired a bullet
			rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
			columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
			bullet_rgb: out std_logic_vector(5 downto 0);
			basepixel: in std_logic_vector(18 downto 0) -- concatenation of a 10 bit x coordinate and a 9 bit y coordinate
		);
	end component;

	component enemy_bullets is
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
	end component;
	
	component start is
		port (
			clk: in std_logic;
			status: in std_logic_vector(1 downto 0); -- state, 00 is start
			rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
			columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
			crab_rgb: out std_logic_vector(5 downto 0)
		);
	end component;

	component start2 is
		port (
			clk: in std_logic;
			status: in std_logic_vector(1 downto 0); -- state, 00 is start
			rows : in unsigned (9 downto 0);-- max of 524, 10 bits needed. first row = 0, last = 479. FROM VGA
			columns : in unsigned (9 downto 0);  -- max of 799, 10 bits needed. first bit = 0, last = 639. FROM VGA
			srt2_rgb: out std_logic_vector(5 downto 0)
		);
	end component;
	
	
	------ GAME RELATED COMPONENTS ---------------
	
	component nes is
		port(
			data : in std_logic;
			clk : in std_logic;
			human_speed_enable : out std_logic;
			copy_register : out std_logic_vector(7 downto 0);
			latch_to_controller : out std_logic;
			clk_to_controller : out std_logic
		);
	end component;

	--GAME LOGIC
	component gameLogic is 
		port(
			buttons : in std_logic_vector(7 downto 0); --A7 B6 SEL5 STRT4 UP3 DOWN2 LEFT1 RIGHT0
			clk : in std_logic;
			human_speed_enable : in std_logic;
			
			firing : in unsigned(6 downto 0); --1 hot for which alien is firing
			row_1_base_pixel : in std_logic_vector(18 downto 0);
			row_2_base_pixel: in std_logic_vector(18 downto 0);
			
			aliens_ship_dead : out std_logic_vector(12 downto 0);
			state_logic_out: out std_logic_vector(1 downto 0); --communicate state - Start(00) gameplay(01) win(10) loss (11)
			
			enemy_bullet_alive : out std_logic;
		
			enemy_bullet_position_x_out : out std_logic_vector(9 downto 0);
			enemy_bullet_position_y_out : out std_logic_vector(8 downto 0);
			
			ship_position : out std_logic_vector(18 downto 0);-- first 10 bits x next 9 y
			bullet_position : out std_logic_vector(18 downto 0);
			bullet_alive : out std_logic
		);

	end component;
	

------------ VGA RELATED SIGNALS --------------
	
signal col : unsigned (9 downto 0);
signal row : unsigned (9 downto 0);
signal clock : std_logic;
signal c_RGB : std_logic_vector (5 downto 0);
signal s_RGB : std_logic_vector (5 downto 0);
signal sh_RGB : std_logic_vector (5 downto 0);
signal b_rgb: std_logic_vector (5 downto 0);
signal eb_rgb : std_logic_vector (5 downto 0);
signal str_rgb: std_logic_vector (5 downto 0);
signal str2_rgb: std_logic_vector (5 downto 0);
signal loss_rgb: std_logic_vector(5 downto 0);
signal win_rgb: std_logic_vector (5 downto 0);
signal basepix: std_logic_vector (18 downto 0); -- 19 bits: first 10 are x coordinate, last 9 are y
signal sh_baserow: std_logic_vector(8 downto 0); -- just the y coordinate, a constant
signal sq_basepix: std_logic_vector(18 downto 0);
signal dead_crab: std_logic_vector(6 downto 0); -- NOT CONNECTED TO ANYTHING. In reality this would probably be a std_logic_vector with one bit for each crab in the row.
-- if a crab's associated bit goes to 1, that crab is dead and should no longer be displayed. it should also no longer be firing bullets
signal forward: unsigned (26 downto 0);
signal backward: unsigned(26 downto 0);

------ GAME RELATED SIGNALS -----------

	signal human_speed_enable : std_logic;
	--signal clk : std_logic;
	signal buttons : std_logic_vector(7 downto 0);
	--signal buttons : std_logic_vector(7 downto 0);
	signal state_logic_out:  std_logic_vector(1 downto 0);
	--signal ship_position_x :  std_logic_vector(9 downto 0);
	--signal ship_position_y : std_logic_vector(8 downto 0);
	--signal bullet_position_x : std_logic_vector(9 downto 0);
	--signal bullet_position_y : std_logic_vector(8  downto 0);
	signal bullet_position : std_logic_vector(18 downto 0);
	signal ship_position : std_logic_vector(18 downto 0);
	
	signal bulletaliv: std_logic;
	signal aliens_ship_dead : std_logic_vector(12 downto 0); --issue?
	signal firing : unsigned(6 downto 0);
	signal enemy_bullet_basepix : std_logic_vector(18 downto 0);


	signal enemy_bullet_position_x : std_logic_vector(9 downto 0);
	signal enemy_bullet_position_y : std_logic_vector(8 downto 0);

	--signal enemy_bullet_alive : std_logic_vector(6 downto 0);
	signal enemy_bullet_alive: std_logic;
	
begin
	enemy_bullet_basepix <= enemy_bullet_position_x & enemy_bullet_position_y;


	-- make sure ship basepixel is getting the right value
	dead_crab <= aliens_ship_dead(10 downto 8) & aliens_ship_dead(4 downto 1);-- and more
	sh_baserow <= "011010010"; -- this constant describes where the ship should be in vertical space. it is 210. the ship is at pixel 420. y coordinates are compressed by 1/2. 
	
	-- things are no longer being handed their basepixels. we give basepixels to rom and it decides what data to hand back.

	PLL : finalPLL port map (ref_clk_i => clk, outglobal_o => clock, outcore_o => open, rst_n_i => '1');
	VGA1 : VGA port map (clk => clock, HSYNC => HSYNC, VSYNC => VSYNC, rows => row, columns => col);
    crab1 : crab port map(crab_clk => clock, rows => row, columns => col, crab_rgb =>c_RGB, basepixel => basepix, dead => dead_crab);
	RGB1 : rgb port map (loss_rgb => loss_rgb, win_rgb => win_rgb, str2_rgb => str2_rgb, row => row, column => col, str_rgb => str_rgb, crab_rgb => c_RGB, squid_rgb => s_RGB, ship_rgb => sh_RGB, bullet_rgb => b_rgb, ebullet_rgb => eb_rgb, RGB => RGB_out, rgb_clk => clock, basepoint => basepix, bcounter => backward, fcounter => forward, state_logic_vector => state_logic_out);
	squid1 : squid port map(dead => aliens_ship_dead(12 downto 11)& aliens_ship_dead(7 downto 5), crab_clk => clock, rows => row, columns => col, squid_rgb =>s_RGB, back => backward, forth => forward, basepix => sq_basepix);
	ship1 : ship port map(crab_clk => clock, rows => row, columns => col, ship_rgb =>sh_RGB, shipbase => ship_position(18 downto 9) & sh_baserow(8 downto 0), ship_dead => aliens_ship_dead(0));
	bullet1 : bullet port map (crab_clk => clock, exists => bulletaliv, rows => row, columns => col, bullet_rgb => b_rgb, basepixel => bullet_position);
	--ebullet : enemy_bullets port map (clock => clock, rows=> row, columns => col, ebullet_rgb => eb_rgb, basepixel1 => enemy_bullet_basepix_0, basepixel2 => enemy_bullet_basepix_1, basepixel3 => enemy_bullet_basepix_2, basepixel4 => enemy_bullet_basepix_3, basepixel5 => open, basepixel6 => open, basepixel7 => open, status => aliens_ship_dead, firing => firing, enemy_bullet_alive => enemy_bullet_alive);
	ebullet : enemy_bullets port map (clock => clock, rows=> row, columns => col, ebullet_rgb => eb_rgb, basepixel => enemy_bullet_basepix, status => aliens_ship_dead, firing => firing, enemy_bullet_alive => enemy_bullet_alive);
	startscreen1 : start port map(clk => clock, status => state_logic_out, rows => row, columns => col, crab_rgb => str_rgb);
	startscreen2 : start2 port map (clk => clock, status => state_logic_out, rows => row, columns => col, srt2_rgb => str2_rgb);
	won: winner port map (clk => clock, status => state_logic_out, rows => row, columns => col, win_rgb => win_rgb);
	lost : loss port map (clk=> clock, status=> state_logic_out, rows => row, columns => col, loss_rgb => loss_rgb);
		--instantiate NES Controller
	controller : nes port map (data => NES_data, clk => clock, latch_to_controller => latch, clk_to_controller => NESclk, copy_register => buttons,
	human_speed_enable => human_speed_enable);
	
	--instantiate game logic
	game : gameLogic port map (buttons => buttons, clk => clock, human_speed_enable => human_speed_enable, ship_position => ship_position,
		bullet_position => bullet_position, state_logic_out => state_logic_out, bullet_alive => bulletaliv, row_1_base_pixel => basepix, 
		aliens_ship_dead => aliens_ship_dead, row_2_base_pixel => sq_basepix, firing => firing, enemy_bullet_position_x_out => enemy_bullet_position_x, 
		 enemy_bullet_position_y_out => enemy_bullet_position_y, enemy_bullet_alive => enemy_bullet_alive
		);
	
end;
