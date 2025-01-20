class_name Map
extends Node


const DEFAULT_FLOOR = preload("res://Scenes/Floor/FloorScene.tscn")
@export var width:int
@export var height:int

@export var fill_percent:int = 60
@export var smooth_iterations:int = 5
@export var map_seed:String
@export var use_random_seed:bool = true;
@export var end_pos:Vector2i 
@export var start_pos:Vector2i

@export var map_max:Vector2i = Vector2i(100,100)

@onready var CONSTANTS:GameConstants = %CONSTANTS
var mesh_generator
var map = []
var pseudo_random

var spawnable_coords_x = {}
var spawnable_coords_y = {}
var player:Player
var floor
var layers


signal start_point_set(start_position:Vector2i)


##sets the seed for the pseudo-random number generator by getting a hashing the current system time or the provided seed string from user
func _ready():
	floor = DEFAULT_FLOOR.instantiate()
	add_child(floor)
	layers = floor.get_children()
	pseudo_random = RandomNumberGenerator.new()
	if use_random_seed:
		var seed_string = Time.get_datetime_string_from_system()
		
		var rand_seed = hash(seed_string)
		print("random seed for map generation: %s" % rand_seed)
		pseudo_random.seed = rand_seed
	else:
		var seed_value = hash(map_seed)
		print("converting input seed value %s to integer %s" % [map_seed, seed_value])
		pseudo_random.seed = seed_value
	player = get_node("%Player")
	start_point_set.connect(player._on_start_point_set)
	generate_map()


func generate_map():

	_random_fill()
	
	
	for x in smooth_iterations:
		smooth_map()
	
	_fill_tiles()
	
	#set stairs to next floor
	#_set_end_point()
	
	
	#set_start_point()
	
		
func _random_fill():      
	for x in width:
		map.append([])
		for y in height:
			if(x == 0 or x == width - 1 or y == 0 or y == height - 1):
				map[x].append(1)
			else:
				map[x].append(1 if pseudo_random.randi_range(0,100) < self.fill_percent else 0 )


func _fill_tiles():
	var start_pos = layers[0].local_to_map(Vector2.ZERO)
	for x in width:
		for y in height:
			var tile_idx = map[x][y]
			var tile_type
			if(tile_idx == 0):
				tile_type = CONSTANTS.GROUND 
			elif(tile_idx == 1):
				tile_type = CONSTANTS.WALL
				
			var coords = Vector2i(start_pos.x + x, start_pos.y + y)
			
			match tile_type:
				CONSTANTS.GROUND:
					layers[CONSTANTS.TILE_IDX.GROUND].set_cell(coords,0,tile_type,0)
				CONSTANTS.WALL:
					layers[CONSTANTS.TILE_IDX.WALL].set_cell(coords,0,tile_type,0)
				CONSTANTS.FLUID:
					layers[CONSTANTS.TILE_IDX.FLUID].set_cell(coords,0,tile_type,0)

func _set_end_point():
	print("setting end point to.....")
	end_pos.x = randi_range(0,map_max.x -1)
	end_pos.y = randi_range(0,map_max.y -1)

	while map[end_pos.x][end_pos.y] != 0:
		end_pos.x = randi_range(0,map_max.x -1)
		end_pos.y = randi_range(0,map_max.y -1)
	
	print("Endpoint(x: %s, y: %s)" %[end_pos.x, end_pos.y])
	
	var ground_layer = layers[CONSTANTS.TILE_IDX.GROUND]
	ground_layer.set_cell(end_pos,0, CONSTANTS.STAIRS, 0)
	

func set_start_point(forced_position:Vector2i = Vector2i(-1,-1)):
	print("setting start point to.....")
	start_pos.x = randi_range(0,map_max.x -1)
	start_pos.y = randi_range(0,map_max.y -1)
	
	if forced_position > Vector2i.ZERO:
		print("setting forced position: x: %s, y: %s" %[forced_position.x, forced_position.y])
		start_pos = forced_position
		start_point_set.emit(start_pos)
		return
	
	while map[start_pos.x][start_pos.y] != 0 or start_pos == end_pos:
		start_pos.x = randi_range(0,map_max.x -1)
		start_pos.y = randi_range(0,map_max.y -1)
	
	
	var ground_layer = layers[CONSTANTS.TILE_IDX.GROUND]
	var world_pos = ground_layer.map_to_local(start_pos)
	print("Map Startpoint(x: %s, y: %s) World Startpoint (x: %s, y: %s)" %[start_pos.x, start_pos.y, world_pos.x, world_pos.y])
	start_point_set.emit(world_pos)

func _get_random_point(): 
	var random_point = Vector2i(-1,-1)
	
	map.pick_random()
	


func smooth_map():
	var map_copy = map.duplicate(true)
	for x in range(len(map_copy)):
		for y in range(len(map_copy[x])):
			var neighbor_tiles = get_surrounding_tiles_count(x,y)
			if(neighbor_tiles > 4):
				map_copy[x][y] = 1
			elif(neighbor_tiles < 4):
				map_copy[x][y] = 0
	
	map = map_copy
			

			
func get_surrounding_tiles_count(map_x:int, map_y:int) -> int: 
	var wall_count = 0
	
	#range goes from start to n-1, therefore, to get the tiles that are greater than the center
	#we need to add +2 so we look at them in the loop
	for neighbor_x in range(map_x - 1, map_x + 2): 
		for neighbor_y in range(map_y - 1, map_y + 2):
			
			if( neighbor_x >= 0 and neighbor_x < width and 
				neighbor_y >= 0 and neighbor_y < height):
					if(neighbor_x != map_x or neighbor_y != map_y):
						wall_count += map[neighbor_x][neighbor_y]
			else:
				wall_count += 1
	return wall_count
