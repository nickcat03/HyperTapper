extends Node2D

# References to the button sprites using onready variables
@onready var up_sprite : Node2D = $UpButton
@onready var down_sprite : Node2D  = $DownButton
@onready var left_sprite : Node2D = $LeftButton
@onready var right_sprite : Node2D = $RightButton
@onready var a_sprite : Node2D = $AButton
@onready var b_sprite : Node2D = $BButton
@onready var x_sprite : Node2D = $XButton
@onready var y_sprite : Node2D = $YButton
@export var score_label : Label
@export var streak_label : Label
@export var multiplier_label : Label
@export var camera : Camera2D

#SFX
@export var background_music : AudioStreamPlayer2D
@export var successful_hit_sound : AudioStreamPlayer2D
@export var fast_hit_sound : AudioStreamPlayer2D
var random_pitch = 0
@export var multiplier_sound : AudioStreamPlayer2D
@export var wrong_button_sound : AudioStreamPlayer2D
@export var high_score_sound : AudioStreamPlayer2D

#Timer
var timer = 2.0
@export var timer_bar_1 : ProgressBar
@export var timer_bar_2 : ProgressBar
var timer_speed = 1.0
var timer_max = 2.0
var timer_speed_up_interval = 20
var timer_speed_up_amount = 1.1

#Game Over
var game_over = false
@export var game_over_label : Label
@export var background_dimmer : ColorRect

var score = 0
var button_streak = 0
var score_multiplier = 1
var previous_score_multiplier = 1
var current_glowing_button = ""
var shake_duration = 0.0
var shake_magnitude = 0.7

func _ready():
	# Center to viewport
	#var viewport_size = get_viewport_rect().size
	#position = viewport_size / 2
	
	background_music.play()
	
	randomize()
	# Make sure all glowing button sprites are initially hidden
	initialize_sprites()
	# Select the first button to glow
	select_random_button()
	# Initialize score
	score_label.text = "0"
	# Set gameover backgrounds to not show by default
	game_over_label.visible = false
	background_dimmer.visible = false

func _process(delta):
	if not game_over:
		# Update each button's state
		update_button_state("up", up_sprite)
		update_button_state("down", down_sprite)
		update_button_state("left", left_sprite)
		update_button_state("right", right_sprite)
		update_button_state("a", a_sprite)
		update_button_state("b", b_sprite)
		update_button_state("x", x_sprite)
		update_button_state("y", y_sprite)
		
		# Handle timer countdown
		timer -= delta * timer_speed
		if timer > 2.0:
			timer = 2.0
		if timer <= 0:
			game_over_routine()
		else: 
			#update the timer display 
			timer_bar_1.value = timer
			timer_bar_2.value = timer
			
		# Handle score multiplier
		score_multiplier = (button_streak / 10) + 1
		if score_multiplier > 1:
			multiplier_label.text = str(score_multiplier) + "x"
		else:
			multiplier_label.text = ""
		if score_multiplier > previous_score_multiplier:
			multiplier_sound.play()
			timer += 0.3
		previous_score_multiplier = score_multiplier
		
		streak_label.text = "Streak: %d" % button_streak
		
		# Handle screen shake
		if shake_duration > 0:
			shake_duration -= delta
			camera.position += Vector2(randf_range(-shake_magnitude, shake_magnitude), randf_range(-shake_magnitude, shake_magnitude))
			if shake_duration <= 0:
				camera.position = Vector2.ZERO
	elif Input.is_action_just_pressed("a"):
		reset_game()

func initialize_sprites():
	up_sprite.modulate = Color(1, 1, 1, 1)  # White color (normal)
	down_sprite.modulate = Color(1, 1, 1, 1)
	left_sprite.modulate = Color(1, 1, 1, 1)
	right_sprite.modulate = Color(1, 1, 1, 1)
	a_sprite.modulate = Color(1, 1, 1, 1)
	b_sprite.modulate = Color(1, 1, 1, 1)
	x_sprite.modulate = Color(1, 1, 1, 1)
	y_sprite.modulate = Color(1, 1, 1, 1)

func update_button_state(action_name, sprite):
	if Input.is_action_just_pressed(action_name):
		if action_name == current_glowing_button:
			timer += 0.5
			button_streak += 1
			score += 1 * score_multiplier
			score_label.text = str(score)
			play_button_hit_sound()
			shake_screen()
			select_random_button()
			# Give bonus points if timer hits max amount
			if timer > timer_max:
				score += 2 * score_multiplier
				fast_hit_sound.play()
			# Speed up timer every 20 points 
			if score % timer_speed_up_interval == 0:
				timer_speed *= timer_speed_up_amount
		else:
			timer -= 0.25
			button_streak = 0
			score_multiplier = 1
			timer_bar_1.value = timer
			timer_bar_2.value = timer
			sprite.modulate = Color(100, 0, 0, 100)  # Red color when pressed
			wrong_button_sound.play()
	else:
		sprite.modulate = Color(1, 1, 1, 1)  # White color (normal)
	if action_name == current_glowing_button:
		sprite.modulate = Color(100, 100, 0, 100)  # Yellow color when it's the target
		
func select_random_button():
	var buttons = ["up", "down", "left", "right", "a", "b", "x", "y"]
	current_glowing_button = buttons[randi() % buttons.size()]
	print("Selected button: ", current_glowing_button)
	
func play_button_hit_sound():
	random_pitch = randf_range(0.95, 1.05) 
	successful_hit_sound.set_pitch_scale(random_pitch)
	successful_hit_sound.play()
		
func shake_screen():
	shake_duration = 0.04
	
func game_over_routine():
	game_over = true
	game_over_label.visible = true
	background_dimmer.visible = true
	score = 0
	score_label.text = str(score)
	high_score_sound.play()
	background_music.stop()
	
func reset_game():
	game_over = false
	game_over_label.visible = false
	background_dimmer.visible = false
	score = 0
	button_streak = 0
	score_multiplier = 1
	previous_score_multiplier = 1
	score_label.text = str(score)
	timer = 2.0
	timer_speed = 1.0
	select_random_button()
	high_score_sound.stop()
	background_music.play()
