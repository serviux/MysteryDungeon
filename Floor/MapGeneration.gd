extends TileMap

@export var width:int
@export var height:int

@export var fill_percent:int = 50
@export var smooth_iterations:int = 5
@export var map_seed:String
@export var use_random_seed:bool = true;
@export var end_pos:Vector2i 


@onready var CONSTANTS = %CONSTANTS
var mesh_generator
var map = []
var pseudo_random



##sets the seed for the pseudo-random number generator by getting a hashing the current system time or the provided seed string from user
func _ready():
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
		
	mesh_generator = get_node("MeshGenerator")
	generate_map()


func generate_map():
	_random_fill()
	
	
	for x in smooth_iterations:
		smooth_map()
	
	#mesh_generator.generate_mesh(map, 1)
	_fill_tiles()
	_set_end_point()
	
	#set stairs to next floor
	
	
		
		
func _random_fill():      
	for x in width:
		map.append([])
		for y in height:
			if(x == 0 or x == width - 1 or y == 0 or y == height - 1):
				map[x].append(1)
			else:
				map[x].append(1 if pseudo_random.randi_range(0,100) < self.fill_percent else 0 )


func _fill_tiles():
	for x in width:
		for y in height:
			var tile_idx = map[x][y]
			var tile_type
			if(tile_idx == 0):
				tile_type = CONSTANTS.GROUND 
			elif(tile_idx == 1):
				tile_type = CONSTANTS.WALL
				
			var coords = Vector2i(x,y)
			set_cell(0, coords, 0, tile_type )


func _set_end_point():
	print("setting end point to.....")
	end_pos.x = randi_range(0,100)
	end_pos.y = randi_range(0,100)
	
	while map[end_pos.x][end_pos.y] != 0:
		end_pos.x = randi_range(0,100)
		end_pos.y = randi_range(0,100)
	
	print("Endpoint(x: %s, y: %s)" %[end_pos.x, end_pos.y])
	set_cell(0, end_pos,0, CONSTANTS.STAIRS)
	
	
	


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
	
