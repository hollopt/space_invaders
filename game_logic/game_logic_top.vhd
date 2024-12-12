library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;




entity gameLogic is 
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
	
end gameLogic;


architecture synth of gameLogic is 


	component stateCalculation is 
		port(
			buttons : in std_logic_vector(7 downto 0);  --A7 B6 SEL5 STRT4 UP3 DOWN2 LEFT1 RIGHT0
			clk : in std_logic;
			all_aliens_dead : in std_logic;
			aliens_reached_player : in std_logic;
			player_dead : in std_logic;


			
			state_logic_vector: out std_logic_vector(1 downto 0) --communicate state - Start(00) gameplay(01) win(10) loss (11)


		);
	end component;
	
	component ShipLogic is
		port(
			state_logic_vector : in std_logic_vector(1 downto 0);-- Start(00) gameplay(01) win(10) loss (11)
			left_button : in std_logic;
			right_button : in std_logic;
			a_button : in std_logic;
			start_button : in std_logic;
			clk : in std_logic; --25.1MHz
			human_speed_enable : in std_logic;
			
			firing : in unsigned(6 downto 0); --1 hot for which alien is firing
			row_1_base_pixel : in std_logic_vector(18 downto 0);
			row_2_base_pixel : in std_logic_vector(18 downto 0);
			aliens_ship_dead : out std_logic_vector(12 downto 0);
			
			enemy_bullet_alive : out std_logic;
			
			enemy_bullet_position_x_out : out std_logic_vector(9 downto 0);
			enemy_bullet_position_y_out : out std_logic_vector(8 downto 0);
			
			
			ship_position_x : out std_logic_vector(9 downto 0); --screen is 640x480. x is the 640, so we need 10 bits fpor 1024
			ship_position_y : out std_logic_vector(8 downto 0); --y is the 460, so we need up to 512 = 2^9
			bullet_position_x : out std_logic_vector(9 downto 0);-- shouldn't change while ship is moving
			bullet_position_y :out std_logic_vector(8 downto 0); --will be changing
			bullet_alive : out std_logic
		);
	end component;
		
	signal all_aliens_dead : std_logic;
	signal aliens_reached_player : std_logic;
	signal player_dead : std_logic;
	signal ship_position_x : std_logic_vector(9 downto 0); --screen is 640x480. x is the 640, so we need 10 bits fpor 1024
	signal ship_position_y : std_logic_vector(8 downto 0); --y is the 460, so we need up to 512 = 2^9
	signal bullet_position_x : std_logic_vector(9 downto 0);-- shouldn't change while ship is moving
	signal bullet_position_y : std_logic_vector(8 downto 0); --will be changing	
	--signal aliens_ship_dead : std_logic_vector(5 downto 0); --0 means alive 1 means dead, top 5 bits are aliens, bottom bit is ship




begin
	all_aliens_dead <= '1' when aliens_ship_dead(12 downto 1) = "111111111111" else '0'; --CHANGE THIS : top down to ship
	ship_position <= ship_position_x & ship_position_y;
	bullet_position <= bullet_position_x & bullet_position_y;
	aliens_reached_player <= '0';
	player_dead <= aliens_ship_dead(0);

	statement : stateCalculation port map(
		buttons => buttons, clk => clk, all_aliens_dead => all_aliens_dead, aliens_reached_player => aliens_reached_player,
		player_dead => player_dead, state_logic_vector => state_logic_out
		
	);
	
	ship : ShipLogic port map(
		state_logic_vector => state_logic_out, left_button => buttons(1), right_button => buttons(0), a_button => buttons(7), start_button => buttons(4),
		clk => clk, human_speed_enable => human_speed_enable, ship_position_x => ship_position_x, ship_position_y => ship_position_y, bullet_position_x => bullet_position_x,
		bullet_position_y => bullet_position_y, bullet_alive => bullet_alive, aliens_ship_dead => aliens_ship_dead, row_1_base_pixel => row_1_base_pixel, row_2_base_pixel => row_2_base_pixel, firing => firing,
		enemy_bullet_alive => enemy_bullet_alive, enemy_bullet_position_x_out => enemy_bullet_position_x_out,
		 enemy_bullet_position_y_out => enemy_bullet_position_y_out
	);
end;

