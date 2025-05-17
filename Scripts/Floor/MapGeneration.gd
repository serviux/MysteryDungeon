class_name Map
extends Node2D


const DEFAULT_FLOOR = preload("res://Scenes/Floor/FloorScene.tscn")

@export_category("Map Generation")
@export var width:int = 50
@export var height:int = 50

@export var fill_percent:int = 60
@export var map_seed:String
@export var use_random_seed:bool = true;

@export_category("Map Post Processing")
@export var smooth_iterations:int = 5
@export var ground_threshold:int = 20;
@export var wall_threshold:int = 20;


@export_category("Debug properties")
@export var end_pos:Vector2i 
@export var start_pos:Vector2i

@onready var CONSTANTS:GameConstants = %CONSTANTS
var map = []
var pseudo_random

var walkable_coords:Array = []
var player:Player
var tile_map
var tile_map_layers




signal start_point_set(start_position:Vector2i)


##sets the seed for the pseudo-random number generator by getting a hashing the current system time or the provided seed string from user
func _ready():
	tile_map = DEFAULT_FLOOR.instantiate()
	add_child(tile_map)
	tile_map_layers = tile_map.get_children()
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
	_find_ground_tiles()
	threshold_regions()
	set_start_point()
	_set_end_point()
	



#region MAP_GENERATION

func _random_fill():
	"""fills a map of length x,y with random tiles based on a fill percentage"""   
	for x in width:
		map.append([])
		for y in height:
			var is_ground_tile = pseudo_random.randi_range(0,100) < self.fill_percent
			if(is_ground_tile):
				map[x].append(CONSTANTS.TILE_IDX.GROUND)
			else:
				map[x].append(CONSTANTS.TILE_IDX.WALL)
				

func _fill_border():
	"""fills the edges of the map with walls"""
	for x in width:
		for y in height:
			if(x == 0 or x == width - 1 or y == 0 or y == height - 1):
				map[x][y] = 1


func _find_ground_tiles():
	"""searches the map for ground tiles, and appends them to the walkable coords member"""
	for x in width:
		for y in height:
			if(map[x][y] == CONSTANTS.TILE_IDX.GROUND):
				var coords = Vector2i(x,y)
				walkable_coords.append(coords)


func _fill_tiles():
	"""
	fills the respective tiles based off the map the corrosponding type in the map
	"""
	start_pos = tile_map_layers[0].local_to_map(Vector2.ZERO)
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
					tile_map_layers[CONSTANTS.TILE_IDX.GROUND].set_cell(coords,0,CONSTANTS.GROUND,0)
				CONSTANTS.WALL:
					tile_map_layers[CONSTANTS.TILE_IDX.WALL].set_cell(coords,0,CONSTANTS.WALL,0)
				CONSTANTS.FLUID:
					tile_map_layers[CONSTANTS.TILE_IDX.FLUID].set_cell(coords,0,CONSTANTS.FLUID,0)

func _set_end_point():
	"""
	sets the goal to reach the next floor on the map
	"""
	print("setting end point to.....")
	
	end_pos = _get_random_point()
	map[end_pos.x][end_pos.y] = CONSTANTS.TILE_IDX.TRAP
	
	
	var trap_layer = tile_map_layers[CONSTANTS.TILE_IDX.TRAP]
	var world_pos = to_global(trap_layer.map_to_local(end_pos))
	print("Endpoint(x: %s, y: %s)  World Position: (x: %s, y: %s)" %[end_pos.x, end_pos.y, world_pos.x, world_pos.y])
	
	trap_layer.set_cell(end_pos,0, CONSTANTS.STAIRS, 0)
	print("it worked")
	

func set_start_point(forced_position:Vector2i = Vector2i(-1,-1)):
	"""
	sets the point the player spawns on this floor
	Parameters
	----------
	forced_position			Vector2i  coordinates of the map to force player spawn
	"""
	print("setting start point to.....")

	var world_pos
	var ground_layer = tile_map_layers[CONSTANTS.TILE_IDX.GROUND]
	
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

func _get_random_point(is_on_ground_tile=true) -> Vector2i:
	"""
	gets a random point from the map 
	Parameters
	----------
	is_on_ground_tile	boolean 	determines if the tile should be sampled from the ground tiles without replacement 
	"""
	var random_point = Vector2i(-1,-1)
	if(is_on_ground_tile):
		var walk_rand_idx = pseudo_random.randi_range(0, len(walkable_coords))
		random_point = walkable_coords.pop_at(walk_rand_idx)
	else: 
		var map_rand_x =  pseudo_random.randi_range(1,width-1)
		var map_rand_y = pseudo_random.randi_range(1,height-1)
		
		random_point = Vector2i(map_rand_x, map_rand_y)
		
	return random_point


func smooth_map():
	"""
	Performs cellular automata to smooth the map for a number of iterations. 
	"""
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
	"""
		gets the count of the suround tiles from map coords (x,y)
		Parameters
		----------
		map_x	int		x coordinate of the map to analyze
		map_y 	int		y coordinate of the map to analyze
	"""
	var wall_count = 0
	
	#range goes from start to n-1, therefore, to get the tiles that are greater than the center
	#we need to add +2 so we look at them in the loop
	for neighbor_x in range(map_x - 1, map_x + 2): 
		for neighbor_y in range(map_y - 1, map_y + 2):
			
			if( is_in_map_range(neighbor_x, neighbor_y)):
					if(neighbor_x != map_x or neighbor_y != map_y):
						wall_count += map[neighbor_x][neighbor_y]
			else:
				wall_count += 1
	return wall_count
	
func threshold_regions():
	var wall_regions = get_regions(CONSTANTS.TILE_IDX.WALL)
	var ground_regions = get_regions(CONSTANTS.TILE_IDX.GROUND)
	
	for region in wall_regions:
		if len(region) < wall_threshold:
			for coord in region:
				map[coord.x][coord.y] = CONSTANTS.TILE_IDX.GROUND;
				
	for region in ground_regions:
		if len(region) < wall_threshold:
			for coord in region:
				map[coord.x][coord.y] = CONSTANTS.TILE_IDX.WALL;

func get_regions(tile_type):
	var regions = []
	var map_flags = []
	for x in width:
		map_flags.append([])
		for y in height:
			map_flags[x].append(0)
	
	for x in width:
		map.append([])
		for y in height:
			if(map_flags[x][y] == 0 and map[x][y] == tile_type):
				var region = get_region_tiles(x, y)
				regions.append(region)
				
				for coord in region:
					map_flags[coord.x][coord.y] = 1;
	
	return regions

func get_region_tiles(start_x:int, start_y:int):
	var tiles = []
	var map_flags = []
	# initialize an empty map to keep track of which tiles are looked at
	for x in width:
		map_flags.append([])
		for y in height:
			map_flags[x].append(0)
	
	var queue = [];
	
	queue.push_front(Vector2i(start_x, start_y))
	
	while(len(queue) > 0):
		var tile:Vector2i = queue.pop_front()
		tiles.append(tile)
		
		for x in range(tile.x - 1, tile.x + 2): 
			for y in range(tile.y - 1, tile.y + 2):
				if(is_in_map_range(x,y) and (y==tile.y or x == tile.x)):
					if(map_flags[x][y] == 0 and map[x][y] == CONSTANTS.TILE_IDX.GROUND):
						map_flags[x][y] = 1;
						queue.push_front(Vector2i(x, y))
	return tiles
	
	
func is_in_map_range(pos_x, pos_y) -> bool:
	return (pos_x >= 0 and pos_x < width and pos_y >= 0 and pos_y < height)
#endregion


#region ENTITY_SPAWNING


#endregion
