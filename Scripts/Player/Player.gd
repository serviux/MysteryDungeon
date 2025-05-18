class_name Player
extends CharacterBody2D


const SPEED = 100
@onready var map_generator:Map = %MapGen 
@onready var CONSTANTS:GameConstants = %CONSTANTS
signal move(Direction:GameConstants.DIRECTION)
signal moved(map_coords:Vector2i)


func _ready() -> void:
	pass


func _physics_process(_delta):
	_movement()
	
func _movement():
	if(Input.is_action_just_released("move_up") and Input.is_action_just_released("move_right")):
		move.emit(CONSTANTS.DIRECTION.NORTH_EAST)
	if(Input.is_action_just_released("move_up") and Input.is_action_just_released("move_left")):
		move.emit(CONSTANTS.DIRECTION.NORTH_WEST)
	if(Input.is_action_just_released("move_down") and Input.is_action_just_released("move_right")):
		move.emit(CONSTANTS.DIRECTION.SOUTH_EAST)
	if(Input.is_action_just_released("move_down") and Input.is_action_just_released("move_left")):
		move.emit(CONSTANTS.DIRECTION.SOUTH_WEST)
	
	
	if(Input.is_action_just_released("move_right")):
		move.emit(CONSTANTS.DIRECTION.EAST)
	if(Input.is_action_just_released("move_left")):
		move.emit(CONSTANTS.DIRECTION.WEST)
	if(Input.is_action_just_released("move_down")):
		move.emit(CONSTANTS.DIRECTION.SOUTH)
	if(Input.is_action_just_released("move_up")):
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
	

func _on_move(Direction: GameConstants.DIRECTION) -> void:
	#get current position of player on the map 
	var ground_layer = map_generator.tile_map_layers[CONSTANTS.TILE_IDX.GROUND]
	var map_pos = ground_layer.local_to_map(position)
	print("Current Player Map position x: %s y: %s Current World Position x: %s, y: %s" %[map_pos.x, map_pos.y, position.x, position.y] )
	print("Current Player Direction: %s" %[GameConstants.DIRECTION.keys()[Direction]] )
	
	var movement = map_pos
	
	match Direction:
		CONSTANTS.DIRECTION.NORTH:
			movement += Vector2i(0, -1)
		CONSTANTS.DIRECTION.NORTH_EAST:
			movement += Vector2i(1, -1)
		CONSTANTS.DIRECTION.EAST:
			movement += Vector2i(1, 0)
		CONSTANTS.DIRECTION.SOUTH_EAST:
			movement += Vector2i(1, 1)
		CONSTANTS.DIRECTION.SOUTH:
			movement += Vector2i(0,1)
		CONSTANTS.DIRECTION.SOUTH_WEST:
			movement += Vector2i(-1, 1)
		CONSTANTS.DIRECTION.WEST:
			movement += Vector2i(-1, 0)
		CONSTANTS.DIRECTION.NORTH_WEST:
			movement += Vector2i(-1,-1)
		
	var walkable = is_tile_walkable(movement)
	print("Target Map position: x:%s, y:%s Walkable: %s" %[movement.x, movement.y, walkable])
	
	if walkable:
		var new_pos = ground_layer.map_to_local(movement)
		print("Target world position x: %s y: %s" %[new_pos.x, new_pos.y])
		position = new_pos
		moved.emit(movement)

func is_tile_walkable(point:Vector2i) -> bool:
	var tile = map_generator.map[point.x][point.y]
	 
	if tile == CONSTANTS.TILE_IDX.GROUND or tile == CONSTANTS.TILE_IDX.TRAP: 
		return true
	return false 
