module Project(CLOCK_50, SW, KEY,
				VGA_R, VGA_G, VGA_B,
				VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK,LEDR,LEDG,
				HEX4,HEX5,HEX6,HEX7, PS2_CLK, PS2_DAT);
	
	input CLOCK_50;
	input [17:0] SW;
	input [3:0] KEY;
	
	inout PS2_CLK;
	inout PS2_DAT;
	
	output [17:0] LEDR;
	output [8:0] LEDG;
	output [9:0] VGA_R;
	output [9:0] VGA_G;
	output [9:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK;
	output VGA_SYNC;
	output VGA_CLK;	
	output [6:0] HEX4,HEX5,HEX6,HEX7;
	
	//input to the timer for fsm draw,move.
	wire enable;
	
	//inputs to move mario character
	wire left = ~KEY[3];//((Q1 == 8'h29)&& (Q1 == 8'h6B) && (Q2 == 8'hE0));
	wire right = ~KEY[2];//((Q1 == 8'h74) && (Q2 == 8'hE0));
	wire up = ~KEY[0];//((Q1 == 8'h29) && (Q2 != 8'hF0));
	wire down = ((Q1 == 8'h72) && (Q2 == 8'hE0));
	//end of inputs to move mario character
	
	//vars for drawing and moving enemy image
	wire[2:0] color_enemy;
	reg [7:0] x_start_enemy_d,x_start_enemy_q;
	reg [6:0] y_start_enemy_d,y_start_enemy_q;
	reg [3:0] counter_x_enemy_d,counter_x_enemy_q,counter_y_enemy_d,counter_y_enemy_q;
	//end of vars for drawing and moving enemy image
	
	//vars for drawing and moving mario image
	wire[2:0] color_mario;
	reg [7:0] x_start_mario_d,x_start_mario_q;
	reg [6:0] y_start_mario_d,y_start_mario_q;
	reg [3:0] counter_x_mario_d,counter_x_mario_q,counter_y_mario_d,counter_y_mario_q;
	//end of vars for drawing and moving mario image
	
	//vars for collison Q_brick
	reg [7:0] x_start_Qbrick_d,x_start_Qbrick_q;
	reg [6:0] y_start_Qbrick_d,y_start_Qbrick_q;
	reg [3:0] counter_x_Qbrick_d,counter_x_Qbrick_q,counter_y_Qbrick_d,counter_y_Qbrick_q;
	reg erase_brown_twice_d,erase_brown_twice_q,coll_qbrick_d,coll_qbrick_q;
	
	//vars for mushroom
	wire[2:0] color_mush;
	reg [7:0] x_start_mush_d,x_start_mush_q;
	reg [6:0] y_start_mush_d,y_start_mush_q;
	reg [3:0] counter_x_mush_d,counter_x_mush_q,counter_y_mush_d,counter_y_mush_q;
	reg ani_mush_twice_d,ani_mush_twice_q,mush_go_down_d,mush_go_down_q,mush_go_left_d,mush_go_left_q
		,mush_go_right_d,mush_go_right_q;
	
	//end of vars for collison Q_brick
	
	//outputs sent to vga
	reg [2:0] color_d,color_q;
	reg [7:0] x_d,x_q;
	reg [6:0] y_d,y_q;
	//end of outputs sent to vga
	
	//vars for fsm move,draw
	reg [5:0] state_draw_d,state_draw_q;
	parameter [5:0] SETUP_MAINBACKGROUND = 6'd0, SETUP_MAINMARIO = 6'd1, WAIT_MAIN = 6'd2, MOVE_MAINMARIO = 6'd3, 
					DRAW_MAINBACKGROUND = 6'd4, DRAW_MAINMARIO = 6'd5, SETUP_STAGE1_BACKGROUND = 6'd6, SETUP_MARIO = 6'd7, 
					SETUP_ENEMY = 6'd8, WAIT = 6'd9, ERASE_MARIO = 6'd10, ERASE_ENEMY = 6'd11, ERASE_QBRICK = 6'd12, 
					ERASE_FATMARIO = 6'd13, ERASE_MUSH = 6'd14, ERASE_DEAD_MARIO = 6'd15, MOVE_MARIO = 6'd16, MOVE_ENEMY = 6'd17, 
					MOVE_FATMARIO = 6'd18,MOVE_MUSH = 6'd19, MOVE_DEAD_MARIO = 6'd20, DRAW_MARIO = 6'd21, DRAW_ENEMY = 6'd22, 
					DRAW_MUSH = 6'd23, DRAW_FATMARIO = 6'd24, DRAW_DEAD_MARIO = 6'd25, COLLIDE_ENEMY = 6'd26, COLLIDE_MONEY = 6'd27,
					SETUP_STAGE2_BACKGROUND = 6'd28, SETUP_PRINCESS = 6'd29, SETUP_STAGE2_MARIO = 6'd30, WAIT_STAGE2 = 6'd31, 
					MOVE_STAGE2_MARIO = 6'd32, MOVE_DEAD_STAGE2_MARIO = 6'd33,	DRAW_STAGE2_BACKGROUND = 6'd34, DRAW_PRINCESS = 6'd35, 
					DRAW_STAGE2_MARIO = 6'd36, DRAW_TURTLE = 6'd37,DRAW_DEAD_STAGE2_MARIO = 6'd38, GAME_END = 6'd39, GAME_OVER = 6'd40;
	// end of vars for fsm move,draw
	
	//vars for main_background
	wire[2:0] color_main_background;
	reg [7:0] x_start_mainbckgnd_d,x_start_mainbckgnd_q;
	reg [6:0] y_start_mainbckgnd_d,y_start_mainbckgnd_q;
	reg [7:0] counter_x_mainbckgnd_d,counter_x_mainbckgnd_q;
	reg [6:0] counter_y_mainbckgnd_d,counter_y_mainbckgnd_q;
	//end of vars for main background
	
	//vars for main mario
	wire[2:0] color_main_mario;
	reg [7:0] x_start_mainmario_d,x_start_mainmario_q;
	reg [6:0] y_start_mainmario_d,y_start_mainmario_q;
	reg [2:0] counter_x_mainmario_d,counter_x_mainmario_q;
	reg [3:0] counter_y_mainmario_d,counter_y_mainmario_q;
	//end of vars for main mario
	
	//vars for fsm WAIT
	reg [26:0] counterClock_d, counterClock_q;
	//end of vars for fsm WAIT
	
	//vars for fsm MOVE_ENEMY
	reg leftRight_d,leftRight_q;
	//end of vars from fsm MOVE_ENEMY

	//vars for keyboard control
	wire [7:0] keyboard_control; 
	wire data_received;
	reg [7:0] Q1, Q2;
	//end of vars for keyboard control 
	
	//vars for fsm WAIT_MAIN
	reg [26:0] counterClock_main_d, counterClock_main_q;
	//end of vars for fsm WAIT_MAIN
	
	//vars for stage1 background
	wire[2:0] color_stage1_background;
	reg [7:0] x_start_stage1bckgnd_d,x_start_stage1bckgnd_q;
	reg [6:0] y_start_stage1bckgnd_d,y_start_stage1bckgnd_q;
	reg [7:0] counter_x_stage1bckgnd_d,counter_x_stage1bckgnd_q;
	reg [6:0] counter_y_stage1bckgnd_d,counter_y_stage1bckgnd_q;
	//end of vars for stage1 background
	
	//vars for fat mario
	wire[2:0] color_fat_mario;
	reg [7:0] x_start_fatmario_d,x_start_fatmario_q;
	reg [6:0] y_start_fatmario_d,y_start_fatmario_q;
	reg [3:0] counter_x_fatmario_d,counter_x_fatmario_q;
	reg [4:0] counter_y_fatmario_d,counter_y_fatmario_q;
	//end of vars for fat mario
	
	//vars for collision mush
	reg collision_mush_d,collision_mush_q;
	//end of vars for collision mush
	
	//vars for stage2_background
	wire[2:0] color_stage2_background;
	reg [7:0] x_start_stage2bckgnd_d,x_start_stage2bckgnd_q;
	reg [6:0] y_start_stage2bckgnd_d,y_start_stage2bckgnd_q;
	reg [7:0] counter_x_stage2bckgnd_d,counter_x_stage2bckgnd_q;
	reg [6:0] counter_y_stage2bckgnd_d,counter_y_stage2bckgnd_q;
	//end of vars for stage2 background
	
	//vars for princess
	wire[2:0] color_princess;
	reg [7:0] x_start_princess_d,x_start_princess_q;
	reg [6:0] y_start_princess_d,y_start_princess_q;
	reg [3:0] counter_x_princess_d,counter_x_princess_q;
	reg [4:0] counter_y_princess_d,counter_y_princess_q;
	//end of vars for princess
	
	//vars for stage2 mario
	wire[2:0] color_stage2_mario;
	reg [7:0] x_start_stage2mario_d,x_start_stage2mario_q;
	reg [6:0] y_start_stage2mario_d,y_start_stage2mario_q;
	reg [3:0] counter_x_stage2mario_d,counter_x_stage2mario_q,counter_y_stage2mario_d,counter_y_stage2mario_q;
	//end of vars for stage2 mario
	
	//vars for fsm WAIT_STAGE2
	reg [26:0] counterClock_stage2_d, counterClock_stage2_q;
	//end of vars for fsm WAIT_STAGE2
	
	//vars for turtle
	wire[2:0] color_turtle;
	reg [7:0] x_start_turtle_d,x_start_turtle_q;
	reg [6:0] y_start_turtle_d,y_start_turtle_q;
	reg [4:0] counter_x_turtle_d,counter_x_turtle_q,counter_y_turtle_d,counter_y_turtle_q;
	//end of vars for turtle
	
	//vars for collision princess
	reg collision_princess_d,collision_princess_q;
	//end of vars for collision princess
	
	//vars for mario projectile
	reg [6:0] v_y_d,v_y_q;
	reg [6:0] d_y_d,d_y_q;
	reg setTwice_d,setTwice_q;
	//end of vars for mario projectile
	
	//enemy collision
	reg collision_enemy_d,collision_enemy_q;
	
	//coin collision
	reg collision_coin_d,collision_coin_q;
	
	//vars for dead stage2 mario
	wire[2:0] color_dead_stage2_mario;
	reg [7:0] x_start_dead_stage2mario_d,x_start_dead_stage2mario_q;
	reg [6:0] y_start_dead_stage2mario_d,y_start_dead_stage2mario_q;
	reg [3:0] counter_x_dead_stage2mario_d,counter_x_dead_stage2mario_q,counter_y_dead_stage2mario_d,counter_y_dead_stage2mario_q;
	//end of vars for dead stage2 mario
	
	//vars for ending_background
	wire[2:0] color_ending_background;
	reg [7:0] x_start_endingbckgnd_d,x_start_endingbckgnd_q;
	reg [6:0] y_start_endingbckgnd_d,y_start_endingbckgnd_q;
	reg [7:0] counter_x_endingbckgnd_d,counter_x_endingbckgnd_q;
	reg [6:0] counter_y_endingbckgnd_d,counter_y_endingbckgnd_q;
	//end of vars for ending background
	
	//vars for dead stage1 mario
	wire[2:0] color_dead_stage1_mario;
	reg [7:0] x_start_dead_stage1mario_d,x_start_dead_stage1mario_q;
	reg [6:0] y_start_dead_stage1mario_d,y_start_dead_stage1mario_q;
	reg [3:0] counter_x_dead_stage1mario_d,counter_x_dead_stage1mario_q,counter_y_dead_stage1mario_d,counter_y_dead_stage1mario_q;
	//end of vars for dead stage1 mario
	
	//vars for game over
	reg [3:0] gameover_d, gameover_q;
	
	//vars for ending_background
	wire[2:0] color_gameover;
	reg [7:0] x_start_gameover_d,x_start_gameover_q;
	reg [6:0] y_start_gameover_d,y_start_gameover_q;
	reg [7:0] counter_x_gameover_d,counter_x_gameover_q;
	reg [6:0] counter_y_gameover_d,counter_y_gameover_q;
	//end of vars for ending background
	
	//vars for erase coins
	reg [7:0] x_start_coin_d,x_start_coin_q;
	reg [6:0] y_start_coin_d,y_start_coin_q;
	reg [3:0] counter_x_coin_d,counter_x_coin_q,counter_y_coin_d,counter_y_coin_q;
	//end of vars for erase coins
	
	//vars for levels
	reg [3:0] level_d, level_q;
	
	//vars for the game feature in which the jump will not be stopped even after the player releases the jump button.
	reg condition_up_d,condition_up_q,condition_up_y63_d,condition_up_y63_q,condition_up_y71_d,condition_up_y71_q;
	reg condition_leftup_d,condition_leftup_q,condition_rightup_d,condition_rightup_q;
	reg condition_leftup_y63_d,condition_leftup_y63_q,condition_rightup_y63_d,condition_rightup_y63_q;
	reg condition_leftup_y71_d,condition_leftup_y71_q,condition_rightup_y71_d,condition_rightup_y71_q;
	reg cond2_up_q, cond2_up_d,cond2_rightup_q, cond2_rightup_d,cond2_leftup_q, cond2_leftup_d;
	//end of vars for the game feature in which the jump will not be stopped even after the player releases the jump button.
	
////////////fsm for draw,move//////////////

	//Register for keyboard control
	always@ (posedge CLOCK_50)
	begin
		if(~KEY[0])
		begin
			Q1 <= 0;
			Q2 <= 0;
		end
		else if(data_received == 1)
		begin
			Q1 <= keyboard_control;
			Q2 <= Q1;
		end
	end

	//timer for controlling the speed when the player moves the mario
	halfSecTimer T0(CLOCK_50, enable);
	
	always@ (*)
	begin
	
	//retain the previous state when it is not going into any state
	
	//state that controls this fsm, and outputs to vga
	state_draw_d = state_draw_q;
	color_d = color_q;
	x_d = x_q;
	y_d = y_q;
	
	//enemy image
	x_start_enemy_d = x_start_enemy_q;
	y_start_enemy_d = y_start_enemy_q;	
	counter_x_enemy_d = counter_x_enemy_q;
	counter_y_enemy_d = counter_y_enemy_q;
	
	//mario image
	x_start_mario_d = x_start_mario_q;
	y_start_mario_d = y_start_mario_q;
	counter_x_mario_d = counter_x_mario_q;
	counter_y_mario_d = counter_y_mario_q;
	
	//Counter for WAIT
	counterClock_d = counterClock_q;
	leftRight_d = leftRight_q;
	
	//collision Q_brick
	//Q_brick
	x_start_Qbrick_d = x_start_Qbrick_q;
	y_start_Qbrick_d = y_start_Qbrick_q;
	counter_x_Qbrick_d = counter_x_Qbrick_q;
	counter_y_Qbrick_d = counter_y_Qbrick_q;
	
	//boolean wire for Q brick and mushroom
	erase_brown_twice_d = erase_brown_twice_q;
	coll_qbrick_d = coll_qbrick_q;
	ani_mush_twice_d = ani_mush_twice_q;
	mush_go_down_d = mush_go_down_q;
	mush_go_left_d = mush_go_left_q;
	mush_go_right_d = mush_go_right_q;
	
	//mushroom image
	x_start_mush_d = x_start_mush_q;
	y_start_mush_d = y_start_mush_q;
	counter_x_mush_d = counter_x_mush_q;
	counter_y_mush_d = counter_y_mush_q;
	
	//main_background
	x_start_mainbckgnd_d = x_start_mainbckgnd_q;
	y_start_mainbckgnd_d = y_start_mainbckgnd_q;
	counter_x_mainbckgnd_d = counter_x_mainbckgnd_q;
	counter_y_mainbckgnd_d = counter_y_mainbckgnd_q;
	
	//main_mario
	x_start_mainmario_d = x_start_mainmario_q;
	y_start_mainmario_d = y_start_mainmario_q;
	counter_x_mainmario_d = counter_x_mainmario_q;
	counter_y_mainmario_d = counter_y_mainmario_q;
	
	//fsm WAIT_MAIN
	counterClock_main_d = counterClock_main_q;
	
	//stage1_background
	x_start_stage1bckgnd_d = x_start_stage1bckgnd_q;
	y_start_stage1bckgnd_d = y_start_stage1bckgnd_q;
	counter_x_stage1bckgnd_d = counter_x_stage1bckgnd_q;
	counter_y_stage1bckgnd_d = counter_y_stage1bckgnd_q;
	
	//fat_mario
	x_start_fatmario_d = x_start_fatmario_q;
	y_start_fatmario_d = y_start_fatmario_q;
	counter_x_fatmario_d = counter_x_fatmario_q;
	counter_y_fatmario_d = counter_y_fatmario_q;
	
	//Collision mush
	collision_mush_d = collision_mush_q;
	
	//stage2_background
	x_start_stage2bckgnd_d = x_start_stage2bckgnd_q;
	y_start_stage2bckgnd_d = y_start_stage2bckgnd_q;
	counter_x_stage2bckgnd_d = counter_x_stage2bckgnd_q;
	counter_y_stage2bckgnd_d = counter_y_stage2bckgnd_q;
	
	//princess
	x_start_princess_d = x_start_princess_q;
	y_start_princess_d = y_start_princess_q;
	counter_x_princess_d = counter_x_princess_q;
	counter_y_princess_d = counter_y_princess_q;
	
	//stage2 mario image
	x_start_stage2mario_d = x_start_stage2mario_q;
	y_start_stage2mario_d = y_start_stage2mario_q;
	counter_x_stage2mario_d = counter_x_stage2mario_q;
	counter_y_stage2mario_d = counter_y_stage2mario_q;
	
	//fsm WAIT_STAGE2
	counterClock_stage2_d = counterClock_stage2_q;
	
	//turtle
	x_start_turtle_d = x_start_turtle_q;
	y_start_turtle_d = y_start_turtle_q;
	counter_x_turtle_d = counter_x_turtle_q;
	counter_y_turtle_d = counter_y_turtle_q;
	
	//Collision princess
	collision_princess_d = collision_princess_q;
	
	//Mario projectile
	v_y_d = v_y_q;
	d_y_d = d_y_q;
	setTwice_d = setTwice_q;
	
	//enemy collision
	collision_enemy_d = collision_enemy_q;
	
	//coin collision
	collision_coin_d = collision_coin_q;
	
	//dead stage2 mario image
	x_start_dead_stage2mario_d = x_start_dead_stage2mario_q;
	y_start_dead_stage2mario_d = y_start_dead_stage2mario_q;
	counter_x_dead_stage2mario_d = counter_x_dead_stage2mario_q;
	counter_y_dead_stage2mario_d = counter_y_dead_stage2mario_q;
	
	//Ending Background
	x_start_endingbckgnd_d = x_start_endingbckgnd_q;
	y_start_endingbckgnd_d = y_start_endingbckgnd_q;
	counter_x_endingbckgnd_d = counter_x_endingbckgnd_q;
	counter_y_endingbckgnd_d = counter_y_endingbckgnd_q;
	
	//dead stage1 mario image
	x_start_dead_stage1mario_d = x_start_dead_stage1mario_q;
	y_start_dead_stage1mario_d = y_start_dead_stage1mario_q;
	counter_x_dead_stage1mario_d = counter_x_dead_stage1mario_q;
	counter_y_dead_stage1mario_d = counter_y_dead_stage1mario_q;
	
	//game over
	gameover_d = gameover_q;
	
	//GameOver Background
	x_start_gameover_d = x_start_gameover_q;
	y_start_gameover_d = y_start_gameover_q;
	counter_x_gameover_d = counter_x_gameover_q;
	counter_y_gameover_d = counter_y_gameover_q;
	
	//Erase coins
	x_start_coin_d = x_start_coin_q;
	y_start_coin_d = y_start_coin_q;
	counter_x_coin_d = counter_x_coin_q;
	counter_y_coin_d = counter_y_coin_q;
	
	//vars for levels
	level_d = level_q;
	
	//jump feature where the jump is not stopped even after the button is released
	condition_up_d = condition_up_q;
	condition_leftup_d = condition_leftup_q;
	condition_rightup_d = condition_rightup_q;
	
	condition_up_y63_d = condition_up_y63_q;
	condition_leftup_y63_d = condition_leftup_y63_q;
	condition_rightup_y63_d = condition_rightup_y63_q;
	
	condition_up_y71_d = condition_up_y71_q;
	condition_leftup_y71_d = condition_leftup_y71_q;
	condition_rightup_y71_d = condition_rightup_y71_q;
	
	cond2_up_d = cond2_up_q;
	cond2_leftup_d = cond2_leftup_q;
	cond2_rightup_d = cond2_rightup_q;
	
	//end of retaining the previous state when it is not going into any state
	
	case (state_draw_q)
	
	//draws main page background on the screen
	SETUP_MAINBACKGROUND:
	begin
		counter_x_coin_d = 4'd0;
		counter_y_coin_d = 4'd0;
		counter_x_gameover_d = 8'd0;
		counter_y_gameover_d = 7'd0;
		counter_x_endingbckgnd_d = 8'd0;
		counter_y_endingbckgnd_d = 7'd0;
		gameover_d = 4'd0;
		level_d = 4'd0;
		
		//draw image
		if (counter_y_mainbckgnd_q <= 7'd119)
		begin
			color_d = color_main_background;
			x_start_mainbckgnd_d = 8'd0;
			y_start_mainbckgnd_d = 7'd0;
			x_d = x_start_mainbckgnd_d + counter_x_mainbckgnd_q;
			y_d = y_start_mainbckgnd_d + counter_y_mainbckgnd_q;
			
			counter_x_mainbckgnd_d = counter_x_mainbckgnd_q + 8'd01;
			if (counter_x_mainbckgnd_q == 8'd159)
			begin
				counter_y_mainbckgnd_d = counter_y_mainbckgnd_q + 7'd01; 
				counter_x_mainbckgnd_d = 8'd00;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_mainbckgnd_q == 8'd159) && (counter_y_mainbckgnd_q == 7'd119))
		begin
			counter_x_mainbckgnd_d = 8'd00;
			counter_y_mainbckgnd_d = 7'd00;
			state_draw_d = SETUP_MAINMARIO;
		end
		else
			state_draw_d = SETUP_MAINBACKGROUND;
	end
	
	//Draws the mario on the main page on the screen
	SETUP_MAINMARIO:
	begin
		//draw image
		if (counter_y_mainmario_q <= 4'd11)
		begin
			color_d = color_main_mario;
			x_start_mainmario_d = 8'd79;
			y_start_mainmario_d = 7'd108;
			x_d = x_start_mainmario_d + counter_x_mainmario_q;
			y_d = y_start_mainmario_d + counter_y_mainmario_q;
			
			counter_x_mainmario_d = counter_x_mainmario_q + 3'd01;
			if (counter_x_mainmario_q == 3'd5)
			begin
				counter_y_mainmario_d = counter_y_mainmario_q + 4'd01; 
				counter_x_mainmario_d = 3'd00;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_mainmario_q == 3'd5) && (counter_y_mainmario_q == 4'd11))
		begin
			counter_x_mainmario_d = 3'd00;
			counter_y_mainmario_d = 4'd00;
			state_draw_d = WAIT_MAIN;
		end
		else
			state_draw_d = SETUP_MAINMARIO;
	end
	
	//Wait state for main page
	WAIT_MAIN:
	begin
		counterClock_main_d = counterClock_main_q + 27'd01;
		if (counterClock_main_q == 26'd5000000)
		begin
				if(y_start_mainmario_q == 7'd94)//Transition from main page to stage 1
					state_draw_d = SETUP_STAGE1_BACKGROUND;
				else
				begin
					counterClock_main_d = 26'd0;
					state_draw_d = MOVE_MAINMARIO;
				end
		end
		else
				state_draw_d = WAIT_MAIN;
	end
	
	//Moves main mario
	MOVE_MAINMARIO:
	begin
		if (Q1 == 8'h75 && Q2 == 8'hE0)	begin y_start_mainmario_d = y_start_mainmario_q-7'd01;state_draw_d = DRAW_MAINBACKGROUND; end				
		else state_draw_d = DRAW_MAINBACKGROUND;		
	end
	
	//Draws main page background
	DRAW_MAINBACKGROUND:
	begin
		//draw image
		if (counter_y_mainbckgnd_q <= 7'd119)
		begin
			color_d = color_main_background;
			x_start_mainbckgnd_d = 8'd0;
			y_start_mainbckgnd_d = 7'd0;
			x_d = x_start_mainbckgnd_d + counter_x_mainbckgnd_q;
			y_d = y_start_mainbckgnd_d + counter_y_mainbckgnd_q;
			
			counter_x_mainbckgnd_d = counter_x_mainbckgnd_q + 8'd01;
			if (counter_x_mainbckgnd_q == 8'd159)
			begin
				counter_y_mainbckgnd_d = counter_y_mainbckgnd_q + 7'd01; 
				counter_x_mainbckgnd_d = 8'd00;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_mainbckgnd_q == 8'd159) && (counter_y_mainbckgnd_q == 7'd119))
		begin
			counter_x_mainbckgnd_d = 8'd00;
			counter_y_mainbckgnd_d = 7'd00;
			state_draw_d = DRAW_MAINMARIO;
		end
		else
			state_draw_d = DRAW_MAINBACKGROUND;
	end
	
	//Draws main mario
	DRAW_MAINMARIO:
	begin
		//draw image
		if (counter_y_mainmario_q <= 4'd11)
		begin
			color_d = color_main_mario;
			x_d = x_start_mainmario_d + counter_x_mainmario_q;
			y_d = y_start_mainmario_d + counter_y_mainmario_q;
			
			counter_x_mainmario_d = counter_x_mainmario_q + 3'd01;
			if (counter_x_mainmario_q == 3'd5)
			begin
				counter_y_mainmario_d = counter_y_mainmario_q + 4'd01; 
				counter_x_mainmario_d = 3'd00;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_mainmario_q == 3'd5) && (counter_y_mainmario_q == 4'd11))
		begin
			counter_x_mainmario_d = 3'd00;
			counter_y_mainmario_d = 4'd00;
			state_draw_d = WAIT_MAIN;
		end
		else
			state_draw_d = DRAW_MAINMARIO;
	end
	
	//Draws stage 1 background
	SETUP_STAGE1_BACKGROUND:
	begin
		
		level_d = 4'd1;
		//draw image
		if (gameover_q == 4'd3)
		begin
			state_draw_d = GAME_OVER;
		end
		
		else
		begin
			if (counter_y_stage1bckgnd_q <= 7'd119)
			begin
				color_d = color_stage1_background;
				x_start_stage1bckgnd_d = 8'd0;
				y_start_stage1bckgnd_d = 7'd0;
				x_d = x_start_stage1bckgnd_d + counter_x_stage1bckgnd_q;
				y_d = y_start_stage1bckgnd_d + counter_y_stage1bckgnd_q;
				
				counter_x_stage1bckgnd_d = counter_x_stage1bckgnd_q + 8'd01;
				if (counter_x_stage1bckgnd_q == 8'd159)
				begin
					counter_y_stage1bckgnd_d = counter_y_stage1bckgnd_q + 7'd01; 
					counter_x_stage1bckgnd_d = 8'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_stage1bckgnd_q == 8'd159) && (counter_y_stage1bckgnd_q == 7'd119))
			begin
				counter_x_stage1bckgnd_d = 8'd0;
				counter_y_stage1bckgnd_d = 7'd0;
				state_draw_d = SETUP_MARIO;
			end
			else
				state_draw_d = SETUP_STAGE1_BACKGROUND;
		end
	end
	
	//This draws mario on the screen and is called only at the beginning of the game.
	SETUP_MARIO: 
	begin 
		//besides, also set all s that are used in subsequent states to 1'b0;
		erase_brown_twice_d = 1'b0;
		coll_qbrick_d = 1'b0;
		counter_x_mush_d = 4'd0;
		counter_y_mush_d = 4'd0;
		ani_mush_twice_d = 1'b0;
		mush_go_down_d = 1'b0;
		mush_go_left_d = 1'b0;
		mush_go_right_d = 1'b0;
		x_start_mush_d = 8'd74;
		y_start_mush_d = 7'd63;
		collision_mush_d = 1'b0;
		x_start_dead_stage1mario_d = 4'd0;
		y_start_dead_stage1mario_d = 4'd0;
		v_y_d = 7'd0;
		d_y_d = 7'd0;
		setTwice_d = 1'b0;
		collision_enemy_d = 1'b0;
		collision_coin_d = 1'b0;
		x_start_fatmario_d = 8'd0;
		y_start_fatmario_d = 7'd0;
		condition_up_d = 1'b0;
		condition_up_y63_d = 1'b0;
		condition_leftup_d = 1'b0;
		condition_leftup_y63_d = 1'b0;
		condition_rightup_d = 1'b0;
		condition_rightup_y63_d = 1'b0;
		condition_leftup_y71_d = 1'b0;
		condition_rightup_y71_d = 1'b0;
		condition_up_y71_d = 1'b0;
		cond2_up_d = 1'b0;
		cond2_leftup_d = 1'b0;
		cond2_rightup_d = 1'b0;
		
		//draw mario
		if (counter_y_mario_q <= 4'd09)
		begin
			color_d = color_mario;
			x_start_mario_d = 8'd23;
			y_start_mario_d = 7'd97;
			x_d = x_start_mario_d + counter_x_mario_q;
			y_d = y_start_mario_d + counter_y_mario_q;
			
			counter_x_mario_d = counter_x_mario_q + 4'd01;
			if (counter_x_mario_q == 4'd04)
			begin
			counter_y_mario_d = counter_y_mario_q+4'd01; 
			counter_x_mario_d = 0;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_mario_q == 4'd04) && (counter_y_mario_q == 4'd09))
			state_draw_d = SETUP_ENEMY;
		else
			state_draw_d = SETUP_MARIO;
		
	end
	
	//draw
	SETUP_ENEMY: 
	begin
		//draw image
		if (counter_y_enemy_q <= 4'd09)
		begin
			color_d = color_enemy;
			x_start_enemy_d = 8'd149;
			y_start_enemy_d = 7'd97;
			x_d = x_start_enemy_d + counter_x_enemy_q;
			y_d = y_start_enemy_d + counter_y_enemy_q;
			
			counter_x_enemy_d = counter_x_enemy_q + 4'd01;
			if (counter_x_enemy_q == 4'd09)
			begin
				counter_y_enemy_d = counter_y_enemy_q + 4'd01; 
				counter_x_enemy_d = 4'd00;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_enemy_q == 4'd09) && (counter_y_enemy_q == 4'd09))
			state_draw_d = WAIT;
		else
			state_draw_d = SETUP_ENEMY;
	end
	
	//stay at the wait state for 0.1s, then go to next state.
	WAIT: 
	begin
		counterClock_d = counterClock_q + 27'd01;
		if(collision_coin_q == 1'b1 && y_start_dead_stage1mario_q == 7'd30)
		begin
			if(counterClock_q == 26'd50000000)
			begin
				gameover_d = gameover_q + 4'd01;
				counterClock_d = 26'd0;
				state_draw_d = SETUP_STAGE1_BACKGROUND;
			end
			else
				state_draw_d = WAIT;
		end
		
		else if(collision_enemy_q == 1'b1 && y_start_dead_stage1mario_q == 7'd82)
		begin
			if(counterClock_q == 26'd50000000)
			begin
				gameover_d = gameover_q + 4'd01;
				counterClock_d = 26'd0;
				state_draw_d = SETUP_STAGE1_BACKGROUND;
			end
			else
				state_draw_d = WAIT;
		end
		
		else if(collision_mush_q == 1'b1 && y_start_fatmario_q == 7'd101)
		begin
			if(counterClock_q == 26'd50000000)
			begin
				gameover_d = gameover_q + 4'd01;
				counterClock_d = 26'd0;
				state_draw_d = SETUP_STAGE1_BACKGROUND;
			end
			else
				state_draw_d = WAIT;
		end
		
		else if (coll_qbrick_q && x_start_mario_q >= 8'd19 && x_start_mario_q <= 8'd100 && y_start_mush_q >= 7'd77 && y_start_mush_q <= 7'd97
				 && y_start_mario_q >= 7'd87 && y_start_mario_q <= 7'd97)
		begin
			if (((x_start_mario_q < x_start_mush_q) &&(x_start_mario_q + 8'd05  >= x_start_mush_q)) || 
				((x_start_mush_q + 8'd10 >= x_start_mario_q) && (x_start_mario_q >= x_start_mush_q)))
			begin
				collision_mush_d = 1'b1;	
				//erase the mushroom
				if (counter_y_mush_q <= 4'd09)
				begin
					color_d = 3'b011;
					x_d = x_start_mush_d + counter_x_mush_q;
					y_d = y_start_mush_d + counter_y_mush_q;
					
					counter_x_mush_d = counter_x_mush_q + 4'd01;
					if (counter_x_mush_q == 4'd09)
					begin
						counter_y_mush_d = counter_y_mush_q + 4'd01; 
						counter_x_mush_d = 4'd00;
					end
				end
				else if (counterClock_q == 26'd5000000)
				begin
							counterClock_d = 26'd0;
							counter_x_mario_d = 4'd00;
							counter_y_mario_d = 4'd00;
							counter_x_enemy_d = 4'd00;
							counter_y_enemy_d = 4'd00;
							state_draw_d = ERASE_MARIO;
				end
				else
					state_draw_d = WAIT;
			end
			else if (counterClock_q == 26'd5000000)
				begin
							counterClock_d = 26'd0;
							counter_x_mario_d = 4'd00;
							counter_y_mario_d = 4'd00;
							counter_x_enemy_d = 4'd00;
							counter_y_enemy_d = 4'd00;
							state_draw_d = ERASE_MARIO;
				end
			else
				state_draw_d = WAIT;
		end
			
		else if (counterClock_q == 26'd5000000)
		begin
				if (x_start_mario_q == 8'd155)
					state_draw_d = SETUP_STAGE2_BACKGROUND;
				else
				begin
					counterClock_d = 26'd0;
					counter_x_mario_d = 4'd00;
					counter_y_mario_d = 4'd00;
					counter_x_enemy_d = 4'd00;
					counter_y_enemy_d = 4'd00;
					state_draw_d = ERASE_MARIO;
				end
		end
		
		else
				state_draw_d = WAIT;
	end
	
	//erase mario,once finished, go to next state
	ERASE_MARIO:
	begin
		if(collision_mush_q == 1'b0)
		begin
			if (counter_y_mario_q <= 4'd09)
			begin
				color_d = 3'b011;
				x_d = x_start_mario_d + counter_x_mario_q;
				y_d = y_start_mario_d + counter_y_mario_q;
				
				counter_x_mario_d = counter_x_mario_q + 4'd01;
				if (counter_x_mario_q == 4'd04)
				begin
				counter_y_mario_d = counter_y_mario_q + 4'd01; 
				counter_x_mario_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_mario_q == 4'd04) && (counter_y_mario_q == 4'd09))
				begin
				counter_x_mario_d = 4'd0;
				counter_y_mario_d = 4'd0;
				state_draw_d = ERASE_ENEMY;
				end
			else
				state_draw_d = ERASE_MARIO;
		end
		else
				state_draw_d = ERASE_ENEMY;
	end
	
	//erase enemy,once finished, go to next state
	ERASE_ENEMY:
	begin
		if (counter_y_enemy_q <= 4'd09)
		begin
			color_d = 3'b011;
			x_d = x_start_enemy_d + counter_x_enemy_q;
			y_d = y_start_enemy_d + counter_y_enemy_q;
			
			counter_x_enemy_d = counter_x_enemy_q + 4'd01;
			if (counter_x_enemy_q == 4'd09)
			begin
			counter_y_enemy_d = counter_y_enemy_q + 4'd01; 
			counter_x_enemy_d = 4'd00;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_enemy_q == 4'd09) && (counter_y_enemy_q == 4'd09))
			begin
			counter_x_enemy_d = 4'd0;
			counter_y_enemy_d = 4'd0;
			state_draw_d = ERASE_QBRICK;
			end
		else
			state_draw_d = ERASE_ENEMY;
	end
	
	///////////new event:  with "question_mark" brick/////////////
	ERASE_QBRICK:
	begin
		if ((x_start_mario_q >= 8'd71) && (x_start_mario_q <= 8'd80) && (y_start_mario_q == 7'd82) && (erase_brown_twice_q == 1'b0))
		begin
			//erase Qbrick: dimension = 8x9 excluding boundaries
			if (counter_y_Qbrick_q <= 4'd06)
			begin
				color_d = 3'b110;
				x_start_Qbrick_d = 8'd74;
				y_start_Qbrick_d = 7'd74;
				x_d = x_start_Qbrick_d + counter_x_Qbrick_q;
				y_d = y_start_Qbrick_d + counter_y_Qbrick_q;
				coll_qbrick_d = 1'b1;
				
				counter_x_Qbrick_d = counter_x_Qbrick_q + 4'd01;
			if (counter_x_Qbrick_q == 4'd07)
			begin
				counter_y_Qbrick_d = counter_y_Qbrick_q + 4'd01; 
				counter_x_Qbrick_d = 4'd00;
			end
			end	
		
			//condition for choosing next state
			if ((counter_x_Qbrick_q == 4'd07) && (counter_y_Qbrick_q == 4'd06))
			begin
				counter_x_Qbrick_d = 4'd00;
				counter_y_Qbrick_d = 4'd00;
				erase_brown_twice_d = 1'b1;
				state_draw_d = ERASE_FATMARIO;
			end
			else
				state_draw_d = ERASE_QBRICK;
		
		end
		else
			state_draw_d = ERASE_FATMARIO;
	end
	
	//erase fat mario
	ERASE_FATMARIO:
	begin
		if(collision_mush_q == 1'b1 && y_start_fatmario_q != 7'd101)
		begin
			//draw image
			if (counter_y_fatmario_q <= 5'd19)
			begin
				color_d = 3'b011;
				x_d = x_start_fatmario_d + counter_x_fatmario_q;
				y_d = y_start_fatmario_d + counter_y_fatmario_q;
				
				counter_x_fatmario_d = counter_x_fatmario_q + 4'd01;
				if (counter_x_fatmario_q == 4'd09)
				begin
				counter_y_fatmario_d = counter_y_fatmario_q + 5'd01; 
				counter_x_fatmario_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_fatmario_q == 4'd09) && (counter_y_fatmario_q == 5'd19))
			begin
				counter_x_fatmario_d = 4'd00;
				counter_y_fatmario_d = 5'd00;
				state_draw_d = ERASE_MUSH;
			end
			else
				state_draw_d = ERASE_FATMARIO;
		end
		
		else
				state_draw_d = ERASE_MUSH;
	end
	
	//erase the mushroom
	ERASE_MUSH:
	begin
		if (coll_qbrick_q && collision_mush_q == 1'b0)
		begin
			//1st time it erases nothing, since mushroom is not drawn yet.
			//erase mush: dimension = 8x9 excluding boundaries
			if (counter_y_mush_q <= 4'd09)
			begin
				color_d = 3'b011;
				x_d = x_start_mush_d + counter_x_mush_q;
				y_d = y_start_mush_d + counter_y_mush_q;
				
				counter_x_mush_d = counter_x_mush_q + 4'd01;
				if (counter_x_mush_q == 4'd09)
				begin
					counter_y_mush_d = counter_y_mush_q + 4'd01; 
					counter_x_mush_d = 4'd00;
				end
			end
			
				//condition for choosing next state
				if ((counter_x_mush_q == 4'd09) && (counter_y_mush_q == 4'd09))
				begin
					counter_x_mush_d = 4'd00;
					counter_y_mush_d = 4'd00;
					mush_go_left_d = 1'b1;
					state_draw_d = ERASE_DEAD_MARIO;
				end
				else
				begin
					state_draw_d = ERASE_MUSH;
				end
		end
		
		else
			state_draw_d = ERASE_DEAD_MARIO;
			
	end
	
	//Erases dead mario after mario is dead
	ERASE_DEAD_MARIO:
	begin
	
		//a game feature in which the animation of jump is not stopped even when the player releases the jump button after being pressed once.
		//for all boundaries except boundary 1 
		if ((!condition_leftup_q) && !(y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111))
		begin
			if (left &&up)
			begin
				condition_leftup_d = 1'b1;
				condition_up_d = 1'b0;
			end
			else
				condition_leftup_d = 1'b0;
		end
		
		if ((!condition_rightup_q) && !(y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111)) 
		begin
			if (((right) &&(up)) || ((condition_up_q) && (right)))
			begin
				condition_rightup_d = 1'b1;
				condition_up_d = 1'b0;
			end
			else
				condition_rightup_d = 1'b0;
		end
		
		if ((!condition_up_q) && !(y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111)) 
		begin
			if (up)
				condition_up_d = 1'b1;
			else
				condition_up_d = 1'b0;
		end
		
		//for boundary 1: sky above bricks
		if ((!condition_leftup_y63_q) && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111) 
		begin
			if ((left) &&(up) || ((condition_up_y63_q) && (left)) || (condition_up_q)/* || (condition_rightup_y71_q)*/)
			begin
				condition_leftup_y63_d = 1'b1;
				condition_up_y63_d = 1'b0;
				condition_up_d = 1'b0;
				//condition_rightup_y71_d = 1'b0;
			end
			else
				condition_leftup_y63_d = 1'b0;
		end
		
		if ((!condition_rightup_y63_q) && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111) 
		begin
			if (((right) &&(up)) || ((condition_up_y63_q) && (right)) || (condition_up_q) || (condition_rightup_y71_q))
			begin
				condition_up_d = 1'b0;
				condition_rightup_y63_d = 1'b1;
				condition_up_y63_d = 1'b0;
				condition_rightup_y71_d = 1'b0;
			end
			else
				condition_rightup_y63_d = 1'b0;
		end
		if ((!condition_up_y63_q) && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111) 
		begin
			if(up)
				condition_up_y63_d = 1'b1;
			else
				condition_up_y63_d = 1'b0;
		end
		
		if(collision_coin_q == 1'b1 && y_start_dead_stage1mario_q != 7'd30)
		begin
			//draw dead stage 2 mario
			if (counter_y_dead_stage1mario_q <= 4'd13)
			begin
				color_d = 3'b011;
				x_d = x_start_dead_stage1mario_d + counter_x_dead_stage1mario_q;
				y_d = y_start_dead_stage1mario_d + counter_y_dead_stage1mario_q;
				
				counter_x_dead_stage1mario_d = counter_x_dead_stage1mario_q + 4'd01;
				if (counter_x_dead_stage1mario_q == 4'd04)
				begin
				counter_y_dead_stage1mario_d = counter_y_dead_stage1mario_q+4'd01; 
				counter_x_dead_stage1mario_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_dead_stage1mario_q == 4'd04) && (counter_y_dead_stage1mario_q == 4'd13))
			begin	
				counter_x_dead_stage1mario_d = 4'd00;
				counter_y_dead_stage1mario_d = 4'd00;
				state_draw_d = MOVE_MARIO;
			end
			else
				state_draw_d = ERASE_DEAD_MARIO;
		end
		else if(collision_enemy_q == 1'b1 && y_start_dead_stage1mario_q != 7'd82)
		begin
			//draw dead stage 2 mario
			if (counter_y_dead_stage1mario_q <= 4'd13)
			begin
				color_d = 3'b011;
				x_d = x_start_dead_stage1mario_d + counter_x_dead_stage1mario_q;
				y_d = y_start_dead_stage1mario_d + counter_y_dead_stage1mario_q;
				
				counter_x_dead_stage1mario_d = counter_x_dead_stage1mario_q + 4'd01;
				if (counter_x_dead_stage1mario_q == 4'd04)
				begin
				counter_y_dead_stage1mario_d = counter_y_dead_stage1mario_q+4'd01; 
				counter_x_dead_stage1mario_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_dead_stage1mario_q == 4'd04) && (counter_y_dead_stage1mario_q == 4'd13))
			begin	
				counter_x_dead_stage1mario_d = 4'd00;
				counter_y_dead_stage1mario_d = 4'd00;
				state_draw_d = MOVE_MARIO;
			end
			else
				state_draw_d = ERASE_DEAD_MARIO;
		end
		else
			state_draw_d = MOVE_MARIO;
	end
	
	//move the mario 
	MOVE_MARIO:
	begin
	
	//condition for jumping motion, determined by the keys.
	//all boundaries except boundary 1
	if ((condition_leftup_q) && (y_start_mario_q == 7'd97))
			condition_leftup_d = 1'b0;
	if ((condition_rightup_q) && (y_start_mario_q == 7'd97))
			condition_rightup_d = 1'b0;
	if ((condition_up_q) && (y_start_mario_q == 7'd97))
			condition_up_d = 1'b0;
	
	//for boundary 1
	if ((condition_leftup_y63_q) && (y_start_mario_q == 7'd63))
			condition_leftup_y63_d = 1'b0;
	if ((condition_rightup_y63_q) && (y_start_mario_q == 7'd63))
			condition_rightup_y63_d = 1'b0;
	if ((condition_up_y63_q) && (y_start_mario_q == 7'd63))
			condition_up_y63_d = 1'b0;
			
	/*
	Note: Boundary Table
	Boundary 1: 48 <= x <= 111, 0 <= y <= 63; (sky above the bricks)
	Boundary 2: 0  <= x <  48 , 0 <= y <= 63; (region before the bricks)   
	Boundary 6: 111 < x <= 155, 0 <= y <= 97; (region after the bricks)
	
	const coordinate:
	1.ground : y = 97;	
	*/
	if(collision_mush_q == 1'b0 && collision_enemy_q == 1'b0 && collision_coin_q == 1'b0)
		begin
		/******************************************Boundary 1********************************************************/
		//sky above the bricks
		if (y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111)
			begin
				if (condition_rightup_y63_q && (y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111))
					begin 
						//do not fall into the brick 
						if ((v_y_q >= 7'd9) && (y_start_mario_q >= 7'd56 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111))
						begin
							y_start_mario_d = 7'd63;
							state_draw_d = MOVE_ENEMY; 
						end 
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							x_start_mario_d = x_start_mario_q+8'd2; 
							y_start_mario_d = y_start_mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end
					end
				else if (condition_leftup_y63_q && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111)
					begin 
						//do not fall into the brick 
						if ((v_y_q >= 7'd9) && (y_start_mario_q >= 7'd56 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111))
						begin
							y_start_mario_d = 7'd63;
							state_draw_d = MOVE_ENEMY; 
						end 
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							x_start_mario_d = x_start_mario_q-8'd2; 
							y_start_mario_d = y_start_mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end
					end
				else if (left && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111)    
					begin 
						v_y_d = 7'd0;
						setTwice_d = 1'b0;
						d_y_d = 7'd0;
						x_start_mario_d = x_start_mario_q-8'd1; 
						state_draw_d = MOVE_ENEMY; 
					end
				
				else if (right && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111)
					begin 
						v_y_d = 7'd0;
						setTwice_d = 1'b0;
						d_y_d = 7'd0;
						x_start_mario_d = x_start_mario_q+8'd1; 
						state_draw_d = MOVE_ENEMY; 
					end
				else if (condition_up_y63_q && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111)   
					begin	
						//do not fall into the brick 
						if ((v_y_q >= 7'd9) && (y_start_mario_q >= 7'd52 && y_start_mario_q <= 7'd63 && x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111))
						begin
							y_start_mario_d = 7'd63;
							state_draw_d = MOVE_ENEMY; 
						end 
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							y_start_mario_d = y_start_mario_q-7'd9 + v_y_q;	
							state_draw_d = MOVE_ENEMY; 	
						end
					
					end
				else
				begin
						v_y_d = 7'd0;
						setTwice_d = 1'b0;
						d_y_d = 7'd0;
						state_draw_d = MOVE_ENEMY;
				end
			end
		/******************************************End of Boundary 1********************************************************/

		/******************************************Boundary 2********************************************************/
		else if(x_start_mario_q >= 8'd0 && x_start_mario_q < 8'd48 && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd97)
			begin
			
				//mario is on the pipe in this range.
				
				if (right && up && x_start_mario_q >= 8'd1 && x_start_mario_q < 8'd48 && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd97)
					begin 
						//do not fall into the pipe
						if ((v_y_q >= 7'd9) && (d_y_q >= 7'd0) && (y_start_mario_q >= 7'd65 && y_start_mario_q <= 7'd71 && x_start_mario_q >= 8'd0 && x_start_mario_q <= 8'd20))
						begin
							x_start_mario_d = 7'd1;
							y_start_mario_d = 7'd71;
							state_draw_d = MOVE_ENEMY; 
						end 
						//do not fall into the ground
						else if ((v_y_q >= 7'd9) && (d_y_q >= 7'd0) && (y_start_mario_q >= 7'd91 && y_start_mario_q <= 7'd97 && x_start_mario_q >= 8'd21 && x_start_mario_q < 8'd48))
						begin
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end
						//do not touch the bricks
						else if ((x_start_mario_q >= 8'd44 && x_start_mario_q <= 8'd47) && (y_start_mario_q >= 7'd60 && y_start_mario_q <= 7'd90))
						begin
							if ((!setTwice_q) && (y_start_mario_q >= 7'd71))
							begin
								x_start_mario_d = 8'd47; 
								y_start_mario_d = 7'd71;
								setTwice_d = 1'b1;
								state_draw_d = MOVE_ENEMY;
							end
							else 
							begin
								d_y_d = d_y_q+7'd1;
								x_start_mario_d = 8'd47; 
								y_start_mario_d = y_start_mario_q + d_y_q;		
								state_draw_d = MOVE_ENEMY;
							end
						end
						//safe to fall down
						else
						begin
							v_y_d = v_y_q+7'd1;
							x_start_mario_d = x_start_mario_q+8'd2; 
							y_start_mario_d = y_start_mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end
					end
		
				else if (left && up && x_start_mario_q >= 8'd1 && x_start_mario_q < 8'd48 && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd97)
					begin 
						//do not fall into the pipe while the mario is falling down onto the pipe.
						if ((v_y_q >= 7'd9) && (y_start_mario_q >= 7'd61 && y_start_mario_q <= 7'd71 && x_start_mario_q > 8'd6 && x_start_mario_q <= 8'd22))
						begin
							y_start_mario_d = 7'd71;
							state_draw_d = MOVE_ENEMY; 
						end 
						//while jumping to the left corner, restrict the mario to stay at x = 1, y = 71 to prevent it jumps off the boundary.
						else if ((y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd71 && x_start_mario_q >= 8'd0 && x_start_mario_q <= 8'd6))
						begin
							x_start_mario_d = 7'd2;
							y_start_mario_d = 7'd71;
							state_draw_d = MOVE_ENEMY;
						end
						//do not fall into the ground
						else if ((v_y_q >= 7'd9) && (y_start_mario_q >= 7'd87 && y_start_mario_q <= 7'd97 && x_start_mario_q > 8'd22 && x_start_mario_q < 8'd48))
						begin
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end
						//while jumping, do not touch the body of the pipe. 
						else if ((y_start_mario_q >= 7'd71 && y_start_mario_q <= 7'd97 && x_start_mario_q >= 8'd15 && x_start_mario_q <= 8'd22))
						begin
							v_y_d = v_y_q+7'd1; 
							y_start_mario_d = y_start_mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 
						end
						//safe to jump and fall down
						else
						begin
							v_y_d = v_y_q+7'd1;
							x_start_mario_d = x_start_mario_q-8'd2; 
							y_start_mario_d = y_start_mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end
					end
		
				else if (left && x_start_mario_q >= 8'd1 && x_start_mario_q < 8'd48 && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd97)
					begin		
						if (x_start_mario_q > 8'd22 && x_start_mario_q < 8'd48 &&  y_start_mario_q == 7'd97)
						begin
							x_start_mario_d = x_start_mario_q-8'd1; 
							v_y_d = 7'd0;
							setTwice_d = 1'b0;
							d_y_d = 7'd0;
							state_draw_d = MOVE_ENEMY; 
						end
						else if (x_start_mario_q > 8'd22 && x_start_mario_q < 8'd48 && y_start_mario_q >= 7'd1 &&  y_start_mario_q <= 7'd90)
						begin
							x_start_mario_d = x_start_mario_q-8'd2; 
							v_y_d = v_y_q + 7'd1;
							setTwice_d = 1'b0;
							d_y_d = 7'd0;
							y_start_mario_d = y_start_mario_q + v_y_q;
							state_draw_d = MOVE_ENEMY; 
						end
						//Note: x > 1 instead of x >= 1, to prevent mario go to x = 0.
						else if (x_start_mario_q > 8'd1 && x_start_mario_q <= 8'd22 && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd71)
						begin
							x_start_mario_d = x_start_mario_q-8'd1; 
							v_y_d = 7'd0;
							setTwice_d = 1'b0;
							d_y_d = 7'd0;
							state_draw_d = MOVE_ENEMY;
						end
						else 
						begin
							v_y_d = 7'd0;
							setTwice_d = 1'b0;			
							y_start_mario_d = 7'd97;
							d_y_d = 7'd0;
							state_draw_d = MOVE_ENEMY; 	
						end
					end
				else if (right && x_start_mario_q >= 8'd1 && x_start_mario_q < 8'd48 && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd97)
					begin 
						//make mario fall down in projectile
						if (x_start_mario_q >= 8'd22 && x_start_mario_q < 8'd48 && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd90)
						begin
							v_y_d = v_y_q + 7'd1;
							x_start_mario_d = x_start_mario_q+8'd1;
							y_start_mario_d = y_start_mario_q + v_y_q;	 
							state_draw_d = MOVE_ENEMY; 
						end
						//move to right
						else if (x_start_mario_q > 8'd22 && x_start_mario_q < 8'd48 && y_start_mario_q >= 7'd90 && y_start_mario_q <= 7'd96)
						begin
							v_y_d = 7'd0;
							setTwice_d = 1'b0;
							d_y_d = 7'd0;
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end 
						else
						begin
							v_y_d = 7'd0;
							setTwice_d = 1'b0;
							d_y_d = 7'd0;
							x_start_mario_d = x_start_mario_q+8'd1; 
							state_draw_d = MOVE_ENEMY; 
						end
					end
				else if (up/*(condition_up_q) || condition_up_y71_q)*/ && x_start_mario_q >= 8'd1 && x_start_mario_q < 8'd48 && y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd97) 
					begin	
						//do not fall into the pipe
						if ((v_y_q >= 7'd9) && (y_start_mario_q >= 7'd61 && y_start_mario_q <= 7'd71 && x_start_mario_q >= 8'd1 && x_start_mario_q < 8'd21))
						begin
							y_start_mario_d = 7'd71;
							state_draw_d = MOVE_ENEMY; 
						end 
						//do not fall into the ground
						else if ((v_y_q >= 7'd9) && (y_start_mario_q >= 7'd87 && y_start_mario_q <= 7'd97 && x_start_mario_q >= 8'd1 && x_start_mario_q < 8'd48))
						begin
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end 
						//safe to fall down or jump
						else
						begin
							v_y_d = v_y_q+7'd1;
							y_start_mario_d = y_start_mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end
					
					end
				else
						state_draw_d = MOVE_ENEMY;
			end
			
		
		
					
		/******************************************Boundary 3********************************************************/
			else if(x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111 && y_start_mario_q >= 7'd82 && y_start_mario_q <= 7'd97)
			begin
				if (condition_rightup_q && (x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111 && y_start_mario_q >= 7'd82 && y_start_mario_q <= 7'd97))
					begin 
						//do not fall into the ground								do not change 97 to 96, b/c this 97 prevents it from sinking into ground. 
						if ((v_y_q >= 7'd5) && ((x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111 && y_start_mario_q >= 7'd92 && y_start_mario_q <= 7'd97)))
						begin
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end 
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							x_start_mario_d = x_start_mario_q+8'd2; 
							y_start_mario_d = y_start_mario_q-7'd5 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end
					end
				else if (condition_leftup_q && (x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111 && y_start_mario_q >= 7'd82 && y_start_mario_q <= 7'd97))
					begin 
						//do not fall into the ground								do not change 97 to 96, b/c this 97 prevents it from sinking into ground. 
						if ((v_y_q >= 7'd5) && ((x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111 && y_start_mario_q >= 7'd92 && y_start_mario_q <= 7'd97)))
						begin
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end 
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							x_start_mario_d = x_start_mario_q-8'd2; 
							y_start_mario_d = y_start_mario_q-7'd5 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end
					end
					
				else if (left && (x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111 && y_start_mario_q >= 7'd82 && y_start_mario_q <= 7'd97))
					begin 
						v_y_d = 7'd0;
						setTwice_d = 1'b0;
						d_y_d = 7'd0;
						x_start_mario_d = x_start_mario_q-8'd1; 
						state_draw_d = MOVE_ENEMY; 
					end
		
				else if (right && (x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111 && y_start_mario_q >= 7'd82 && y_start_mario_q <= 7'd97))
					begin 
							v_y_d = 7'd0;
							setTwice_d = 1'b0;
							d_y_d = 7'd0;
							x_start_mario_d = x_start_mario_q+8'd1; 
							state_draw_d = MOVE_ENEMY;  
					end
				else if (condition_up_q && (x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111 && y_start_mario_q >= 7'd82 && y_start_mario_q <= 7'd97))
					begin 
						//do not fall into the ground 
						if ((v_y_q >= 7'd5) && (x_start_mario_q >= 8'd48 && x_start_mario_q <= 8'd111 && y_start_mario_q >= 7'd92 && y_start_mario_q <= 7'd97))
						begin
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end 
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							y_start_mario_d = y_start_mario_q-7'd5 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end
					
					end
				
				else
					begin
						y_start_mario_d = 7'd97;
						state_draw_d = MOVE_ENEMY;
					end
			end

		/******************************************End of Boundary 3********************************************************/	
		
		/******************************************Boundary 4********************************************************/
			else if(x_start_mario_q > 8'd111 && x_start_mario_q <= 8'd155 && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd97)
			begin
				if (condition_rightup_q && (x_start_mario_q > 8'd111 && x_start_mario_q <= 8'd154 && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd97))
					begin 
						//do not fall into the ground								do not change 97 to 96, b/c this 97 prevents it from sinking into ground. 
						if ((v_y_q >= 7'd9) && ((x_start_mario_q > 8'd150 && x_start_mario_q <= 8'd159) && (y_start_mario_q >= 7'd1 && y_start_mario_q <= 7'd97)))
						begin
							x_start_mario_d = 8'd152;
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end 
						
						else if ((v_y_q >= 7'd9) && ((x_start_mario_q > 8'd111 && x_start_mario_q <= 8'd150) && (y_start_mario_q >= 7'd91 && y_start_mario_q <= 7'd97)))
						begin
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							x_start_mario_d = x_start_mario_q+8'd2; 
							y_start_mario_d = y_start_mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end
					end
				else if (condition_leftup_q && (x_start_mario_q > 8'd111 && x_start_mario_q <= 8'd155 && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd97))
					begin 
						//do not fall into the ground,and off the right screen         
						if ((v_y_q >= 7'd9) && (x_start_mario_q > 8'd111 && x_start_mario_q <= 8'd154 && y_start_mario_q >= 7'd87 && y_start_mario_q <= 7'd97))
						begin
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end 
						//do not touch the bricks
						else if ((x_start_mario_q >= 8'd110 && x_start_mario_q <= 8'd114) && (y_start_mario_q >= 7'd63 && y_start_mario_q <= 7'd90))
						begin
							if ((!setTwice_q) && (y_start_mario_q >= 7'd71))
							begin
								x_start_mario_d = 8'd114; 
								y_start_mario_d = 7'd71;
								setTwice_d = 1'b1;
								state_draw_d = MOVE_ENEMY;
							end
							else 
							begin
								d_y_d = d_y_q+7'd1;
								x_start_mario_d = 8'd114; 
								y_start_mario_d = y_start_mario_q + d_y_q;		
								state_draw_d = MOVE_ENEMY;
							end
						end
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							x_start_mario_d = x_start_mario_q-8'd2; 
							y_start_mario_d = y_start_mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end				
						
					end
				else if (left && x_start_mario_q > 8'd111 && x_start_mario_q <= 8'd155 && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd97)	    
					begin 
						x_start_mario_d = x_start_mario_q-8'd1; 
						v_y_d = 7'd0;
						setTwice_d = 1'b0;
						d_y_d = 7'd0;
						state_draw_d = MOVE_ENEMY; 
					end
				else if (right && x_start_mario_q > 8'd111 && x_start_mario_q <= 8'd154 && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd97)
					begin 
						//make mario fall down in projectile
						if (x_start_mario_q > 8'd111 && x_start_mario_q <= 8'd154 && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd90)
						begin
							v_y_d = v_y_d + 7'd1;
							x_start_mario_d = x_start_mario_q + 8'd1;
							y_start_mario_d = y_start_mario_q + v_y_q;
							state_draw_d = MOVE_ENEMY;
						end
						else
						begin
							x_start_mario_d = x_start_mario_q+8'd1; 
							y_start_mario_d = 7'd97;
							v_y_d = 7'd0;
							setTwice_d = 1'b0;
							d_y_d = 7'd0;
							state_draw_d = MOVE_ENEMY; 
						end
					end
				else if (condition_up_q && x_start_mario_q > 8'd111 && x_start_mario_q <= 8'd155 && y_start_mario_q >= 7'd0 && y_start_mario_q <= 7'd97)
					begin 
						//do not fall into the ground 
						if ((v_y_q >= 7'd9) && (y_start_mario_q >= 7'd87 && y_start_mario_q <= 7'd97 && x_start_mario_q > 8'd111 && x_start_mario_q <= 8'd155))
						begin
							y_start_mario_d = 7'd97;
							state_draw_d = MOVE_ENEMY; 
						end 
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							y_start_mario_d = y_start_mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_ENEMY; 	
						end
					
					end
				
				else
					begin
						v_y_d = 7'd0;
						setTwice_d = 1'b0;
						d_y_d = 7'd0;
						state_draw_d = MOVE_ENEMY;
					end
			end

		/******************************************End of Boundary 4********************************************************/	
			else
						state_draw_d = MOVE_ENEMY;
	end
		else
			state_draw_d = MOVE_ENEMY;
	end
	
	//move the enemy
	MOVE_ENEMY:
	begin
				if (x_start_enemy_q >= 8'd149)  
					leftRight_d = 1'b0;
				if (x_start_enemy_q <= 8'd109) 
					leftRight_d = 1'b1;
				if (leftRight_d == 1'b0)//move to the left
					x_start_enemy_d = x_start_enemy_q - 8'd01; 
				if (leftRight_d == 1'b1)//move to the right
					x_start_enemy_d = x_start_enemy_q + 8'd01;
				state_draw_d = MOVE_FATMARIO;
	end
	
	//move fat mario
	MOVE_FATMARIO:
	begin
		if(collision_mush_q == 1'b1 && y_start_fatmario_q != 7'd101)
		begin
				y_start_fatmario_d = y_start_fatmario_q + 7'd01;
				state_draw_d = MOVE_MUSH;
		end
		else
			state_draw_d = MOVE_MUSH;
	end
	
	//move the mushroom
	MOVE_MUSH:
	begin
		if (coll_qbrick_q && collision_mush_q == 1'b0)
		begin
			if ((mush_go_left_q) && (!mush_go_down_q) && (!mush_go_right_q))
			begin
				x_start_mush_d = x_start_mush_q-8'd1; 
				state_draw_d = MOVE_DEAD_MARIO;
			end
			
			else if ((mush_go_left_q) && (mush_go_down_q) && (!mush_go_right_q))
			begin
				x_start_mush_d = x_start_mush_q-8'd1;
				y_start_mush_d = y_start_mush_q+7'd2; 
				state_draw_d = MOVE_DEAD_MARIO;
			end
			
			else if ((mush_go_left_q) && (!mush_go_down_q) && (mush_go_right_q))
			begin
				x_start_mush_d = x_start_mush_q+8'd1; 
				state_draw_d = MOVE_DEAD_MARIO;
			end
			
			else state_draw_d = MOVE_DEAD_MARIO;
			
		end
		
		else
			state_draw_d = MOVE_DEAD_MARIO;
	end
	
	//Moves dead mario
	MOVE_DEAD_MARIO:
	begin
		if(collision_enemy_q == 1'b1 && y_start_dead_stage1mario_q != 7'd82)
		begin
				y_start_dead_stage1mario_d = y_start_dead_stage1mario_q - 7'd01;
				state_draw_d = DRAW_MARIO;
		end
		else if (collision_coin_q == 1'b1 && y_start_dead_stage1mario_q != 7'd30)
		begin
				y_start_dead_stage1mario_d = y_start_dead_stage1mario_q - 7'd01;
				state_draw_d = DRAW_MARIO;
		end
		else
			state_draw_d = DRAW_MARIO;
	end
	
	//draw mario on its new position, go back to wait again once it is done.
	DRAW_MARIO:
	begin
		if(collision_mush_q == 1'b0 && collision_enemy_q == 1'b0 && collision_coin_q == 1'b0)
		begin
			//draw image
			if (counter_y_mario_q <= 4'd09)
			begin
				color_d = color_mario;
				x_d = x_start_mario_d + counter_x_mario_q;
				y_d = y_start_mario_d + counter_y_mario_q;
				
				counter_x_mario_d = counter_x_mario_q + 4'd01;
				if (counter_x_mario_q == 4'd04)
				begin
				counter_y_mario_d = counter_y_mario_q + 4'd01; 
				counter_x_mario_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_mario_q == 4'd04) && (counter_y_mario_q == 4'd09))
			begin
				x_start_dead_stage1mario_d = x_start_mario_q;
				y_start_dead_stage1mario_d = y_start_mario_q - 4'd4;
				counter_x_mario_d = 4'd00;
				counter_y_mario_d = 4'd00;
				state_draw_d = DRAW_ENEMY;
				x_start_fatmario_d = x_start_mario_q;
				y_start_fatmario_d = y_start_mario_q - 7'd10;
			end
			else
				state_draw_d = DRAW_MARIO;
		end
		
		else 
			state_draw_d = DRAW_ENEMY;
	end

	DRAW_ENEMY:
	begin
		//draw image
		if (counter_y_enemy_q <= 4'd09)
		begin
			color_d = color_enemy;
			x_d = x_start_enemy_d + counter_x_enemy_q;
			y_d = y_start_enemy_d + counter_y_enemy_q;
			
			counter_x_enemy_d = counter_x_enemy_q + 4'd01;
			if (counter_x_enemy_q == 4'd09)
			begin
				counter_y_enemy_d = counter_y_enemy_q + 4'd01; 
				counter_x_enemy_d = 4'd00;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_enemy_q == 4'd09) && (counter_y_enemy_q == 4'd09))
		begin	
			counter_x_enemy_d = 4'd00;
			counter_y_enemy_d = 4'd00;
			state_draw_d = DRAW_MUSH;
		end
		else
			state_draw_d = DRAW_ENEMY;
	end
	
	DRAW_MUSH:
	begin
		if (coll_qbrick_q && collision_mush_q == 1'b0)
		begin
			
			//draw mush
			if (counter_y_mush_q <= 4'd09)
			begin
				color_d = color_mush;
				x_d = x_start_mush_d + counter_x_mush_q;
				y_d = y_start_mush_d + counter_y_mush_q;
				
				counter_x_mush_d = counter_x_mush_q + 4'd01;
				if (counter_x_mush_q == 4'd09)
				begin
					counter_y_mush_d = counter_y_mush_q + 4'd01; 
					counter_x_mush_d = 4'd00;
				end
			end
			
			//condition for choosing next state
			if ((counter_x_mush_q == 4'd09) && (counter_y_mush_q == 4'd09))
			begin	
				counter_x_mush_d = 4'd00;
				counter_y_mush_d = 4'd00;
				state_draw_d = DRAW_FATMARIO;
			end
			else
				state_draw_d = DRAW_MUSH;
				
			//end of draw mush
			
			if ((x_start_mush_q == 8'd43) && (y_start_mush_q == 7'd63))
			begin
				mush_go_down_d = 1'b1;
				mush_go_left_d = 1'b0;
				mush_go_right_d = 1'b0;
			end
			
			else if ((x_start_mush_q >= 8'd0) && (x_start_mush_q <= 8'd40) && (y_start_mush_q == 7'd97) && (!ani_mush_twice_d))
			begin
				ani_mush_twice_d = 1'b1;
				mush_go_down_d = 1'b0;
				mush_go_left_d = 1'b1;
				mush_go_right_d = 1'b0;
			end
			
			else if (x_start_mush_q == 8'd19) 
			begin
				mush_go_down_d = 1'b0;
				mush_go_left_d = 1'b0;
				mush_go_right_d = 1'b1;
			end
			
			else if (x_start_mush_q == 8'd90) 
			begin
				mush_go_down_d = 1'b0;
				mush_go_left_d = 1'b1;
				mush_go_right_d = 1'b0;
			end
			
		end
		
		else
			state_draw_d = DRAW_FATMARIO;
	
	end
	
	//Draws Fat Mario after the mushroom is eaten
	DRAW_FATMARIO:
	begin
		if(collision_mush_q == 1'b1 && y_start_fatmario_q != 7'd101)
		begin
			//draw image
			if (counter_y_fatmario_q <= 5'd19)
			begin
				color_d = color_fat_mario;
				x_d = x_start_fatmario_d + counter_x_fatmario_q;
				y_d = y_start_fatmario_d + counter_y_fatmario_q;
				
				counter_x_fatmario_d = counter_x_fatmario_q + 4'd01;
				if (counter_x_fatmario_q == 4'd09)
				begin
				counter_y_fatmario_d = counter_y_fatmario_q + 5'd01; 
				counter_x_fatmario_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_fatmario_q == 4'd09) && (counter_y_fatmario_q == 5'd19))
			begin
				counter_x_fatmario_d = 4'd00;
				counter_y_fatmario_d = 5'd00;
				state_draw_d = DRAW_DEAD_MARIO;
			end
			else
				state_draw_d = DRAW_FATMARIO;
		end
		
		else
				state_draw_d = DRAW_DEAD_MARIO;
	end
	
	//Draws dead mario
	DRAW_DEAD_MARIO:
	begin
		if(collision_coin_q == 1'b1)
		begin
			//draw dead stage 2 mario
			if (counter_y_dead_stage1mario_q <= 4'd13)
			begin
				color_d = color_dead_stage1_mario;
				x_d = x_start_dead_stage1mario_d + counter_x_dead_stage1mario_q;
				y_d = y_start_dead_stage1mario_d + counter_y_dead_stage1mario_q;
				
				counter_x_dead_stage1mario_d = counter_x_dead_stage1mario_q + 4'd01;
				if (counter_x_dead_stage1mario_q == 4'd04)
				begin
				counter_y_dead_stage1mario_d = counter_y_dead_stage1mario_q+4'd01; 
				counter_x_dead_stage1mario_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_dead_stage1mario_q == 4'd04) && (counter_y_dead_stage1mario_q == 4'd13))
			begin	
				counter_x_dead_stage1mario_d = 4'd00;
				counter_y_dead_stage1mario_d = 4'd00;
				state_draw_d = COLLIDE_ENEMY;
			end
			else
				state_draw_d = DRAW_DEAD_MARIO;
		end
		else if(collision_enemy_q == 1'b1)
		begin
			//draw dead stage 2 mario
			if (counter_y_dead_stage1mario_q <= 4'd13)
			begin
				color_d = color_dead_stage1_mario;
				x_d = x_start_dead_stage1mario_d + counter_x_dead_stage1mario_q;
				y_d = y_start_dead_stage1mario_d + counter_y_dead_stage1mario_q;
				
				counter_x_dead_stage1mario_d = counter_x_dead_stage1mario_q + 4'd01;
				if (counter_x_dead_stage1mario_q == 4'd04)
				begin
				counter_y_dead_stage1mario_d = counter_y_dead_stage1mario_q+4'd01; 
				counter_x_dead_stage1mario_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_dead_stage1mario_q == 4'd04) && (counter_y_dead_stage1mario_q == 4'd13))
			begin	
				counter_x_dead_stage1mario_d = 4'd00;
				counter_y_dead_stage1mario_d = 4'd00;
				state_draw_d = COLLIDE_ENEMY;
			end
			else
				state_draw_d = DRAW_DEAD_MARIO;
		end
		else
			state_draw_d = COLLIDE_ENEMY;
	end
	
	
	COLLIDE_ENEMY:
	begin
		if (((x_start_mario_q - x_start_enemy_q <= 8'd10) || (x_start_enemy_q - x_start_mario_q <= 8'd5)) && (y_start_enemy_q - y_start_mario_d <= 7'd10))
		begin
			collision_enemy_d = 1'b1;
			state_draw_d = COLLIDE_MONEY;
		end
		else
			state_draw_d = COLLIDE_MONEY;
	end
	
	COLLIDE_MONEY:
	begin
		if (((x_start_mario_q >= 8'd79) && (x_start_mario_q <= 8'd91)) && (y_start_mario_d >= 7'd53 && y_start_mario_d <= 7'd63))
		begin
			if (counter_y_coin_q <= 4'd07)
			begin
				color_d = 3'b011;
				x_start_coin_d = 8'd84;
				y_start_coin_d = 7'd64;
				x_d = x_start_coin_d + counter_x_coin_q;
				y_d = y_start_coin_d + counter_y_coin_q;
				
				counter_x_coin_d = counter_x_coin_q + 4'd01;
				if (counter_x_coin_q == 4'd06)
				begin
				counter_y_coin_d = counter_y_coin_q + 4'd01; 
				counter_x_coin_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_coin_q == 4'd06) && (counter_y_coin_q == 4'd07))
				begin
				counter_x_coin_d = 4'd0;
				counter_y_coin_d = 4'd0;
				collision_coin_d = 1'b1;
				state_draw_d = WAIT;
				end
			else
				state_draw_d = COLLIDE_MONEY;
		end
		
		else if (((x_start_mario_q >= 8'd91) && (x_start_mario_q <= 8'd101)) && (y_start_mario_d >= 7'd53 && y_start_mario_d <= 7'd63))
		begin
			if (counter_y_coin_q <= 4'd07)
			begin
				color_d = 3'b011;
				x_start_coin_d = 8'd94;
				y_start_coin_d = 7'd64;
				x_d = x_start_coin_d + counter_x_coin_q;
				y_d = y_start_coin_d + counter_y_coin_q;
				
				counter_x_coin_d = counter_x_coin_q + 4'd01;
				if (counter_x_coin_q == 4'd06)
				begin
				counter_y_coin_d = counter_y_coin_q + 4'd01; 
				counter_x_coin_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_coin_q == 4'd06) && (counter_y_coin_q == 4'd07))
				begin
				counter_x_coin_d = 4'd0;
				counter_y_coin_d = 4'd0;
				collision_coin_d = 1'b1;
				state_draw_d = WAIT;
				end
			else
				state_draw_d = COLLIDE_MONEY;
		end
		
		else if (((x_start_mario_q >= 8'd101) && (x_start_mario_q <= 8'd110)) && (y_start_mario_d >= 7'd53 && y_start_mario_d <= 7'd63))
		begin
			if (counter_y_coin_q <= 4'd07)
			begin
				color_d = 3'b011;
				x_start_coin_d = 8'd104;
				y_start_coin_d = 7'd64;
				x_d = x_start_coin_d + counter_x_coin_q;
				y_d = y_start_coin_d + counter_y_coin_q;
				
				counter_x_coin_d = counter_x_coin_q + 4'd01;
				if (counter_x_coin_q == 4'd06)
				begin
				counter_y_coin_d = counter_y_coin_q + 4'd01; 
				counter_x_coin_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_coin_q == 4'd06) && (counter_y_coin_q == 4'd07))
				begin
				counter_x_coin_d = 4'd0;
				counter_y_coin_d = 4'd0;
				collision_coin_d = 1'b1;
				state_draw_d = WAIT;
				end
			else
				state_draw_d = COLLIDE_MONEY;
		end
		
		else
			state_draw_d = WAIT;
	end
		
	SETUP_STAGE2_BACKGROUND:
	begin
		level_d = 4'd2;
		collision_princess_d = 1'b0;
		y_start_dead_stage2mario_d = 7'd0;
		x_start_dead_stage2mario_d = 8'd0;
		counterClock_stage2_d = 27'd0;
		
		//draw image
		if (counter_y_stage2bckgnd_q <= 7'd119)
		begin
			color_d = color_stage2_background;
			x_start_stage2bckgnd_d = 8'd0;
			y_start_stage2bckgnd_d = 7'd0;
			x_d = x_start_stage2bckgnd_d + counter_x_stage2bckgnd_q;
			y_d = y_start_stage2bckgnd_d + counter_y_stage2bckgnd_q;
			
			counter_x_stage2bckgnd_d = counter_x_stage2bckgnd_q + 8'd01;
			if (counter_x_stage2bckgnd_q == 8'd159)
			begin
				counter_y_stage2bckgnd_d = counter_y_stage2bckgnd_q + 7'd01; 
				counter_x_stage2bckgnd_d = 8'd00;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_stage2bckgnd_q == 8'd159) && (counter_y_stage2bckgnd_q == 7'd119))
		begin
			counter_x_stage2bckgnd_d = 8'd00;
			counter_y_stage2bckgnd_d = 7'd00;
			state_draw_d = SETUP_PRINCESS;
		end
		else
			state_draw_d = SETUP_STAGE2_BACKGROUND;
	end
	
	//Draws princess on the screen of stage2	
	SETUP_PRINCESS:
	begin
		//draw image
		if (counter_y_princess_q <= 5'd19)
		begin
			color_d = color_princess;
			x_start_princess_d = 8'd70;
			y_start_princess_d = 7'd87;
			x_d = x_start_princess_d + counter_x_princess_q;
			y_d = y_start_princess_d + counter_y_princess_q;
				
			counter_x_princess_d = counter_x_princess_q + 4'd01;
			if (counter_x_princess_q == 4'd09)
			begin
				counter_y_princess_d = counter_y_princess_q + 5'd01; 
				counter_x_princess_d = 4'd00;
			end
		end	
			
		//condition for choosing next state
		if ((counter_x_princess_q == 4'd09) && (counter_y_princess_q == 5'd19))
		begin
			counter_x_princess_d = 4'd00;
			counter_y_princess_d = 5'd00;
			state_draw_d = SETUP_STAGE2_MARIO;
		end
		else
			state_draw_d = SETUP_PRINCESS;
	end
	
	//Draws stage2 mario
	SETUP_STAGE2_MARIO:
	begin
		//draw stage 2 mario
		if (counter_y_stage2mario_q <= 4'd09)
		begin
			color_d = color_stage2_mario;
			x_start_stage2mario_d = 8'd0;
			y_start_stage2mario_d = 7'd97;
			x_d = x_start_stage2mario_d + counter_x_stage2mario_q;
			y_d = y_start_stage2mario_d + counter_y_stage2mario_q;
			
			counter_x_stage2mario_d = counter_x_stage2mario_q + 4'd01;
			if (counter_x_stage2mario_q == 4'd04)
			begin
			counter_y_stage2mario_d = counter_y_stage2mario_q+4'd01; 
			counter_x_stage2mario_d = 4'd00;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_stage2mario_q == 4'd04) && (counter_y_stage2mario_q == 4'd09))
		begin
			counter_x_stage2mario_d = 4'd00;
			counter_y_stage2mario_d = 4'd00;
			state_draw_d = WAIT_STAGE2;
		end
		else
			state_draw_d = SETUP_STAGE2_MARIO;
	end
	
	//Wait state for stage 2
	WAIT_STAGE2:
	begin
		//a game feature in which the animation of jump is not stopped even when the player releases the jump button after being pressed once.
//		//for all boundaries except boundary 1 
		if ((!cond2_leftup_q) && (y_start_stage2mario_q >= 7'd1 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd155)) 
		begin
			if ((left && up) || ((cond2_up_q) && (left)))
			begin
				cond2_leftup_d = 1'b1;
				cond2_up_d = 1'b0;
			end
			else
				cond2_leftup_d = 1'b0;
		end
		
		if ((!cond2_rightup_q) && (y_start_stage2mario_q >= 7'd1 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd155)) 
		begin
			if (((right) &&(up)) || ((cond2_up_q) && (right)))
			begin
				cond2_rightup_d = 1'b1;
				cond2_up_d = 1'b0;
			end
			else
				cond2_rightup_d = 1'b0;
		end
		
		if ((!cond2_up_q) && (y_start_stage2mario_q >= 7'd1 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd155)) 
		begin
			if (up)
				cond2_up_d = 1'b1;
			else
				cond2_up_d = 1'b0;
		end
		
		counterClock_stage2_d = counterClock_stage2_q + 27'd01;
		if(collision_princess_q == 1'b1 && y_start_dead_stage2mario_q == 7'd60)
		begin
			if (counterClock_stage2_q == 27'd50000000)
			begin	
						gameover_d = gameover_q + 4'd01;
						counterClock_stage2_d = 27'd0;
						state_draw_d = SETUP_STAGE1_BACKGROUND;
			end
			else
					state_draw_d = WAIT_STAGE2;
		end
		else if ((x_start_stage2mario_q >= 8'd65) && (x_start_stage2mario_q <= 8'd75) && (y_start_stage2mario_q >= 7'd80) && (y_start_stage2mario_q <= 7'd97))
		begin
				collision_princess_d = 1'b1;
				if (counterClock_stage2_q == 27'd5000000)
					begin				
						counterClock_stage2_d = 27'd0;
						state_draw_d = MOVE_STAGE2_MARIO;
					end
				else
					state_draw_d = WAIT_STAGE2;
		end
		else if (x_start_stage2mario_q == 8'd120 && y_start_stage2mario_q == 7'd97)
		begin
					state_draw_d = GAME_END;
		end
		else if (counterClock_stage2_q == 27'd5000000)
		begin				
					counterClock_stage2_d = 27'd0;
					state_draw_d = MOVE_STAGE2_MARIO;
		end
		else
				state_draw_d = WAIT_STAGE2;
	end
	
	//Moves stage 2 mario
	MOVE_STAGE2_MARIO:
	begin
//	//condition for jumping motion, determined by the keys.
//	//all boundaries except boundary 1
	

	/******************************************Boundary********************************************************/
				if ((cond2_up_q) && (y_start_stage2mario_q == 7'd97))
						cond2_up_d = 1'b0;
				if ((cond2_leftup_q) && (y_start_stage2mario_q == 7'd97))
						cond2_leftup_d = 1'b0;
				if ((cond2_rightup_q) && (y_start_stage2mario_q == 7'd97))
						cond2_rightup_d = 1'b0;
				
				
				if (cond2_rightup_q && (y_start_stage2mario_q >= 7'd1 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd155))
					begin 
						if ((v_y_q >= 7'd9) && (y_start_stage2mario_q >= 7'd87 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd155))
						begin
							y_start_stage2mario_d = 7'd97;
							state_draw_d = MOVE_DEAD_STAGE2_MARIO; 
						end
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							x_start_stage2mario_d = x_start_stage2mario_q+8'd2; 
							y_start_stage2mario_d = y_start_stage2mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_DEAD_STAGE2_MARIO; 	
						end
					end
				else if (cond2_leftup_q && (y_start_stage2mario_q >= 7'd1 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd155))
					begin 
						//do not fall into the ground,and off the right screen         
						if ((v_y_q >= 7'd9) && (y_start_stage2mario_q >= 7'd87 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd1 && x_start_stage2mario_q <= 8'd155))
						begin
							y_start_stage2mario_d = 7'd97;
							state_draw_d = MOVE_DEAD_STAGE2_MARIO; 
						end 
						else if (y_start_stage2mario_q >= 7'd1 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd6)
						begin
							x_start_stage2mario_d = 8'd6;
							y_start_stage2mario_d = 7'd97;
							state_draw_d = MOVE_DEAD_STAGE2_MARIO; 
						end 
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							x_start_stage2mario_d = x_start_stage2mario_q-8'd2; 
							y_start_stage2mario_d = y_start_stage2mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_DEAD_STAGE2_MARIO; 	
						end				
						
					end
				else if (left && (y_start_stage2mario_q >= 7'd1 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd155))	    
					begin 
						x_start_stage2mario_d = x_start_stage2mario_q-8'd1; 
						v_y_d = 7'd0;
						state_draw_d = MOVE_DEAD_STAGE2_MARIO; 
					end
				else if (right && (y_start_stage2mario_q >= 7'd1 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd155))
					begin 
							x_start_stage2mario_d = x_start_stage2mario_q+8'd1; 
							y_start_stage2mario_d = 7'd97;
							v_y_d = 7'd0;
							state_draw_d = MOVE_DEAD_STAGE2_MARIO; 
					end
				else if (cond2_up_q && (y_start_stage2mario_q >= 7'd1 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd155))
					begin 
						//do not fall into the ground 
						if ((v_y_q >= 7'd9) && (y_start_stage2mario_q >= 7'd87 && y_start_stage2mario_q <= 7'd97 && x_start_stage2mario_q >= 8'd0 && x_start_stage2mario_q <= 8'd155))
						begin
							y_start_stage2mario_d = 7'd97;
							state_draw_d = MOVE_DEAD_STAGE2_MARIO; 
						end 
						else
						//safe to fall down
						begin
							v_y_d = v_y_q+7'd1;
							y_start_stage2mario_d = y_start_stage2mario_q-7'd9 + v_y_q;		
							state_draw_d = MOVE_DEAD_STAGE2_MARIO; 	
						end
					
					end
				
				else
					begin
						v_y_d = 7'd0;
						state_draw_d = MOVE_DEAD_STAGE2_MARIO;
					end
		/******************************************End of Boundary********************************************************/	
	end
	
	//Moves dead stage2 mario when mario is dead
	MOVE_DEAD_STAGE2_MARIO:
	begin
		if(collision_princess_q == 1'b1 && y_start_dead_stage2mario_q != 7'd60)
		begin
				y_start_dead_stage2mario_d = y_start_dead_stage2mario_q - 7'd01;
				state_draw_d = DRAW_STAGE2_BACKGROUND;
		end
		else
			state_draw_d = DRAW_STAGE2_BACKGROUND;
	end
	
	//Draws stage2 background
	DRAW_STAGE2_BACKGROUND:
	begin
		//draw image
		if (counter_y_stage2bckgnd_q <= 7'd119)
		begin
			color_d = color_stage2_background;
			x_d = x_start_stage2bckgnd_d + counter_x_stage2bckgnd_q;
			y_d = y_start_stage2bckgnd_d + counter_y_stage2bckgnd_q;
			
			counter_x_stage2bckgnd_d = counter_x_stage2bckgnd_q + 8'd01;
			if (counter_x_stage2bckgnd_q == 8'd159)
			begin
				counter_y_stage2bckgnd_d = counter_y_stage2bckgnd_q + 7'd01; 
				counter_x_stage2bckgnd_d = 8'd00;
			end
		end	
		
		//condition for choosing next state
		if ((counter_x_stage2bckgnd_q == 8'd159) && (counter_y_stage2bckgnd_q == 7'd119))
		begin	
			counter_x_stage2bckgnd_d = 8'd00;
			counter_y_stage2bckgnd_d = 7'd00;
			state_draw_d = DRAW_PRINCESS;
		end
		else
			state_draw_d = DRAW_STAGE2_BACKGROUND;
	end
	
	//Draws princess untill collision
	DRAW_PRINCESS:
	begin
		if (collision_princess_q == 1'b0)
		begin
			//draw image
			if (counter_y_princess_q <= 5'd19)
			begin
				color_d = color_princess;
				x_d = x_start_princess_d + counter_x_princess_q;
				y_d = y_start_princess_d + counter_y_princess_q;
					
				counter_x_princess_d = counter_x_princess_q + 4'd01;
				if (counter_x_princess_q == 4'd09)
				begin
					counter_y_princess_d = counter_y_princess_q + 5'd01; 
					counter_x_princess_d = 4'd00;
				end
			end	
				
			//condition for choosing next state
			if ((counter_x_princess_q == 4'd09) && (counter_y_princess_q == 5'd19))
			begin
				counter_x_princess_d = 4'd00;
				counter_y_princess_d = 5'd00;
				state_draw_d = DRAW_STAGE2_MARIO;
			end
			else
				state_draw_d = DRAW_PRINCESS;
		end
		
		else
			state_draw_d = DRAW_STAGE2_MARIO;
	end
	
	//Draws stage2 mario
	DRAW_STAGE2_MARIO:
	begin
		if (collision_princess_q == 1'b0)
		begin
			//draw stage 2 mario
			if (counter_y_stage2mario_q <= 4'd09)
			begin
				color_d = color_stage2_mario;
				x_d = x_start_stage2mario_d + counter_x_stage2mario_q;
				y_d = y_start_stage2mario_d + counter_y_stage2mario_q;
				
				counter_x_stage2mario_d = counter_x_stage2mario_q + 4'd01;
				if (counter_x_stage2mario_q == 4'd04)
				begin
				counter_y_stage2mario_d = counter_y_stage2mario_q+4'd01; 
				counter_x_stage2mario_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_stage2mario_q == 4'd04) && (counter_y_stage2mario_q == 4'd09))
			begin	
				counter_x_stage2mario_d = 4'd00;
				counter_y_stage2mario_d = 4'd00;
				x_start_dead_stage2mario_d = x_start_stage2mario_q;
				y_start_dead_stage2mario_d = y_start_stage2mario_q - 7'd3;
				state_draw_d = DRAW_TURTLE;
			end
			else
				state_draw_d = DRAW_STAGE2_MARIO;
		end
		
		else
			state_draw_d = DRAW_TURTLE;
	end
	
	//Draws turtle. Condition: Mario collides with princess
	DRAW_TURTLE:
	begin
		if (collision_princess_q == 1'b1)
		begin
			//draw turtle
			if (counter_y_turtle_q <= 5'd16)
			begin
				color_d = color_turtle;
				x_start_turtle_d = x_start_princess_d;
				y_start_turtle_d = y_start_princess_d + 7'd3;
				x_d = x_start_turtle_d + counter_x_turtle_q;
				y_d = y_start_turtle_d + counter_y_turtle_q;
				
				counter_x_turtle_d = counter_x_turtle_q + 5'd01;
				if (counter_x_turtle_q == 5'd14)
				begin
				counter_y_turtle_d = counter_y_turtle_q+5'd01; 
				counter_x_turtle_d = 5'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_turtle_q == 5'd14) && (counter_y_turtle_q == 5'd16))
			begin
				counter_x_turtle_d = 5'd00;
				counter_y_turtle_d = 5'd00;
				state_draw_d = DRAW_DEAD_STAGE2_MARIO;
			end
			else
				state_draw_d = DRAW_TURTLE;
		end
		else
			state_draw_d = DRAW_DEAD_STAGE2_MARIO;
	end
	
	DRAW_DEAD_STAGE2_MARIO:
	begin
		if(collision_princess_q == 1'b1)
		begin
			//draw dead stage 2 mario
			if (counter_y_dead_stage2mario_q <= 4'd13)
			begin
				color_d = color_dead_stage2_mario;
				x_d = x_start_dead_stage2mario_d + counter_x_dead_stage2mario_q;
				y_d = y_start_dead_stage2mario_d + counter_y_dead_stage2mario_q;
				
				counter_x_dead_stage2mario_d = counter_x_dead_stage2mario_q + 4'd01;
				if (counter_x_dead_stage2mario_q == 4'd04)
				begin
				counter_y_dead_stage2mario_d = counter_y_dead_stage2mario_q+4'd01; 
				counter_x_dead_stage2mario_d = 4'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_dead_stage2mario_q == 4'd04) && (counter_y_dead_stage2mario_q == 4'd13))
			begin	
				counter_x_dead_stage2mario_d = 4'd00;
				counter_y_dead_stage2mario_d = 4'd00;
				state_draw_d = WAIT_STAGE2;
			end
			else
				state_draw_d = DRAW_DEAD_STAGE2_MARIO;
		end
		
		else
			state_draw_d = WAIT_STAGE2;
	end
	
	//Prints ending page
	GAME_END:
	begin
		if (Q1 == 8'h5A)
		begin
			state_draw_d = SETUP_MAINBACKGROUND;
		end
		
		else
		begin
			//draw image
			if (counter_y_endingbckgnd_q <= 7'd119)
			begin
				color_d = color_ending_background;
				x_start_endingbckgnd_d = 8'd0;
				y_start_endingbckgnd_d = 7'd0;
				x_d = x_start_endingbckgnd_d + counter_x_endingbckgnd_q;
				y_d = y_start_endingbckgnd_d + counter_y_endingbckgnd_q;
				
				counter_x_endingbckgnd_d = counter_x_endingbckgnd_q + 8'd01;
				if (counter_x_endingbckgnd_q == 8'd159)
				begin
					counter_y_endingbckgnd_d = counter_y_endingbckgnd_q + 7'd01; 
					counter_x_endingbckgnd_d = 8'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_endingbckgnd_q == 8'd159) && (counter_y_endingbckgnd_q == 7'd119))
				state_draw_d = GAME_END;
			else
				state_draw_d = GAME_END;
		end
	end
	
	GAME_OVER:
	begin
		if (Q1 == 8'h5A)
		begin
			state_draw_d = SETUP_MAINBACKGROUND;
		end
		
		else
		begin
			//draw image
			if (counter_y_gameover_q <= 7'd119)
			begin
				color_d = color_gameover;
				x_start_gameover_d = 8'd0;
				y_start_gameover_d = 7'd0;
				x_d = x_start_gameover_d + counter_x_gameover_q;
				y_d = y_start_gameover_d + counter_y_gameover_q;
				
				counter_x_gameover_d = counter_x_gameover_q + 8'd01;
				if (counter_x_gameover_q == 8'd159)
				begin
					counter_y_gameover_d = counter_y_gameover_q + 7'd01; 
					counter_x_gameover_d = 8'd00;
				end
			end	
			
			//condition for choosing next state
			if ((counter_x_gameover_q == 8'd159) && (counter_y_gameover_q == 7'd119))
				state_draw_d = GAME_OVER;
			else
				state_draw_d = GAME_OVER;
		end
	end
	
	endcase
	end
	
	/////at each clock +ve edge, pass in all values of regs into FFs in fsm draw,move.
	
	//other state except move state
	always @(posedge CLOCK_50)
	begin
		state_draw_q <= state_draw_d;
		counter_x_enemy_q <= counter_x_enemy_d;
		counter_y_enemy_q <= counter_y_enemy_d;
		counter_x_mario_q <= counter_x_mario_d;
		counter_y_mario_q <= counter_y_mario_d;
		counter_x_Qbrick_q <= counter_x_Qbrick_d;
		counter_y_Qbrick_q <= counter_y_Qbrick_d;
		erase_brown_twice_q <= erase_brown_twice_d;
		coll_qbrick_q <= coll_qbrick_d;
		counter_x_mush_q <= counter_x_mush_d;
		counter_y_mush_q <= counter_y_mush_d;
		ani_mush_twice_q <= ani_mush_twice_d;
		mush_go_down_q <= mush_go_down_d;
		mush_go_left_q <= mush_go_left_d;
		mush_go_right_q <= mush_go_right_d;
		color_q <= color_d;
		x_q <= x_d;
		y_q <= y_d;
		leftRight_q <= leftRight_d;
		counterClock_q <= counterClock_d;
		counter_x_mainbckgnd_q <= counter_x_mainbckgnd_d;
		counter_y_mainbckgnd_q <= counter_y_mainbckgnd_d;
		counter_x_mainmario_q <= counter_x_mainmario_d;
		counter_y_mainmario_q <= counter_y_mainmario_d;
		counterClock_main_q <= counterClock_main_d;
		counter_x_stage1bckgnd_q <= counter_x_stage1bckgnd_d;
		counter_y_stage1bckgnd_q <= counter_y_stage1bckgnd_d;
		counter_x_fatmario_q <= counter_x_fatmario_d;
		counter_y_fatmario_q <= counter_y_fatmario_d;
		collision_mush_q <= collision_mush_d;
		counter_x_stage2bckgnd_q <= counter_x_stage2bckgnd_d;
		counter_y_stage2bckgnd_q <= counter_y_stage2bckgnd_d;
		counter_x_princess_q <= counter_x_princess_d;
		counter_y_princess_q <= counter_y_princess_d;
		counter_x_stage2mario_q <= counter_x_stage2mario_d;
		counter_y_stage2mario_q <= counter_y_stage2mario_d;
		counterClock_stage2_q <= counterClock_stage2_d;
		counter_x_turtle_q <= counter_x_turtle_d;
		counter_y_turtle_q <= counter_y_turtle_d;
		collision_princess_q <= collision_princess_d;
		v_y_q <= v_y_d;
		d_y_q <= d_y_d;
		setTwice_q <= setTwice_d;
		collision_enemy_q <= collision_enemy_d;
		collision_coin_q <= collision_coin_d;
		counter_x_dead_stage2mario_q <= counter_x_dead_stage2mario_d;
		counter_y_dead_stage2mario_q <= counter_y_dead_stage2mario_d;
		counter_x_endingbckgnd_q <= counter_x_endingbckgnd_d;
		counter_y_endingbckgnd_q <= counter_y_endingbckgnd_d;
		counter_x_dead_stage1mario_q <= counter_x_dead_stage1mario_d;
		counter_y_dead_stage1mario_q <= counter_y_dead_stage1mario_d;
		gameover_q <= gameover_d;
		counter_x_gameover_q <= counter_x_gameover_d;
		counter_y_gameover_q <= counter_y_gameover_d;
		counter_x_coin_q <= counter_x_coin_d;
		counter_y_coin_q <= counter_y_coin_d;
		level_q <= level_d;
		condition_up_q <= condition_up_d;
		condition_leftup_q <= condition_leftup_d;
		condition_rightup_q <= condition_rightup_d;
		condition_up_y63_q <= condition_up_y63_d;	
		condition_leftup_y63_q <= condition_leftup_y63_d;	
		condition_rightup_y63_q <= condition_rightup_y63_d;
		condition_up_y71_q <= condition_up_y71_d;
		condition_leftup_y71_q <= condition_leftup_y71_d;
		condition_rightup_y71_q <= condition_rightup_y71_d;
		cond2_up_q <= cond2_up_d;
		cond2_leftup_q <= cond2_leftup_d;
		cond2_rightup_q <= cond2_rightup_d;
	end
	
	//move state 
	always @(posedge CLOCK_50)
	begin
			x_start_coin_q <= x_start_coin_d;
			y_start_coin_q <= y_start_coin_d;
			x_start_gameover_q <= x_start_gameover_d;
			y_start_gameover_q <= y_start_gameover_d;
			x_start_dead_stage1mario_q <= x_start_dead_stage1mario_d;
			y_start_dead_stage1mario_q <= y_start_dead_stage1mario_d;
			x_start_endingbckgnd_q <= x_start_endingbckgnd_d;
			y_start_endingbckgnd_q <= y_start_endingbckgnd_d;
			x_start_dead_stage2mario_q <= x_start_dead_stage2mario_d;
			y_start_dead_stage2mario_q <= y_start_dead_stage2mario_d;
			x_start_turtle_q <= x_start_turtle_d;
			y_start_turtle_q <= y_start_turtle_d;
			x_start_stage2mario_q <= x_start_stage2mario_d;
			y_start_stage2mario_q <= y_start_stage2mario_d;
			x_start_princess_q <= x_start_princess_d;
			y_start_princess_q <= y_start_princess_d;
			x_start_stage2bckgnd_q <= x_start_stage2bckgnd_d;
			y_start_stage2bckgnd_q <= y_start_stage2bckgnd_d;
			x_start_fatmario_q <= x_start_fatmario_d;
			y_start_fatmario_q <= y_start_fatmario_d;
			x_start_stage1bckgnd_q <= x_start_stage1bckgnd_d;
			y_start_stage1bckgnd_q <= y_start_stage1bckgnd_d;
			x_start_mainmario_q <= x_start_mainmario_d;
			y_start_mainmario_q <= y_start_mainmario_d;
			x_start_mainbckgnd_q <= x_start_mainbckgnd_d;
			y_start_mainbckgnd_q <= y_start_mainbckgnd_d;
			x_start_enemy_q <= x_start_enemy_d;
			y_start_enemy_q <= y_start_enemy_d;	
			x_start_mario_q <= x_start_mario_d;
			y_start_mario_q <= y_start_mario_d;
			x_start_Qbrick_q <= x_start_Qbrick_d;
			y_start_Qbrick_q <= y_start_Qbrick_d;
			x_start_mush_q <= x_start_mush_d;
			y_start_mush_q <= y_start_mush_d;
	end

/////end of at each clock +ve edge, pass in all values of regs into FFs in fsm draw,move.
	
////////////end of fsm for draw,move///////////////


////call modules to draw all images on the stage

	Enemy e1 (counter_x_enemy_d+counter_y_enemy_d*10,CLOCK_50,color_enemy);
	Mario m1 (counter_x_mario_d+counter_y_mario_d*5,CLOCK_50,color_mario);
	Mushroom mush1 (counter_x_mush_d+counter_y_mush_d*10,CLOCK_50,color_mush);
	Main_Background bckgnd1 (counter_x_mainbckgnd_d+counter_y_mainbckgnd_d*128+counter_y_mainbckgnd_d*32,CLOCK_50,color_main_background);
	Main_Mario main_mario (counter_x_mainmario_d+counter_y_mainmario_d*6,CLOCK_50,color_main_mario);
	Stage1_Background stage1 (counter_x_stage1bckgnd_d+counter_y_stage1bckgnd_d*128+counter_y_stage1bckgnd_d*32,CLOCK_50,color_stage1_background);
	Fat_Mario fat_mario (counter_x_fatmario_d+counter_y_fatmario_d*10,CLOCK_50,color_fat_mario);
	Stage2_Background stage2 (counter_x_stage2bckgnd_d+counter_y_stage2bckgnd_d*128+counter_y_stage2bckgnd_d*32,CLOCK_50,color_stage2_background);
	Princess princess (counter_x_princess_d+counter_y_princess_d*10,CLOCK_50,color_princess);
	Stage2_Mario stg2Mario (counter_x_stage2mario_d+counter_y_stage2mario_d*5,CLOCK_50,color_stage2_mario);
	Turtle turtle(counter_x_turtle_d+counter_y_turtle_d*15,CLOCK_50,color_turtle);
	Dead_Stage2Mario deadstg2mario (counter_x_dead_stage2mario_d+counter_y_dead_stage2mario_d*5,CLOCK_50,color_dead_stage2_mario);
	Ending_Background Endbckgnd (counter_x_endingbckgnd_d+counter_y_endingbckgnd_d*128+counter_y_endingbckgnd_d*32,CLOCK_50,color_ending_background);
	Dead_Stage1Mario deadstg1mario (counter_x_dead_stage1mario_d+counter_y_dead_stage1mario_d*5,CLOCK_50,color_dead_stage1_mario);
	GameOver gameoverbckgnd (counter_x_gameover_d+counter_y_gameover_d*128+counter_y_gameover_d*32,CLOCK_50,color_gameover);
	
	display_HEX H4 (4'd3 - gameover_q[3:0], HEX6);
	display_HEX H5 (4'd0, HEX7);
	display_HEX H6 (level_q[3:0], HEX4);
	display_HEX H7 (4'd0, HEX5);
	
	assign LEDG[5:0] = state_draw_q;
	assign LEDR[7:0] = x_start_mario_q;
	assign LEDR[15:8] = x_start_stage2mario_q;
		
////end of calling modules to draw all images on the stage

//////call vga adapter	
	vga_adapter VGA(
			.resetn(1),
			.clock(CLOCK_50),
			.colour(color_q),
			.x(x_q),
			.y(y_q),
			.plot(1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "MarioBackgroundNew.mif";
//////end of calling vga adapter	

ps2_Controller Keyboard(
	// Inputs
	.CLOCK_50(CLOCK_50),
	.reset(~KEY[0]),

	//.the_command,
	//.send_command,

	// Bidirectionals
	.PS2_CLK(PS2_CLK),					// PS2 Clock
 	.PS2_DAT(PS2_DAT),					// PS2 Data

	// Outputs
	//.command_was_sent,
	//.error_communication_timed_out,

	.received_data(keyboard_control),
	.received_data_en(data_received)			// If 1 - new data has been received
);			
			
endmodule

//slow the clock so that it becomes a timer of .2 seconds
module halfSecTimer (clk, enable);

	input clk;
	output reg enable;
	reg [25:0]clockCounter=0;
	always @(posedge clk)
	begin
	enable = (clockCounter==3000000);
		clockCounter <= clockCounter+26'd1;
	if (clockCounter == 3000000)
		clockCounter <= 0;
	end
endmodule

module display_HEX (input [3:0] S, output [6:0] H);

	assign H[0] = ~S[3]&~S[2]&~S[1]&S[0] | ~S[3]&S[2]&~S[1]&~S[0] | S[3]&~S[2]&S[1]&S[0] | S[3]&S[2]&~S[1]&S[0];
	assign H[1] = ~S[3]&S[2]&~S[1]&S[0] | ~S[3]&S[2]&S[1]&~S[0] | S[3]&~S[2]&S[1]&S[0] | S[3]&S[2]&~S[1]&~S[0] | S[3]&S[2]&S[1]; 
	assign H[2] = ~S[3]&~S[2]&S[1]&~S[0] | S[3]&S[2]&~S[1]&~S[0] | S[3]&S[2]&S[1];
	assign H[3] = ~S[3]&~S[2]&~S[1]&S[0] | ~S[3]&S[2]&~S[1]&~S[0] | ~S[3]&S[2]&S[1]&S[0] | S[3]&~S[2]&~S[1]&S[0] | S[3]&~S[2]&S[1]&~S[0] | S[3]&S[2]&S[1]&S[0];
	assign H[4] = ~S[3]&S[2]&~S[1] | ~S[3]&~S[2]&S[0] | ~S[3]&S[2]&S[1]&S[0] | S[3]&~S[2]&~S[1]&S[0];
	assign H[5] = ~S[3]&~S[2]&S[0] | ~S[3]&~S[2]&S[1]&~S[0] | ~S[3]&S[2]&S[1]&S[0] | S[3]&S[2]&~S[1]&S[0];
	assign H[6] = ~S[3]&~S[2]&~S[1] | ~S[3]&S[2]&S[1]&S[0] | S[3]&S[2]&~S[1]&~S[0];
	
endmodule