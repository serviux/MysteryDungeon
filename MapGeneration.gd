extends TileMap

@export var width:int
@export var height:int

@export var fill_percent:int = 50
@export var smooth_iterations:int = 5

@export var map_seed:String
@export var use_random_seed:bool = true;



@onready var CONSTANTS = %CONSTANTS
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
		
	
	generate_map()


func generate_map():
	_random_fill()
	
	
	for x in smooth_iterations:
		smooth_map()
		
	_fill_tiles()
	
	
		
		
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


func smooth_map():
	for x in map:
		for y in x:
			#TODO: implement smoothing
			pass
			

			
func get_surrounding_tiles_count(map_x:int, map_y:int):
	var wall_count = 0
	var neighbor_x = map_x - 1
	var neighbor_y = map_y - 1
	wall_count = count_surrounding_tiles(map_x, map_y, neighbor_x,neighbor_y, wall_count)
	return wall_count
	

func count_surrounding_tiles(map_x:int, map_y:int, neighbor_x:int, neighbor_y:int, wall_count:int):
	if (neighbor_x > map_x +1) and (neighbor_y >  map_y + 1) : 
		return wall_count
	
	if( neighbor_x > 0 and neighbor_x < width and 
		neighbor_y > 0 and neighbor_y < height):
			wall_count += map[neighbor_x][neighbor_y]
	else:
		wall_count += 1
	
	if(neighbor_y <= map_y +1):
		wall_count = count_surrounding_tiles(map_x, map_y, neighbor_x, neighbor_y + 1, wall_count)
	elif(neighbor_x <= map_x + 1):
		#reset neighbor_y to look at surrounding tiles on that column 
		neighbor_y = map_y - 1
		wall_count = count_surrounding_tiles(map_x, map_y,neighbor_x + 1, neighbor_y, wall_count)
	


