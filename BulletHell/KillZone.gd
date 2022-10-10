extends Node2D

func _on_kill_zone_body_entered(body):
	body.queue_free()
