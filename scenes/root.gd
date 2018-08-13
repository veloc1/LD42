extends Node2D

const shake_disposition = 30

onready var player = $player
onready var camera = $Camera2D
onready var tween = $Tween

func _ready():
	player.connect("change_gravity", self, "on_player_changes_gravity")
	player.connect("box_fall_on_player", self, "on_box_fall_on_player")
	
func _process(delta):
	camera.position = player.position
	
	screen_shake()
	
	update()

func _draw():
	var center = get_viewport_rect().size / 2
	#draw_line(center, center + get_gravity_vector() * get_gravity_scale(), Color(0, 0, 1))
	#draw_circle(center + get_gravity_vector() * get_gravity_scale(), 3, Color(0, 1, 1))


func get_gravity_vector():
	return Physics2DServer.area_get_param(get_world_2d().space, Physics2DServer.AREA_PARAM_GRAVITY_VECTOR)

func get_gravity_scale():
	return Physics2DServer.area_get_param(get_world_2d().space, Physics2DServer.AREA_PARAM_GRAVITY)

func on_player_changes_gravity():
	tween.stop_all()
	var start = camera.rotation
	var end = player.rotation
	var diff = end - start
	if abs(diff) > PI:
		start += sign(diff) * PI * 2
	tween.interpolate_property(camera, "rotation", start, end, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()

func start_screen_shake():
	if camera.get_node("Timer").time_left == 0:
		camera.get_node("Timer").start()

func screen_shake():
	if camera.get_node("Timer").time_left == 0:
		return
	camera.position += Vector2(rand_range(-shake_disposition, shake_disposition),rand_range(-shake_disposition, shake_disposition))

func on_box_fall_on_player():
	start_screen_shake()

func _on_button_on_button_pressed():
	pass # replace with function body

func on_button_pressed():
	$small_wall.queue_free()
	$small_wall2.queue_free()
	$small_wall3.queue_free()
