extends Area2D

signal on_button_pressed

func _on_button_body_entered(body):
	emit_signal("on_button_pressed")
