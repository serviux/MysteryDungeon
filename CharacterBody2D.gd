extends CharacterBody2D


const SPEED = 100

func _physics_process(delta):
	if(Input.is_action_just_pressed("move_right")):
		position.x += SPEED;
	if(Input.is_action_just_pressed("move_left")):
		position.x -= SPEED;
	if(Input.is_action_just_pressed("move_down")):
		position.y += SPEED;
	if(Input.is_action_just_pressed("move_up")):
		position.y -= SPEED;
	
