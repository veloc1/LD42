extends StaticBody2D

var play_reverse_animation

func _ready():
	if play_reverse_animation:
		$AnimationPlayer.play("show-wall-module-reverse")
	else:
		$AnimationPlayer.play("show-wall-module")