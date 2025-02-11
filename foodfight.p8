pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--can you fight hard enough
--to save your restaurant?

function _init () 
declare_variables()
create_map_objects()
make_player()
end

function _update()
	update_timer()

	if(game_state == "title") then
		update_title()
	end
	if(game_state == "game") then
		update_game()
	end
	if(game_state == "over") then
		update_game_over()
	end
	if(game_state == "results") then
		update_results()
	end
end

function _draw()
	cls()

	if(game_state == "title") then
		draw_title()
	end
	if(game_state == "game") then
		draw_game()
	end
	if(game_state == "over") then
		draw_game_over()
	end
	if(game_state == "results") then
		draw_results()
	end
end

-->8
--game state methods

function start_game()
	--reset variables
	apple_count = 0
	spag_count = 0
	burger_count = 0
	icecream_count = 0
	apple_money = 0
	spag_money = 0
	burger_money = 0
	icecream_money = 0
	total_money = 0

	game_timer = 0
	game_timer_display = time_limit/30
	game_state = "game"
	
	--lists
	monsters={}
	projectiles={}
	pickups={}
	health_icons={}
	results_text = {}

	--player
	player.x = 63
	player.y = 63
	player.health = 3
	player.i_frames = 0
	player.y_vel = 0
	player.state = "standing"
	player.attack_timer = 12
end

function update_title()
	if (btnp(❎)) then
		start_game()
		sfx(2)
	end
end

function draw_title()
	--frame
	map(32, 0, 0, 0, 16, 16)
	--draw the bg
	spr(202, 44, 40, 6, 6)
	--draw the title
	spr(192, 28, 40, 10, 6)

	--make text flash
	if (text_flash == false) then
		return
	end

	print_centered("press ❎ to start", 80, 7)
end

function update_game_over()
	--the player can't continue for 1 second
	if(game_timer < 30) then
		return
	end

	if (btnp(❎)) then
		start_game()
		sfx(2)
	end
end

function draw_game_over()
	--frame
	map(32, 0, 0, 0, 16, 16)
	print_centered("game over!", 56, 7)

	--flashing text
	if(text_flash == false) then
		return
	end
	print_centered("press ❎ to try again", 72, 7)
end

function update_game()
	update_player()
	foreach(projectiles, update_projectiles)
	foreach(monsters,update_monster)
	foreach(pickups, update_pickup)
 	spawn_monster()

	if(player.health < 1) then
		game_state = "over"
		game_timer = 0
		sfx(3)
	end
end

function draw_game()
	draw_map()
	draw_health_icons()
	draw_timer()
	draw_player()
	foreach(projectiles,draw_projectiles)
	foreach(pickups, draw_pickup)
	foreach(monsters, draw_monster)
end

function update_results()
	--if all the text is added
	--let the player advance
	if(game_timer > text_delay * 12) then
		if(btn(❎)) then
			start_game()
			sfx(2)
		else
			return
		end
	end

	--play sounds when numbers gets shown
	if(game_timer % text_delay == 0) then
		--times when the sound shouldn't play
		if(game_timer == text_delay * 0 or game_timer == text_delay * 9 
		 or game_timer == text_delay * 12) then
			return
		end
		sfx(7)
	end
end

function draw_results()
	--draw the stuff thats always drawn
	--frame
	map(32, 0, 0, 0, 16, 16)
	--title
	print_centered("results", 10, 7)
	--collected
	print("collected", 5, 24)
	print("collected", 5, 36)
	print("collected", 5, 48)
	print("collected", 5, 60)
	--food sprites
	spr(97, 59, 22)
	spr(96, 59, 34)
	spr(112, 59, 46)
	spr(113, 59, 58)
	--food prices
	print ("x $08 =", 73, 24)
	print ("x $15 =", 73, 36)
	print ("x $22 =", 73, 48)
	print ("x $30 =", 73, 60)
	--dividing line
	line(5, 72, 122, 72, 7)
	--total
	print ("total amount gotten    =", 5, 80)

	--print the dynamic text
	--using a set delay
	--apple count
	if(game_timer >= text_delay) then
		print(round(apple_count, 2), 46, 24)
	end
	--apple money
	if(game_timer >= (text_delay * 2)) then
		apple_money = apple_count * apple_price
		print("$"..round(apple_money, 3), 106, 24)
	end
	--spaghetti count
	if(game_timer >= (text_delay * 3)) then
		print(round(spag_count, 2), 46, 36)
	end
	--spaghetti money
	if(game_timer >= (text_delay * 4)) then
		spag_money = spag_count * spag_price
		print("$"..round(spag_money, 3), 106, 36)
	end
	--burger count
	if(game_timer >= (text_delay * 5)) then
		print(round(burger_count, 2), 46, 48)
	end
	--burger money
	if(game_timer >= (text_delay * 6)) then
		burger_money = burger_count * burger_price
		print("$"..round(burger_money, 3), 106, 48)
	end
	--icecream count
	if(game_timer >= (text_delay * 7)) then
		print(round(icecream_count, 2), 46, 60)
	end
	--icecream money
	if(game_timer >= (text_delay * 8)) then
		icecream_money = icecream_count * icecream_price
		print("$"..round(icecream_money, 3), 106, 60)
	end
	--total money
	if(game_timer >= (text_delay * 10)) then
		total_money = apple_money + spag_money + burger_money + icecream_money
		print("$"..round(total_money, 3), 106, 80)
	end
	--final results
	if(game_timer >= (text_delay * 11)) then
		--bad result
		if(total_money < 160) then 
			print_centered("lame... try harder next time", 96, 7)
		--middle result
		elseif (total_money < 320) then
			print_centered("not bad... keep grinding!", 96, 7)
		--good result
		else
			print_centered("wow! the food fighting king!", 96, 7)
		end
	end
	--play again text
	if(game_timer >= (text_delay * 12)) then
		--flash the text
		if(text_flash == false) then
			return
		end
		print_centered("press ❎ to play again", 110, 7)
	end
