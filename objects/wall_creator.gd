extends RigidBody2D

const Wall = preload("res://objects/wall.tscn") 

var wall_rotation
var player

func _on_wall_creator_body_entered(body):
	if body is StaticBody2D:
		make_wall()
		queue_free()

func make_wall():
	var wall = Wall.instance()
	var disposition = Vector2(-50, 0).rotated(wall_rotation)
	wall.position = position + disposition
	wall.rotation = wall_rotation
	
	var a = position
	var b = wall.position
	var p = player.position
	
	var s = sign((b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x))
	if s == -1:
		wall.rotation += PI
	else:
		wall.play_reverse_animation = true
	get_parent().add_child(wall)

func set_wall_rotation(rotation):
	wall_rotation = rotation

func set_player(player):
	self.player = player