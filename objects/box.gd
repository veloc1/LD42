extends RigidBody2D

func _on_box_body_entered(body):
	var should_sound = false
	if body is StaticBody2D:
		should_sound = linear_velocity.length() > 10
	
	if body is RigidBody2D:
		should_sound = linear_velocity.length() + body.linear_velocity.length() > 30
	
	if should_sound:
		$AudioStreamPlayer2D.play()

func is_collided_with_player_recently():
	return $Timer.time_left != 0

func collide_with_player():
	$Timer.start()