end

-->8
--player class/methods

--constructor
function make_player()
	player = {}
	player.x = 63
	player.y = 63
	player.width = 16
	player.height = 16
	player.sprite = 2
	player.health = 3
	player.i_frames = 0
	player.face_left = false
	player.speed = 2
	player.y_vel = 0
	player.state = "standing" 
	player.attack_timer = 0
	player.grounded = false
end

function update_player()
	--move right
	if(btn(➡️)) then
		player.face_left = false
		player.x += player.speed
		player.state="walking"
	--move left
	elseif (btn(⬅️)) then
		player.face_left = true
		player.x -= player.speed
		player.state="walking"
	else
	--if the player isnt walking theyre standing
		player.state="standing"
	end
	
	--jump
	if (btnp(🅾️)) then
	--only jump if the player
	--isnt in the air
		if (player.y_vel == 0 and player.grounded == true) then
			player.y_vel += 8
			player.y -= 1
			sfx(1)
		end
	end

	--player can only attack every 12 frames
	if(player.attack_timer > 0) then
		player.attack_timer -= 1
	elseif (btnp(❎)) then
		fire_projectile()
		player.attack_timer += 12
		sfx(5)
	end
	
	player_take_damage()
	update_player_vertical()
	update_player_horizontal()
end

function update_player_horizontal()
	--check collision with walls
	for wall in all (walls) do
		if (intersect(wall, player)) then 
			if(player.x < 10) then
				player.x = 8
			else
				player.x = 106
			end
		end
	end

	--screenwrap
	if (player.x < 0 - player.width) then
		player.x = 127
	elseif (player.x > 128) then
		player.x = 0 - player.width
	end	
end

function update_player_vertical()
	--so the player doesnt fall while they screenwrap
	if(player.x < 0 or player.x + player.height > 128) then
		return
	end

	player.grounded = false

	--if the player is above the floor
	if (player.y < floor_height- player.height) then
		player.y_vel -= gravity
		player.y -= player.y_vel
	end
	--if the player hits the ceiling
	if(player.y <= 3) then
		player.y_vel = 0
		player.y = 3
	end

	--if player is falling down
	if(player.y_vel < 0) then
		for plat in all (platforms) do
			if(intersect(player, plat)) then
				player.y = plat.y - player.height
				player.y_vel = 0
				player.grounded = true
			end
		end
	end

	--if the playeris on or under the floor
	if (player.y >= floor_height- player.height) then
		player.y_vel = 0
		player.y = floor_height - player.height
		player.grounded = true
	end
end

--checks for monster intersections
--and removes health
function player_take_damage()
	--if player has i frames 
	--they cant take damage
	if (player.i_frames >= 1) then
		player.i_frames-= 1
		return 
	end

	--check if monsters are touching player
	for monster in all (monsters) do
		if (intersect(player, monster)) then
			player.health-=1
			player.i_frames = 45
			monster.flee_timer = 0
		end
	end
end

--animates the player by changing sprites
function player_animate()
	if (player.state == "walking") then
		--every anim_time frames
		if (game_timer % anim_time == 0) then
			--update the sprite
			--if its not at the end increment
			if (player.sprite < 8) then
				player.sprite += 2
			--otherwise go back to start
			else 
				player.sprite = 2
			end
		end

	elseif (player.state == "standing") then
		player.	sprite = 2
	end
end

function draw_player()
	--change the sprites
	player_animate()
	--if the player has i frames then they flash
	if(player.i_frames > 0) then
		if(game_timer % 2 == 0) then
			return
		end
	end
	spr(player.sprite, player.x, player.y, 2, 2, player.face_left)
end

-->8
--enemy class/methods

--has a chance to spawn a monster
--with randomly generated attributes
function spawn_monster()
	--can only spawn every 15 frames
	if(spawn_timer > 0) then
		spawn_timer -= 1
		return
	--wont spawn if there are too many
	elseif (count(monsters) >= 6) then
		--makes the oldest one flee
		monsters[1].flee_timer = 0
		return
	--rng, more spawn at the end
	--will always continue if 
	--too few monsters
	elseif(rnd() > .15/(game_timer_display/6 + 3) 
	 and count(monsters) >= 1) then
		return
	end

	spawn_timer = 15

	--generate attributes
	local int which_monster = rnd()
	local int left_or_right = rnd()

	local monster_type
	--spawns a spaghtti, 40% chance
	if(which_monster <= .4) then
		monster_type = "spaghetti"
	--spawns an apple, 25% chance
	elseif (which_monster <= .65) then
		monster_type = "apple"
	--spawns a burger, 20% chance
	elseif (which_monster <= .85) then
		monster_type = "burger"
	--spawns an icecream, 15% chance
	else
		monster_type = "icecream"
	end

	--choose whether the monster spawns on the 
	--left or right side of the screen
	local left_spawn
	--left side
	if(left_or_right <.5) then
		left_spawn = true
	else
		left_spawn = false 
	end

	--chose which entrance the monster spawns from 
	--(top, middle, bottom)
	local entrance = rnd()

	make_monster(monster_type, left_spawn, entrance)
