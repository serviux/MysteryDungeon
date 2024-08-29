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
#endregion
