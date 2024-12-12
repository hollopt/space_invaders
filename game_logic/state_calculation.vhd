library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity stateCalculation is 
	port(
	buttons : in std_logic_vector(7 downto 0);  --A7 B6 SEL5 STRT4 UP3 DOWN2 LEFT1 RIGHT0
	clk : in std_logic;
	
	--calculated in top mod
	all_aliens_dead : in std_logic;
	aliens_reached_player : in std_logic;
	player_dead : in std_logic;
	
	--aliens_ship_dead : out std_logic_vector(5 downto 0); --0 means alive 1 means dead, top 5 bits are aliens, bottom bit is ship
	state_logic_vector: out std_logic_vector(1 downto 0) --communicate state - Start(00) gameplay(01) win(10) loss (11)
	);
end entity;


architecture synth of stateCalculation is 


	Type State is (START, GAMEPLAY, WIN, LOSS);
	signal current_game_state : State;
	


begin
	state_logic_vector <= "00" when current_game_state = START else
						  "01" when current_game_state = GAMEPLAY else
						  "10" when current_game_state = WIN else
						  "11" when current_game_state = LOSS else "00"; --default is start state (00) Start


	
	
	process (clk) begin
		if rising_edge(clk) then 
			case current_game_state is
				when START =>
					current_game_state <= GAMEPLAY when buttons(4) = '1' else START; --go to gameplay if we hit start, otherwise stay in start state

				when GAMEPLAY =>
					
					current_game_state <= WIN when all_aliens_dead = '1' else --we win if we kill all aliens
								   LOSS when player_dead else -- we lose if aliens reached us or if we get shot
								   START when buttons(5) = '1' else --hit select
								   GAMEPLAY;
				when WIN =>
					current_game_state <= START when buttons(5) = '1' else WIN; --go to START if we hit select, otherwise stay in WIN screen
				when LOSS =>
					current_game_state <= START when buttons(5) = '1' else LOSS; --go to START if we hit select, otherwise stay in WIN screen
				when others =>
					current_game_state <= START; --if we're in nonvalid state, go to start
			end case;
		end if;
	end process;




end;