end

function make_monster(monster_type, left_spawn, entrance)
	new_monster = {}
	--variables that are the same for every monster
	new_monster.type = monster_type
	new_monster.move_state = "attack"
	new_monster.width = 16
	new_monster.height = 16
	new_monster.i_frames = 0
	new_monster.speed = 1
	new_monster.y_vel = 0
	new_monster.draw_flash = false

	if(monster_type == "spaghetti") then
		new_monster.health = 1
		new_monster.speed = .49 
		new_monster.sprite1 = 64
		new_monster.sprite2 = 66
		new_monster.sprite = 64
		new_monster.flee_timer = 180
		new_monster.grounded = false
	elseif (monster_type == "apple") then
		new_monster.health = 1
		new_monster.speed = .75
		new_monster.sprite1 = 68
		new_monster.sprite2 = 70
		new_monster.sprite = 68
		new_monster.flee_timer = 240
	elseif (monster_type == "burger") then
		new_monster.health = 2
		new_monster.sprite1 = 72
		new_monster.sprite2 = 74
		new_monster.sprite = 72
		new_monster.speed = .49 
		new_monster.flee_timer = 0
	elseif (monster_type == "icecream") then
		new_monster.health = 2
		new_monster.sprite = 76
		new_monster.jump_timer = 0
		new_monster.flee_timer = 180
	end

	--whether the monster spawns on the 
	--left or right side of the screen
	if(left_spawn) then
		--spawn it off the left side
		new_monster.x = -new_monster.width
		new_monster.face_left = false 
	else
		--right
		new_monster.x = 128
		new_monster.face_left = true 
	end

	--place the monster at the correct vertical entrance
	if(entrance < .33) then
		new_monster.y = 16
	elseif (entrance < .66) then
		new_monster.y = 56
	else
		new_monster.y = 104
	end

	add(monsters, new_monster)
end

function update_monster(monster)
	monster_take_damage(monster)

	--all monsters but burgers and icecream can flee
	monster.flee_timer -= 1

	if(monster.type != "burger" and monster.type != "icecream" and monster.flee_timer < 1) then
		update_fleeing_monster(monster)
		return
	end

	if (monster.type  == "apple") then
		update_apple(monster)
	elseif (monster.type == "spaghetti") then
		update_spaghetti(monster)
	elseif (monster.type == "burger") then
		update_burger(monster)
	elseif (monster.type == "icecream") then
		update_icecream(monster)
	end
end

--makes a monster flee
--if their time is up or if they attacked
--the player
function update_fleeing_monster(monster)
	--if theyre closer to the left side of the screen go left
	if(monster.x < 64) then
		monster.face_left = true
		monster.x -= (monster.speed * 2)
	--otherwise go right
	else 
		monster.face_left = false
		monster.x -= (monster.speed * 2)
	end

	if(monster.type == "spaghetti" or monster.type == "icecream") then
		update_monster_vertical(monster)
	end

	--when it goes offscreen get rid of it
	if(monster.x < -monster.width or monster.x > 128) then
		del(monsters,monster)
	end
end

function update_apple(monster)
	--move towards the player left/right
	if (player.x < monster.x) then
		monster.x -= monster.speed
		monster.face_left = true
	elseif (player.x > monster.x) then
		monster.x += monster.speed
		monster.face_left = false
	end

	--move up towards the player if player is above
	if(player.y < monster.y) then
		monster.y -= monster.speed
	--otherwise move down
	elseif (player.y > monster.y) then
		monster.y += monster.speed
	end

	--if the apple is clipping into the floor
	if(monster.y > floor_height-monster.height) then
		--find the amount it is
		local int overlap = monster.y - (floor_height-monster.height)
		monster.y -= overlap
	end
end

function update_spaghetti(monster)
	--move towards the player left/right
	if (player.x < monster.x) then
		monster.x -= monster.speed
		monster.face_left = true
	elseif (player.x > monster.x) then
		monster.x += monster.speed
		monster.face_left = false
	end

	update_monster_vertical(monster)
end

function update_burger(monster)
	--move direction its facing 
	if (monster.face_left) then
		monster.x -= monster.speed
	else 
		monster.x += monster.speed
	end

	--when it goes offscreen get rid of it
	if(monster.x < -monster.width or monster.x > 128) then
		del(monsters,monster)
	end
end

function update_icecream(monster)
	--if its charging a jump, dont do anything
	if (monster.jump_timer > 0) then
		monster.jump_timer -= 1
		return
	end

	if(monster.flee_timer > 0) then 
	--move towards the player left/right
		if (player.x < monster.x) then
			monster.x -= monster.speed
			monster.face_left = true
		elseif (player.x > monster.x) then
			monster.x += monster.speed
			monster.face_left = false
		end
	else 
		--if theyre closer to the left side of the screen go left
		if(monster.x < 64) then
			monster.face_left = true
			monster.x -= (monster.speed * 2)
		--otherwise go right
		else 
			monster.face_left = false
			monster.x -= (monster.speed * 2)
		end
	end

	update_monster_vertical(monster)

	--if on the ground, jump
	if(monster.grounded) then
		monster.y_vel += 10
		monster.y -= 1 --so it doesnt get stuck in the floor
		monster.jump_timer = 40 --prevents it from jumping for 40 frames
	end
end

