class_name Map
extends Node2D


const DEFAULT_FLOOR = preload("res://Scenes/Floor/FloorScene.tscn")
@export var width:int = 50
@export var height:int = 50

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

var walkable_coords:Array = []
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
	
	_fill_border()
	
	_fill_tiles()
	#set stairs to next floor
	
	_find_ground_tiles()

	
	
	set_start_point()
	_set_end_point()



#region MAP_GENERATION

func _random_fill():      
	for x in width:
		map.append([])
		for y in height:
			var is_ground_tile = pseudo_random.randi_range(0,100) < self.fill_percent
			if(is_ground_tile):
				map[x].append(CONSTANTS.TILE_IDX.GROUND)
			else:
				map[x].append(CONSTANTS.TILE_IDX.WALL)
				

func _fill_border():
	for x in width:
		for y in height:
			if(x == 0 or x == width - 1 or y == 0 or y == height - 1):
				map[x][y] = 1


func _find_ground_tiles():
	for x in width:
		for y in height:
			if(map[x][y] == CONSTANTS.TILE_IDX.GROUND):
				var coords = Vector2i(x,y)
				walkable_coords.append(coords)

func _fill_tiles():
	var start_pos = layers[0].local_to_map(Vector2.ZERO)
	for x in width:
		for y in height:
			var tile_idx = map[x][y]
			var tile_type
			if(tile_idx == CONSTANTS.TILE_IDX.GROUND):
				tile_type = CONSTANTS.GROUND 
			elif(tile_idx == CONSTANTS.TILE_IDX.WALL):
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
	
	var end_pos = _get_random_point()
	map[end_pos.x][end_pos.y] = CONSTANTS.TILE_IDX.TRAP
	
	print("Endpoint(x: %s, y: %s)" %[end_pos.x, end_pos.y])
	
	var trap_layer = layers[CONSTANTS.TILE_IDX.TRAP]
	trap_layer.set_cell(end_pos,0, CONSTANTS.STAIRS, 0)
	

func set_start_point(forced_position:Vector2i = Vector2i(-1,-1)):
	print("setting start point to.....")

	var world_pos
	var ground_layer = layers[CONSTANTS.TILE_IDX.GROUND]
	
	if forced_position > Vector2i.ZERO:
		world_pos = forced_position
		print("setting forced position: x: %s, y: %s" %[forced_position.x, forced_position.y])
		world_pos = ground_layer.map_to_local(start_pos)
		start_pos = forced_position
		start_point_set.emit(world_pos)
		return
	
	var spawn = _get_random_point()
	
	world_pos = spawn
	world_pos = ground_layer.map_to_local(world_pos)
	print("Map Startpoint(x: %s, y: %s) World Startpoint (x: %s, y: %s)" %[spawn.x, spawn.y, world_pos.x, world_pos.y])
	world_pos = to_global(world_pos)
	
	
	start_point_set.emit(world_pos)

func _get_random_point(walkable=true) -> Vector2i: 
	var random_point = Vector2i(-1,-1)
	if(walkable):
		var walk_rand_idx = pseudo_random.randi_range(0, len(walkable_coords))
		random_point = walkable_coords.pop_at(walk_rand_idx)
	else: 
		var map_rand_x =  pseudo_random.randi_range(1,width-1)
		var map_rand_y = pseudo_random.randi_range(1,height-1)
		
		random_point = Vector2i(map_rand_x, map_rand_y)
		
	return random_point
	


func smooth_map():
	var map_copy = map.duplicate(true)
	for x in range(len(map_copy)):
		for y in range(len(map_copy[x])):
			var neighbor_tiles = get_surrounding_tiles_count(x,y)
			if(neighbor_tiles > 4):
				map_copy[x][y] = CONSTANTS.TILE_IDX.WALL
			elif(neighbor_tiles < 4):
				map_copy[x][y] = CONSTANTS.TILE_IDX.GROUND
	
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
#endregion


#region ENTITY_SPAWNING


#endregion
