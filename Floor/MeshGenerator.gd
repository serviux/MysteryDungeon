extends Node


#region class_defs
class MeshNode :
	var position:Vector3
	var vertex_idx: int
	
	func _init(pos:Vector3):
		self.position = pos

class ControlMeshNode extends MeshNode:
	var active:bool
	var above:MeshNode
	var right:MeshNode
	
	func _init(pos:Vector3, active:bool, square_size:float):
		super._init(pos)
		self.active = active
		
		
		self.above = MeshNode.new(self.position + Vector3.FORWARD * (square_size/2))
		self.right = MeshNode.new(self.position + Vector3.RIGHT * (square_size/2))

class Square:
	var top_left:ControlMeshNode
	var top_right:ControlMeshNode
	var bot_right:ControlMeshNode
	var bot_left:ControlMeshNode
	var cent_top:MeshNode
	var cent_right:MeshNode
	var cent_bot:MeshNode
	var cent_left:MeshNode
	
	func _init(top_left: ControlMeshNode,
			  	top_right: ControlMeshNode, 
				bot_right: ControlMeshNode,
				bot_left: ControlMeshNode):
				
				self.top_left = top_left
				self.top_right = top_right
				self.bot_right = bot_right
				self.bot_left = bot_left
				
				self.cent_top = top_left.right
				self.cent_right = bot_right.above
				self.cent_bot = bot_left.right
				self.cent_left = bot_left.above


class SquareGrid:
	var squares
	
	func _init(map, square_size:float):
		var node_count_x = len(map)
		var node_count_y = len(map[0])
		
		var map_width = node_count_x * square_size
		var map_height = node_count_y * square_size
		
		var control_nodes = []
		
		for x in node_count_x:
			control_nodes.append([])
			for y in node_count_y:
				var pos = Vector3(-map_width/2 + x * square_size + square_size/2,
							  0,
							  -map_height/2 + y * square_size + square_size/2)
				control_nodes[x][y] = ControlMeshNode.new(pos, map[x][y] == 1, square_size)
		
		squares = [] 
		for x in node_count_x:
			squares.append([])
			for y in node_count_y:
				squares[x][y] = Square.new(control_nodes[x][y+1],
										  control_nodes[x+1][y+1],
										  control_nodes[x+1][y],
										  control_nodes[x][y])


var square_grid:SquareGrid

func generate_mesh(map, square_size:float):
	square_grid = SquareGrid.new(map, square_size)
#endregion