function update_monster_vertical(monster)
	--so they dont fall while offscreen
	if(monster.x < 0 or monster.x + player.height > 128) then
		return
	end

	monster.grounded = false

	--if the monster is above the floor
	if (monster.y < floor_height- monster.height) then
		monster.y_vel -= gravity
		monster.y -= monster.y_vel
	end
	
	--if the monster hits the ceiling
	if(monster.y <= 3) then
		monster.y_vel = 0
		monster.y = 3
	end
	
	--platforms
	if(monster.y_vel < 0) then
		for plat in all (platforms) do
			if(intersect(monster, plat)) then
				monster.y = plat.y - monster.height
				monster.y_vel = 0
				monster.grounded = true
			end
		end
	end
	
	--if the monster is on or under the floor
	if (monster.y >= floor_height- monster.height) then
		monster.y_vel = 0
		monster.y = floor_height - monster.height
		monster.grounded = true
	end
end

function monster_take_damage(monster)
	if (monster.i_frames >= 1) then
		monster.i_frames-= 1
		return 
	end

	--check if in contact in projectile
	--if yes take damage
	for projectile in all (projectiles) do 
		if (intersect(monster, projectile)) then
			monster.health-=1
			monster.i_frames = 10
			del(projectiles,projectile)
			sfx(0)
		end
	end

	if(monster.health < 1) then
		monster_die(monster)
	end
end

--spawns a pickup and despawns a monster
function monster_die(monster)
	make_pickup(monster)
	del(monsters, monster)
	sfx(4)
end

--swap sprites to animate the monster
function monster_animate(monster)
	if (monster.type == "icecream") then
		--if its chargin a jump
		if(monster.jump_timer > 0) then
			monster.sprite = 76
		--if its in the air
		else
			monster.sprite = 78
		end
	else -- the other monsters- apple burger spag
		if(game_timer % anim_time == 0) then
			--swap between the two sprites
			if(monster.sprite == monster.sprite1) then
				monster.sprite = monster.sprite2
			else
				monster.sprite = monster.sprite1
			end
		end
	end
end

function draw_monster(monster)
	monster_animate(monster)

	--if monster has i frames it flashes
	if(monster.i_frames > 0) then
		if(game_timer % 2 == 0) then
			return
		end
	end

	spr(monster.sprite, monster.x, monster.y, 2, 2, monster.face_left)
end
-->8
--other classes/methods

--projectiles
--make a new projectile
function fire_projectile()
	local new_projectile = {}
	new_projectile.sprite = 16
	--faces same way as the player
	new_projectile.face_left = player.face_left

	--spawn it 
	new_projectile.x = player.x 
	new_projectile.y = player.y + 10
	
	--width and height of the sprite
	new_projectile.width = 8
	new_projectile.height = 4

	--add the projectile to our list
	add(projectiles, new_projectile)
end

--updates a projectile
function update_projectiles(projectile)
	--move the projectile left or right depending which way they are facing
	if (projectile.face_left) then
		projectile.x -=5
	else
		projectile.x += 5
	end

	--if the projectile goes offscreen get rid of it
	if (projectile.x < -projectile.width or projectile.x > 127) then
		del(projectiles, projectile)
	end
end

--draws a projectile
function draw_projectiles(projectile)
	spr(projectile.sprite, projectile.x, projectile.y, 1, 1, projectile.face_left)
end

--pickups
function make_pickup(monster)
	local new_pickup = {}
	new_pickup.x = monster.x 
	new_pickup.y = monster.y
	new_pickup.type = monster.type
	new_pickup.y_vel = 0
	new_pickup.height = 8
	new_pickup.width = 8

	if (monster.type  == "apple") then
		new_pickup.sprite = 97	
	elseif (monster.type == "spaghetti") then
		new_pickup.sprite = 96		
	elseif (monster.type == "burger") then
		new_pickup.sprite = 112
	elseif (monster.type == "icecream") then
		new_pickup.sprite = 113
	end
	add(pickups, new_pickup)
end

function update_pickup(pickup)
	update_pickup_vertical(pickup)

	--player picks it up
	if(intersect(pickup, player)) then
		sfx(2)
		if (pickup.type  == "apple") then
			apple_count += 1		
		elseif (pickup.type == "spaghetti") then
			spag_count += 1		
		elseif (pickup.type == "burger") then
			burger_count += 1
		elseif (pickup.type == "icecream") then
			icecream_count += 1
		end

		del(pickups, pickup)
	end	
end

function update_pickup_vertical(pickup)
	--make the pickup fall
	--if above the floor
	if (pickup.y < floor_height- pickup.height) then
		pickup.y_vel -= gravity
		pickup.y -= pickup.y_vel
	end

	--if the pickup is on or under the floor
	if (pickup.y >= floor_height- pickup.height) then
		pickup.y_vel = 0
		pickup.y = floor_height - pickup.height
	end

	--pickup intersects platforms
	for plat in all (platforms) do
		if(intersect(pickup, plat)) then
			pickup.y = plat.y - pickup.height
			pickup.y_vel = 0
		end
	end
end

function draw_pickup(pickup)
	spr(pickup.sprite, pickup.x, pickup.y)
end	

-->8
--misc methods
--declare all the variables
function declare_variables()
	--constants
	floor_height = 128-8 
	gravity = 1
	apple_price = 12
	spag_price = 8
	burger_price = 24
	icecream_price = 30
	time_limit = 45 * 30
	anim_time = 5
	
	--variables
	apple_count = 0
	spag_count = 0
	burger_count = 0
	icecream_count = 0
	apple_money = 0
	spag_money = 0
	burger_money = 0
	icecream_money = 0
	total_money = 0

	game_timer = 0
	game_timer_display = time_limit/30
	spawn_timer = 0
	game_state = "title"
	text_flash = true
	text_delay = 30
	
	--lists
	monsters = {}
	projectiles = {}
	pickups = {}
	health_icons = {}
	walls = {}
	platforms = {}
	results_text = {}
	end
