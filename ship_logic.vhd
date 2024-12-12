library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity ShipLogic is
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
end entity;


architecture synth of ShipLogic is
	signal state_at_previous_clk : std_logic_vector(1 downto 0);
	signal ship_intermediate_x : unsigned (9 downto 0);
	signal bullet_intermediate_y : unsigned(8 downto 0);
	signal row_1_base_pixel_y : unsigned(8 downto 0);
	signal row_1_base_pixel_x : unsigned(9 downto 0);
	signal row_2_base_pixel_y : unsigned(8 downto 0);
	signal row_2_base_pixel_x : unsigned(9 downto 0);
	--signal bullet_alive : std_logic; --on when a bullet exists, don't shoot another when this is 1
	--signal enemy_bullet_alive : std_logic_vector(6 downto 0);
	signal enemy_bullet_position_x : unsigned(9 downto 0);
	signal enemy_bullet_position_y : unsigned(8 downto 0);
	

begin
	enemy_bullet_position_x_out <= std_logic_vector(enemy_bullet_position_x);
	enemy_bullet_position_y_out <= std_logic_vector(enemy_bullet_position_y);
	row_1_base_pixel_x <= unsigned(row_1_base_pixel(18 downto 9));
	row_1_base_pixel_y <= unsigned(row_1_base_pixel(8 downto 0));
	row_2_base_pixel_x <= unsigned(row_2_base_pixel(18 downto 9));
	row_2_base_pixel_y <= unsigned(row_2_base_pixel(8 downto 0));
	--initial positions
	ship_position_y <= "011010010"; --y should never change from 210
	ship_position_x <= std_logic_vector(ship_intermediate_x);
	bullet_position_y <= std_logic_vector(bullet_intermediate_y);
	
	--

	
	
	
	--updating everything
	process (clk) is begin	
		if rising_edge(clk) then
			if state_logic_vector = "01" then
				if human_speed_enable = '1' then --check if stuff should move
				--ship movement
					if left_button = '1' then 
						ship_intermediate_x <= ship_intermediate_x - "0000000101" when ship_intermediate_x > "0000000100" else "0000000000";
					elsif right_button = '1' then
						ship_intermediate_x <= ship_intermediate_x + "0000000101" when ship_intermediate_x < "1001001110" else "1001001111";
					end if;
				--bullet firing logic
					if (start_button ='1') then --reset
							aliens_ship_dead <= "0000000000000";
					else
						if bullet_alive = '0' then --we can fire a bullet
							if ((a_button = '1') and (aliens_ship_dead(0) = '0')) then	---should be 24 and 6, im moving it to 6 and 12
								bullet_position_x <= std_logic_vector(unsigned(ship_position_x) + 10d"24"); -- kayla's edit: the bullet comes from the center of the ship, so ship_position_x + 6 squares
								bullet_intermediate_y <= unsigned(ship_position_y(8 downto 0)) - 9d"6"; -- k's edit: so as to not mess up RGB_gen, bullet and ship can't overlap. bullet spawns just above ship.
								bullet_alive <= '1';
							end if;
						
						else--bullet is flying
							bullet_intermediate_y <= bullet_intermediate_y - "000001000";
							if bullet_intermediate_y <= "000001000" then
								bullet_alive <= '0';
							end if;
							--check if hits first ghost in top left 
							if (bullet_intermediate_y > row_1_base_pixel_y) then
								if (bullet_intermediate_y < (row_1_base_pixel_y + 16 + 4)) then
								--we're on right row
									if (aliens_ship_dead(1) = '0') then
										if (unsigned(bullet_position_x) > (row_1_base_pixel_x - 4)) then
											if (unsigned(bullet_position_x) < (row_1_base_pixel_x + 44 + 4)) then
												aliens_ship_dead(1) <= '1';
												bullet_alive <= '0';
											end if;
										end if;
									end if;
									--alien 2
									if (aliens_ship_dead(2) = '0') then
										if (unsigned(bullet_position_x) > (row_1_base_pixel_x - 4 + 160)) then
											if (unsigned(bullet_position_x) < (row_1_base_pixel_x + 44 + 4 + 160)) then
												aliens_ship_dead(2) <= '1';
												bullet_alive <= '0';
											end if;
										end if;
									end if;
									--alien 3
									if (aliens_ship_dead(3) = '0') then
										if (unsigned(bullet_position_x) > (row_1_base_pixel_x - 4 + 320)) then
											if (unsigned(bullet_position_x) < (row_1_base_pixel_x + 44 + 4 + 320)) then
												aliens_ship_dead(3) <= '1';
												bullet_alive <= '0';
											end if;
										end if;
									end if;
									--alien 4
									if (aliens_ship_dead(4) = '0') then
										if (unsigned(bullet_position_x) > (row_1_base_pixel_x - 4 + 480)) then
											if (unsigned(bullet_position_x) < (row_1_base_pixel_x + 44 + 4 + 480)) then
												aliens_ship_dead(4) <= '1';
												bullet_alive <= '0';
											end if;
										end if;
									end if;
									--alien 5 (2nd from left
									if (aliens_ship_dead(8) = '0') then
										if (unsigned(bullet_position_x) > (row_1_base_pixel_x - 4 + 80)) then
											if (unsigned(bullet_position_x) < (row_1_base_pixel_x + 44 + 4 + 80)) then
												aliens_ship_dead(8) <= '1';
												bullet_alive <= '0';
											end if;
										end if;
									end if;
									
									--alien 6 (4th from left
									if (aliens_ship_dead(9) = '0') then
										if (unsigned(bullet_position_x) > (row_1_base_pixel_x - 4 + 240)) then
											if (unsigned(bullet_position_x) < (row_1_base_pixel_x + 44 + 4 + 240)) then
												aliens_ship_dead(9) <= '1';
												bullet_alive <= '0';
											end if;
										end if;
									end if;
									--alien 7 (6th from left
									if (aliens_ship_dead(10) = '0') then
										if (unsigned(bullet_position_x) > (row_1_base_pixel_x - 4 + 400)) then
											if (unsigned(bullet_position_x) < (row_1_base_pixel_x + 44 + 4 + 400)) then
												aliens_ship_dead(10) <= '1';
												bullet_alive <= '0';
											end if;
										end if;
									end if;
									
								elsif (bullet_intermediate_y > (row_2_base_pixel_y)) then --squids at 74 x 2 from top
									if (bullet_intermediate_y < (row_2_base_pixel_y + 16 + 4)) then
										--we're on right row
										if (aliens_ship_dead(5) = '0') then
											if (unsigned(bullet_position_x) > (row_2_base_pixel_x - 4 + 80)) then
												if (unsigned(bullet_position_x) < (row_2_base_pixel_x + 44 + 4 + 80)) then
													aliens_ship_dead(5) <= '1';
													bullet_alive <= '0';
												end if;
											end if;
										end if;
										--squid 2
										if (aliens_ship_dead(6) = '0') then
											if (unsigned(bullet_position_x) > (row_2_base_pixel_x - 4 + 240)) then
												if (unsigned(bullet_position_x) < (row_2_base_pixel_x + 44 + 4 + 240)) then
													aliens_ship_dead(6) <= '1';
													bullet_alive <= '0';
												end if;
											end if;
										end if;
										--squid 3
										if (aliens_ship_dead(7) = '0') then
											if (unsigned(bullet_position_x) > (row_2_base_pixel_x - 4 + 400)) then
												if (unsigned(bullet_position_x) < (row_2_base_pixel_x + 44 + 4 + 400)) then
													aliens_ship_dead(7) <= '1';
													bullet_alive <= '0';
												end if;
											end if;
										end if;
										--squid 4 (2nd from left
										if (aliens_ship_dead(11) = '0') then
											if (unsigned(bullet_position_x) > (row_2_base_pixel_x - 4 + 160)) then
												if (unsigned(bullet_position_x) < (row_2_base_pixel_x + 44 + 4 + 160)) then
													aliens_ship_dead(11) <= '1';
													bullet_alive <= '0';
												end if;
											end if;
										end if;
										--squid 5 (4th from left
										if (aliens_ship_dead(12) = '0') then
											if (unsigned(bullet_position_x) > (row_2_base_pixel_x - 4 + 320)) then
												if (unsigned(bullet_position_x) < (row_2_base_pixel_x + 44 + 4 + 320)) then
													aliens_ship_dead(12) <= '1';
													bullet_alive <= '0';
												end if;
											end if;
										end if;
										
										
									end if;
								end if;
						end if;
						end if;
						--enemy bullet firing - we have a 1 hot saying which is firing, we need to generate an incrementing base pixel for that
						
						if (firing = "000000") then --don't generate anything
							enemy_bullet_alive <= '0';
						else --the bullet is fired/we need to fire a bullet
							if ((firing(0) = '1') and (enemy_bullet_alive = '0') and (aliens_ship_dead(1) = '0')) then --first squid needs to fire
								enemy_bullet_alive <= '1';
								enemy_bullet_position_x <= row_1_base_pixel_x + 22;
								enemy_bullet_position_y <= row_1_base_pixel_y + 16;
							elsif ((firing(1) = '1') and (enemy_bullet_alive = '0') and (aliens_ship_dead(2) = '0')) then --second squid should fire
								enemy_bullet_alive <= '1';
								enemy_bullet_position_x <= row_1_base_pixel_x + 22 + 160;
								enemy_bullet_position_y <= row_1_base_pixel_y + 16;
							elsif (firing(2) = '1' and (enemy_bullet_alive = '0') and (aliens_ship_dead(3) = '0')) then --third squid should fire
								enemy_bullet_alive <= '1';
								enemy_bullet_position_x <= row_1_base_pixel_x + 22 + 320;
								enemy_bullet_position_y <= row_1_base_pixel_y + 16;
							elsif ((firing(3) = '1') and (enemy_bullet_alive = '0') and (aliens_ship_dead(4) = '0')) then --fourth squid should fire
								enemy_bullet_alive <= '1';
								enemy_bullet_position_x <= row_1_base_pixel_x + 22 + 480;
								enemy_bullet_position_y <= row_1_base_pixel_y + 16;
							elsif ((firing(4) = '1') and (enemy_bullet_alive = '0') and (aliens_ship_dead(5) = '0')) then --fourth squid should fire
								enemy_bullet_alive <= '1';
								enemy_bullet_position_x <= row_2_base_pixel_x + 22 + 80;
								enemy_bullet_position_y <= row_2_base_pixel_y + 16;
							elsif ((firing(5) = '1') and (enemy_bullet_alive = '0') and (aliens_ship_dead(6) = '0')) then --fourth squid should fire
								enemy_bullet_alive <= '1';
								enemy_bullet_position_x <= row_2_base_pixel_x + 22 + 160 + 80;
								enemy_bullet_position_y <= row_2_base_pixel_y + 16;
							elsif ((firing(6) = '1') and (enemy_bullet_alive = '0') and (aliens_ship_dead(7) = '0')) then --fourth squid should fire
								enemy_bullet_alive <= '1';
								enemy_bullet_position_x <= row_2_base_pixel_x + 22 + 320 + 80;
								enemy_bullet_position_y <= row_2_base_pixel_y + 16;
							else --if bullet is alive
								if enemy_bullet_alive = '1' then
									enemy_bullet_position_y <= enemy_bullet_position_y + "000000101";
								end if;
								--if hit bottom of screen, bullet goes away
								--going away conditions
								if (enemy_bullet_position_y > 240) then
									enemy_bullet_alive <= '0';
								elsif (enemy_bullet_position_y >= unsigned(ship_position_y) and (enemy_bullet_alive = '1')) then --if we hit the ship, bullet goes away
									if (enemy_bullet_position_y < unsigned(ship_position_y) + 16) then
										if (enemy_bullet_position_x >= unsigned(ship_position_x)) then
											if (enemy_bullet_position_x < unsigned(ship_position_x) + 44) then
												enemy_bullet_alive <= '0';
												aliens_ship_dead(0) <='1';
											end if;
										end if;
									end if;
								end if;
							end if;
							
						end if;
						
					end if;
				end if;
			else
				aliens_ship_dead <= "0000000000000";
				enemy_bullet_alive <= '0';
				bullet_alive <= '0';
			end if;

		end if;
	end process;


end;
