extends Node2D


var particle = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$animated_sprite.play("impact")
	if particle:
		$cpu_particles_2d.restart()


func _on_timer_timeout():
	queue_free()