--puts all the collidable map 
--tiles into a list
function create_map_objects()
	--loop through every map tile
	for i=0, 16 do
		for j=0, 16 do
			--if the sprite is a wall
			if(fget(mget(i,j), 0)) then
				new_wall = {}
				new_wall.x = i*8
				new_wall.y = j*8
				new_wall.height = 8
				new_wall.width = 8
				add(walls, new_wall)
			--otherwise a platform
			elseif (fget(mget(i,j), 2)) then
				new_plat = {}
				new_plat.x = i*8
				new_plat.y = j*8
				new_plat.height = 3
				new_plat.width = 8
				add(platforms, new_plat)
			end
		end
	end
end

function draw_map()
	--draw the brick tile in the bg
	for i = 0, 8 do
		for j = 0, 8 do
			spr(138, i*16, j*16, 2, 2)
		end
	end
	--draw the map of decorative stuff
	map(16, 0, 0, 0, 16, 16)
	--draw the map on top
	map(0, 0, 0, 0, 16, 16)
end

function update_timer()
	game_timer += 1

	--stuff conly for the gameplay state
	if(game_state == "game") then
		--if time runs out end the game
		if (game_timer >= time_limit) then
			game_state = "results"
			game_timer = 0
		end

		--game timer is in frames, game timer display is in seconds
		if(game_timer % 30 == 0) then
			game_timer_display -= 1

			if(game_timer_display <= 10) then
				sfx(6)
			end
		end
	end

	--makes text flash
	if(game_timer % 10 == 0) then
		if(text_flash) then
			text_flash = false
		else
			text_flash = true
		end
	end
end

function draw_timer()
	--draw the bg thing
	spr(173, 48, 6, 3, 2)

	print(round(game_timer_display, 2), 56, 10, 7)
end

function draw_health_icons()
	if(player.health < 1) then
		spr(17, 12, 6)
	else 
		spr(1, 12, 6)
	end
	if(player.health < 2) then
		spr(17, 24, 6)
	else
		spr(1, 24, 6)
	end
	if(player.health < 3) then
		spr(17, 36, 6)
	else
		spr(1, 36, 6)
	end
end

--checks if 2 things are intersecting
function intersect(a,b)
	return (a.x + a.width) > b.x and a.x < (b.x + b.width) and (a.y + a.height) > b.y and a.y < (b.y + b.height)
end

