class_name Player
extends CharacterBody2D


const SPEED = 100
var map_generator:Map
@onready var CONSTANTS:GameConstants = %CONSTANTS
signal move(Direction)

func _ready() -> void:
	pass


func _physics_process(delta):
	_test_movement(delta)
	
	
func _movement():
	if(Input.is_action_just_pressed("move_up") and Input.is_action_just_pressed("move_right")):
		move.emit(CONSTANTS.DIRECTION.NORTH_EAST)
	if(Input.is_action_just_pressed("move_up") and Input.is_action_just_pressed("move_left")):
		move.emit(CONSTANTS.DIRECTION.NORTH_WEST)
	if(Input.is_action_just_pressed("move_down") and Input.is_action_just_pressed("move_right")):
		move.emit(CONSTANTS.DIRECTION.SOUTH_EAST)
	if(Input.is_action_just_pressed("move_down") and Input.is_action_just_pressed("move_left")):
		move.emit(CONSTANTS.DIRECTION.SOUTH_WEST)
	
	
	if(Input.is_action_just_pressed("move_right")):
		move.emit(CONSTANTS.DIRECTION.EAST)
	if(Input.is_action_just_pressed("move_left")):
		move.emit(CONSTANTS.DIRECTION.WEST)
	if(Input.is_action_just_pressed("move_down")):
		move.emit(CONSTANTS.DIRECTION.SOUTH)
	if(Input.is_action_just_pressed("move_up")):
		move.emit(CONSTANTS.DIRECTION.NORTH)


func _test_movement(delta):
	if(Input.is_action_pressed("move_right")):
		position.x += SPEED * delta
	if(Input.is_action_pressed("move_left")):
		position.x -= SPEED * delta
	if(Input.is_action_pressed("move_down")):
		position.y += SPEED * delta
	if(Input.is_action_pressed("move_up")):
		position.y -= SPEED * delta

func _on_start_point_set(pos:Vector2i):
	position = pos
