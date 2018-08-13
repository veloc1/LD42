extends Node2D

export (Color) var color = Color(0.3, 0.3, 1)

var parent_shape

func _ready():
	parent_shape = $"../".shape

func _process(delta):
	update()

func _draw():
	if parent_shape is RectangleShape2D:
		var rect = Rect2(-parent_shape.extents.x, -parent_shape.extents.y, parent_shape.extents.x * 2, parent_shape.extents.y * 2)
		draw_rect(rect, color)
	elif parent_shape is CircleShape2D:
		draw_circle(Vector2(0, 0), parent_shape.radius, color)