--adds zeros to the front of a 
--string to align it
function round(text, precision)
	--change it to string 
	--in case we pass in numbers
	local new_text = tostr(text)

	while ( #new_text < precision) do
		new_text = "0"..new_text
	end

	return new_text
end

--prints a string centered 
--horizontally 
function print_centered(text, y, color)
	print(text, 64 - #text * 2, y, color)
end

__gfx__
00000000001111000000001111110000000000111111000000000011111100000000001111110000000000000000000000000000000000000000000000000000
00000000017777100000017677671000000001767767100000000176776710000000017677671000000000000000000000000000000000000000000000000000
007007001e1661e10000017677671000000001767767100000000176776710000000017677671000000000000000000000000000000000000000000000000000
000770001e5115e10000011dddd100000000011dddd100000000011dddd100000000011dddd10000000000000000000000000000000000000000000000000000
00077000015555100000185677681000000018567768100000001856776810000000185677681000000000000000000000000000000000000000000000000000
0070070015a55a5100001e85558e100000001e85558e100000001e85558e100000001e85558e1000000000000000000000000000000000000000000000000000
00000000015115100000155555551000000015555555100000001555555510000000155555551000000000000000000000000000000000000000000000000000
00000000001111000001551155115100000155115511510000015511551151000001551155115100000000000000000000000000000000000000000000000000
01111110001111000001555a555a51000001555a555a51000001555a555a51000001555a555a5100000000000000000000000000000000000000000000000000
14466671011111100000155551551000000015555155100000001555515510000000155551551000000000000000000000000000000000000000000000000000
01177710111111110010175515171000001001751517100000101755151710000010017515171000000000000000000000000000000000000000000000000000
00011100111111110151777776777100015107777777100001517777767771000151077777777100000000000000000000000000000000000000000000000000
00000000011111100151556666655100015116556666100001515566666551000151155666655100000000000000000000000000000000000000000000000000
00000000111111110155677777771000015556777771000001556777777710000155567777711000000000000000000000000000000000000000000000000000
00000000011111100011155111551000001111551151000000111551115510000011115115510000000000000000000000000000000000000000000000000000
00000000001111000000011000110000000000110010000000000110001100000000001001100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000100000000000000010000000000000000000000000000000000000000100000000000000001110111100000
00000000000000000000000000000000000000001310000000000000131000000001111111111000000000000000000001311100000000000113381133311000
00000000000000000000000000000000000000013310000000000001331000000019fffff4ff91000000000000000000001338111110000013318a8333331000
0000000000000000000011111100000000011111411100000001111141110000014ff4fffffff410000111111111100000018a81333110001111888333bb3100
0000000000000000000133bb33100000001bbbb411ba1000001bbbb411ba100019f9fff4ff4f9f910019fffff4ff91000001888333331000017777773bbbb100
000011111100000000033bbaab310000001bbbbbbaabb100001bbbbbbaabb1001999999999999991014ff4fffffff4100017777333bb31000111111111111110
000133bb33100000001b33333b33100001b3bb1bbbaba10001b3bb1bbbaba1001aaaaaaaaaaaaaa119f9fff4ff4f9f91017777773bbbb11001611a17b11a1710
00133bbaab310000013343b433bf4100013bbb1a1bbbb100013bbb1a1bbbb100131181b3b31181b11999999999999991011111111111111001677777b7bbb610
013b33333b33100001fff4344434f10001b3bbbbbbb3bb1001b3bbbbbbbbbb101b3b3b3b3b3b3b311aaaaaaaaaaaaaa101611a17b11a17100016666776666100
0143f4334434f1000144fff1ff4f1110013b333bb3373b10013bbbbbbb33bb101888888888888881131181b3b31181b101677777b7bbb6000001111661111000
0144ff31ff4f1110014444f11bf1b41001b36663b371b10001b3b3bbb3b3b10019ffffffffffff911b3b3b3b3b3b3b3100166667766661000000001701000000
14f444f11bf1b41001ffffffffffff10013b367737711000013bbb3bb3bb31000111111111111110188888888888888100011116611110000000001701000000
144fffffffffff41014f44f1b1bfb110013bb3377711b100013bbbb33bbbb100000000000000000019ffffffffffff9100000017010000000000001001000000
1fff44f1b1bfb14101ffffffb1f1b11000133b373377b10000133bbbbbbbb1000000000000000000011111111111111000011117011110000001111001111000
014fffffb1f1b1f10014444444444100000111bbbbb11000000111bbbbb110000000000000000000000000000000000000010660006010000001066000601000
00111111111111000001111111111000000000111110000000000011111000000000000000000000000000000000000000011111111110000001111111111000
00111000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013a3100011131100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
13abb31013b41b310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b3fbf101bbbbab10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
13f4f4f11bbbabb10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f4f4f4113bbbb310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14fff441013333100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100018133100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
014fff1017733bb10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19ff4f91111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
13bbbb311777bbb10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14888841011111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
19ffff91000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110011111100000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555555555500000000000000
01111111111111111111111015661661101110111133110155515155515515151551555151555151100010001000000066100000000001111110000000000000
01666666666666666666661015551561616561666bbb16b766156156166156161551551515555151000010000001000055100000000116666661100000000000
015166666666666666661510011111105155155655b5151511011011011011010111111111111110111111111111111111000000001561111116510000000000
01555555555555555555551015155661111111111111111100000000000000001155566116615551001000000100000056100000016513133131561000000000
0111111111111111111111101551556155616655561656150000000000000000151555611555155100010010010010111111000001513b1bb1b3151000000000
000000000000000000000000011111101555155551555511000000000000000001111110011111101111111111111111566110111613bb1bb1bb316100000000
00000000000000000000000015556161111111111111111100000000000000001556165116655151000001000000010055615155151111111111115100000000
00000000000000000000000015551551551511515515155500000000000000001551555116551551000010001000100055516156151bbb1bb1bbb15100000000
011111bbbab111111bab1110151656611b013bbabb31111155515155515515151155515555515151010011000001100000000166151bbb1bb1bbb15100000000
016666363b36666666366610151555616b16633bb366166566156156166156161155551515511551111111111111111100000155151111111111115100000000
015166666366666666661510011111105515551b3655155513b3b011013bb30101111111111111100010000001000001000000111513bb1bb1bb315100000000
01555555555555555555551015555161111111131111111100b030000030b00015551661166551510001001001000000000001560151bb1bb1bb151000000000
011111111111111111111110155551615556165556615615003000000000300015551561165555511111111111111111000011110155131b313b551000000000
000003b30000000000000000011111105151555155155515000000000000000001111110011111100000010000000010101116650015511b1113510000000000
000000300000000000000000151566611111111111111111000000000000000011516661165155510000010000000100515515550001155b5555100000000000
00000000000000000000000015515551555155555555155500000000000000001515555115551551111111111111111115651555000001131111000000000000
011ba11111113babbb311110156156613ba311013ba000b355151555515515151155515555515151661000006610000055515155001111111111111111110000
0163b36666666633b3666610155515613bb3661663b31b3661561566166156161155551515511551561000005610000055616156001555555555555555510000
0151366666666666366615100113ba1053b555165636135610110111011011011111111111111111110000005100000055611011001533333333333333510000
01555555555555555555551015515b61113111111111111100b000000000b0001555155555555151661000001610000011110000001533333333333333510000
01111111111111111111111015515361555515555155551500300000000030001555155555551551551000005b30000055100000015553333333333333510000
00000000000003b30000000001111110555155515155515100000000000000001111111111111111110000001b00000051000000157075333333333333510000
00000000000000300000000015556161111111111111111100000000000000001151555555515551161000006610000015100000157005333333333333510000
00000000000000000000000015551551515555155555155500000000000000001515555555551551551000005510000055100000157775333333333333510000
013bab31113ba3113bab1110151656611131011b1111011155515155515515150000000000000000000001650000016651551555015553333333333333510000
016b33666663b66663b366101515556166b616b36566166666156156166156160000000000000000000001550000015115551655001533333333333333510000
015b66666666366666b6151001b3111055b515365555155611011011311011010000000000000000000000110000001501111665001533333333333333510000
0153555555555555553555101535156111111111111111110000003bbb300b000000000000000000000001660000016600001111001555555555555555510000
0111111111111111111111101555516151555515515561560000000b030000000000000000000000000001650000016500000165001111111111111111110000
000000000003b3000000000001113b105515551555155515000000030000000011101011101b010100000011000003b100000051000000000000000000000000
000000000000300000000000151563611111111111111111000000000000000055515155515315150000016100000b6600000115000000000000000000000000
00000000000000000000000015515551555515555555155500000000000000006615615616615616000001550000015500000155000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000330000000000000000033000000000000030000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000330000000330000000033000000000000330000000000000
77777700000000000000000000000000000000000000000000000000000000000000077777777770003333333333300000330000000000000330000000000000
77777700776776770000000000000000000000000000000000000000000000000000077777777770003333333333333333300000330000000000000000000000
77555507767777677000000000000000000000000000000006600000000000000000055557755550033333333333333333300000330000033300000000000000
77000007767777677000000000000000000000000000000006600000000000000000000007700000033333333333333333300000033003333333300000000000
77000007767777677000777700007777000000777777000665500007777770077000077007700000033333333333333333000000033333333333330000000000
77000007776776777000777700007777000000777777000665500007777770077000077007700000033333333333333333000000033333333333333000003300
77000000666666660077555577007755770000775555000665500775555550077000077007700000033333333333333333000033333333333333333000033300
77770000777777770077000077007700770000770000000665500770000000077000077007700000033333333333333333333333333333333333333300333300
77770000777777770077000077007700557700777770066555500770077770077777777007700000033333333333333333333333333333333333333333333000
77550000555555550077000077007700007700777770066555500770077770077777777007700000033333333333333333333333333333333333333333300000
77000000770000770077000077007700007700775550066555500770055770077555577007700000033333333333333333333333333333333333333333300000
77000000770000770077000077007700007700770000066555500770000770077000077007700000003333333333333333333333333333333333333333300000
77000000770000770077000077007700007700770000055664400770000770077000077007700000003333333333333333333333333333333333333333300000
77000000770000770077000077007700007700770000000664400770000770077000077007700000000333333333333333333333333333333333333333330000
77000000557777550555777755007777775500770000000554400557777550077000077007700000000003333333333333333333333333333333333333330000
77000000007777000000777700007777770000770000000004400007777000077000077007700000000003333330003333333333333333333333333333333000
55000000005555000000555500005555550000550000000002200005555000055000055005500000000003333000003333333333333333333333333333333300
00000000000000000000000000000000000000000000000000000000000000000000000000000000000333300000003300033333333333333333333333333300
00000000000000000000000000000000000000000000000000000000000000000000000000000000000333300000003300000333333333333333333333333300
00000000000000000000000000000000000000000000000000000000000000000000000000000000003333300000003300000033333333333333333333333300
00000000777777000077000077770000077007700007700007777000077777700770077000000000003333000000000000000033333333333333333333333300
00000000777777000077000077770000077777700007700007777000077777700770077000000000000330000000000000000003333333333333333333333300
00000000775555007755770077557700077777700775577007755770077555500770077000000000000000000000000000000003333333333333333333333300
00000000770000007700770077007700077557700770077007700770077770000770077000000000000000000000003000000000333333333333333333333000
00000000777700007700770077775500077007700770077007700770077770000557755000000000000000000000033000000000333333333333333333330000
00000000777700007700770077770000077007700770077007700770077550000007700000000000000000000000033000000000333000000333333333300000
00000000775500005577550077557700077007700557755007700770077777700007700000000000000000000000000000000003330000000003333330000000
00000000770000000077000077007700077007700007700007700770077777700007700000000000000000000000000000000003330000000000033000003300
00000000550000000055000055005500055005500005500005500550055555500005500000000000000000000000000000000003330000000000033000033300
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000
__label__
55515155555151555155151555515155515515155551515551551515515515155155151555515155515515155551515551551515555151555155151551551555
55616156661561561661561666156156166156166615615616615616166156161661561666156156166156166615615616615616661561561661561615551655
55611011110110110110110113b3b011011011011101101101101101011011010110110111011011013bb3011101101101101101110110110110110101111665
11110000000000000000000000b030000000000000000000000000000000b00000000000000000000030b0000000000000000000000000000000000000001111
55100000000000000000000000300000000000000000000000000000000030000000000000000000000030000000000000000000000000000000000000000165
51000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000051
15100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000115
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
56100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000161
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
56100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000161
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
56100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000161
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
56100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000151
51000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
5b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
1b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b1
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b66
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000330000000000000000033000000000000030000000000000000000000000000000000000000000000165
56100000000000000000000000000000000000000000330000000330000000033000000000000330000000000000000000000000000000000000000000000155
11000000000000000000000000007777770000000000003333333333300000330000000000000330000000000000000007777777777000000000000000000011
66100000000000000000000000007777770077677677003333333333333333300000330000000000000000000000000007777777777000000000000000000166
55100000000000000000000000007755550776777767733333333333333333300000330000033660000000000000000005555775555000000000000000000165
11000000000000000000000000007700000776777767733333333333333333300000033003333663300000000000000000000770000000000000000000000011
16100000000000000000000000007700000776777767733377773333777733000077777733366553330777777007700007700770000000000000000000000161
55100000000000000000000000007700000777677677733377773333777733000077777733366553333777777307700007700770000000000000000000000155
66100000000000000000000000007700000066666666037755557733775577000077555533366553377555555307700007700770000000000000000000000165
56100000000000000000000000007777000077777777037733337733773377333377333333366553377300333307700007700770000000000000000000000155
11000000000000000000000000007777000077777777037733337733773355773377777336655553377337777007777777700770000000000000000000000011
66100000000000000000000000007755000055555555037733337733773333773377777336655553377337777007777777700770000000000000000000000166
55100000000000000000000000007700000077000077037733337733773333773377555336655553377335577007755557700770000000000000000000000165
11000000000000000000000000007700000077000077007733337733773333773377333336655553377333377007700007700770000000000000000000000011
16100000000000000000000000007700000077000077007733337733773333773377333335566443377333377007700007700770000000000000000000000161
55100000000000000000000000007700000077000077007733337733773333773377333333366443377333377007700007700770000000000000000000000155
66100000000000000000000000007700000055777755055577775533777777553377333333355443355777755007700007700770000000000000000000000165
56100000000000000000000000007700000000777700000077773330777777333377333333333443333777733007700007700770000000000000000000000155
11000000000000000000000000005500000000555500000055553000555555333355333333333223333555533305500005500550000000000000000000000011
66100000000000000000000000000000000000000000000333300000003300033333333333333333333333333300000000000000000000000000000000000166
55100000000000000000000000000000000000000000000333300000003300000333333333333333333333333300000000000000000000000000000000000165
11000000000000000000000000000000000000000000003333300000003300000033333333333333333333333300000000000000000000000000000000000011
16100000000000000000000000000000000077777700007733007777000007700773333773333777733337777770077007700000000000000000000000000161
55100000000000000000000000000000000077777700007730007777000007777773333773333777733337777770077007700000000000000000000000000155
66100000000000000000000000000000000077555500775577007755770007777773377557733775577337755550077007700000000000000000000000000165
56100000000000000000000000000000000077000000770077007700773007755770377337733773377337777000077007700000000000000000000000000155
11000000000000000000000000000000000077770000770077007777553007700770377337733773377337777000055775500000000000000000000000000011
66100000000000000000000000000000000077770000770077007777033007700770377007700773377337755000000770000000000000000000000000000166
55100000000000000000000000000000000077550000557755007755770007700773355775500773377337777770000770000000000000000000000000000165
11000000000000000000000000000000000077000000007700007700770007700773330770000770077007777770000770000000000000000000000000000011
16100000000000000000000000000000000055000000005500005500550005500553330550000550055005555550000550000000000000000000000000000161
55100000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
56100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000151
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b1
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b66
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000777077707770077007700000077777000000777007700000077077707770777077700000000000000000000000000165
56100000000000000000000000000000707070707000700070000000770707700000070070700000700007007070707007000000000000000000000000000155
11000000000000000000000000000000777077007700777077700000777077700000070070700000777007007770770007000000000000000000000000000011
66100000000000000000000000000000700070707000007000700000770707700000070070700000007007007070707007000000000000000000000000000166
55100000000000000000000000000000700070707770770077000000077777000000070077000000770007007070707007000000000000000000000000000165
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000161
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
56100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
51000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
5b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000161
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
56100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000161
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
56100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000151
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003b1
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b66
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
56100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000165
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
16100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000161
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
66100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000166
55100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000155
11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011
56100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000156
11110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111
566110111110101111101011101b0101111010111110101111101011111010111110101111101011101b010111101011101b0101111010111110101110111665
55615155555151555551515551531515555151555551515555515155555151555551515555515155515315155551515551531515555151555551515551551555
55516156661561566615615616615616661561566615615666156156661561566615615666156156166156166615615616615616661561566615615615651555

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000102020404010100000400000000000001020204040101000004000000000000010202040404040000040000000000000102020404040401010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8886868696868686b6b78686a797868900000000000000000000000000000000ac868796878687a787869786878687bc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8300000000000000000000000000008300000000000000000000000000000000aa0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000aa0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000aa0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8886a70000000000000000000086a68900000000000000000000000000000000ab0000000000000000000000000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8300000000000000000000000000009300000000000000000000000000000000aa0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8300000000008686b78600000000008300000000000000000000000000000000aa0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000008d8e00008d8e00008d8e000000aa0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000009d9e00009d9e00009d9e000000aa0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88868696000000000000000000a7868900000000000000000000000000000000aa0000000000000000000000000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8300000000000000000000000000009300000000000000000000000000000000aa0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a300000000000000000000000000008300000000000000000000000000000000ab0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3000000000000a786b6b7860000009300000000000000000000000000000000aa0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000aa0000000000000000000000000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000aa0000000000000000000000000000ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b584b5a48484b48485b584b584b48484000000000000000000000000000000008cb8b8b9b8b8b8b8b8b8b9b8b9b8b89c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0002000012670106700f6700d6700a67007670046700067000600260002b100200002c100210002d10022000210002f1002f1003010030100271002810029100291002a1002b1002d10030100210002600026000
00020000135101351014510155101651017510185101a5101c5101f5101e500205002150022500235002550026500265002750029500295002a5002b5002b5002c5002c5002d5002e5002f500000000000000000
000300001852018520185201a5201c520205202452028520296002d6003f6003c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000023170201701f1701e1701c17019170171701717016170151701417012170111700f1700e1700d1700c1700a1700917007170041700317002170011700017000170001000010000100001000000000000
0003000029150241501f1501c1501915017150151501315012150121500a100091000910009100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002c6102e61030610336103c6003e6003f6003a6003a6003a6003a6003a6003a6003a6003a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001f1101f1101f1101f1101f1101f1101f11000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000455004550045500455004550045500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002c5502c5502d5502c5502d5502d5502e5502d5502e5502d5502d550305502d5502d5502e5502e5502e5502f5503055031550375503855038550395500000000000000000000000000000000000000000
