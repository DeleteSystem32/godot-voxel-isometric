extends Node2D

func _process(delta):
	$RotatableSprite.look_towards(get_global_mouse_position())