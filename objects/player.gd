extends KinematicBody2D

signal change_gravity
signal box_fall_on_player

const V = 50
const Vjump = 520
const Vlim = 200

var velocity = Vector2()
var is_jumping = false
var tangent = Vector2()

var is_facing_right = true

onready var spawner = $spawner
onready var animation_player = $AnimationPlayer
onready var sprite = $Sprite
onready var dust = $dust_particles
onready var spawn_particles = $spawner/spawn_particles

var Box = preload("res://objects/box.tscn") 
var WallCreator = preload("res://objects/wall_creator.tscn") 

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		drop_wall_creator()
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		drop_box()
	
	var r = Vector2().angle_to_point(get_local_mouse_position())
	
	is_facing_right = abs(r) > PI / 2
	
	if is_facing_right and spawner.position.x < 0:
		spawner.position.x = -spawner.position.x
	elif not is_facing_right and spawner.position.x > 0:
		spawner.position.x = -spawner.position.x
	
	update()


func _physics_process(delta):
	#var gravity = get_gravity_vector() * get_gravity_scale() * delta
	var gravity = Vector2(0, 1) * get_gravity_scale() / 4
	velocity += gravity
	
	var emit_dust = false
	if is_on_floor():
		velocity.x = 0
		velocity.y = 0
		is_jumping = false
		emit_dust = true
	
	if Input.is_action_pressed("ui_left"):
		velocity -= gravity.tangent() * V
		sprite.flip_h = true
		
		if animation_player.current_animation != "run":
			animation_player.play("run")
	elif Input.is_action_pressed("ui_right"):
		velocity += gravity.tangent() * V
		sprite.flip_h = false
		
		if animation_player.current_animation != "run":
			animation_player.play("run")
	else:
		emit_dust = false
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		
	if Input.is_action_pressed("ui_up") and not is_jumping:
		velocity += Vector2(0, -1) * Vjump
		is_jumping = true
	
	#velocity = velocity.clamped(Vlim)
	#velocity = velocity.normalized() * Vlim
	velocity.x = clamp(velocity.x, -Vlim, Vlim)
	#velocity.y = clamp(velocity.y, -Vlim, Vlim)
	
	move_and_slide(velocity.rotated(get_gravity_vector().angle() - PI / 2), -get_gravity_vector())
	
	var collisions_count = get_slide_count()
	for i in range(collisions_count):
		var collision = get_slide_collision(i)
		if collision.collider.get_collision_layer_bit(1):
			# it's wall
			var vector = Vector2(0, 1)
			vector = vector.rotated(collision.collider.rotation)
			set_gravity_vector(vector)
		if collision.collider.get_collision_layer_bit(2):
			#it's box
			if !collision.collider.is_collided_with_player_recently() and collision.collider.linear_velocity.length() > 20:
				collision.collider.collide_with_player()
				emit_signal("box_fall_on_player")
	
	dust.emitting = emit_dust

func _draw():
	var mouse_position = get_local_mouse_position() 
	draw_line(Vector2(), mouse_position, Color(1, 1, 1))
	
	#var gravity = get_gravity_vector() * get_gravity_scale()
	#gravity = gravity.rotated(-rotation)
	#draw_line(Vector2(), gravity, Color(0, 0, 1))
	#draw_line(Vector2(), gravity.tangent(), Color(0,1,0))

func drop_wall_creator():
	if $shoot_timer.time_left != 0:
		return
	var creator = WallCreator.instance()
	
	var rotation = position.angle_to_point(get_global_mouse_position())
	
	creator.set_wall_rotation(rotation)
	creator.set_player(self)
	
	drop_item(creator)

func drop_box():
	drop_item(Box.instance())

func drop_item(item):
	# todo extract to spawner object
	if $shoot_timer.time_left != 0:
		return
	$shoot_timer.start()
	
	spawn_particles.restart()
	
	$sound_drop.play()
	
	var rotation = position.angle_to_point(get_global_mouse_position())
	var force_magnifier = (position - get_global_mouse_position()).length() / 50
	force_magnifier = clamp(force_magnifier, -30, 30)
	
	var force = Vector2()
	# todo flip when mouse moving
	if abs(rotation) > PI / 2:
		force = Vector2(get_size().x * 1.2, 0).rotated(rotation + PI)
	else:
		force =  Vector2(-get_size().x * 1.2, 0).rotated(rotation)
		
	item.position = $spawner.global_position
	get_parent().add_child(item)
	item.apply_impulse(Vector2(), force * force_magnifier)

func get_size():
	var x = $CollisionShape2D.shape.radius * 2
	var y = $CollisionShape2D.shape.height + x
	return Vector2(x, y)

func set_gravity_vector(vector):
	if get_gravity_vector() == vector:
		return
	var angle = Vector2().angle_to_point(vector)
	# TODO interpolate rotation
	rotation = angle + PI / 2
	
	dust.process_material.gravity = Vector3(vector.x, vector.y, 0) * get_gravity_scale() / -3
	
	emit_signal("change_gravity")
	return Physics2DServer.area_set_param(get_world_2d().space, Physics2DServer.AREA_PARAM_GRAVITY_VECTOR, vector)

func get_gravity_vector():
	return Physics2DServer.area_get_param(get_world_2d().space, Physics2DServer.AREA_PARAM_GRAVITY_VECTOR)

func get_gravity_scale():
	return Physics2DServer.area_get_param(get_world_2d().space, Physics2DServer.AREA_PARAM_GRAVITY)