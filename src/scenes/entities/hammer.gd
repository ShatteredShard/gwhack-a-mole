extends Area2D

var fruit_under:Fruit = null

var id := 0

var is_host:=false

func _input(event):
	if !$animation_player.is_playing() and is_network_master():
		if event is InputEventMouseButton:
			if event.pressed:
				$animation_player.play("hit")
				rpc("anim_hit")

func _physics_process(delta):
	if is_network_master():
		position = get_global_mouse_position()
		rpc_unreliable("set_pos", position)

puppet func anim_hit():
	$animation_player.play("hit")

puppet func set_pos(p_pos):
	position = p_pos

func hit():
	if fruit_under != null:
		
		get_parent().rpc("hit_fruit",id,fruit_under.id)
		
		if !is_host:
			fruit_under.queue_free()
		fruit_under=null
		


func _on_hammer_body_entered(body):
	if body is Fruit:
		fruit_under = body


func _on_hammer_body_exited(body):
	if body is Fruit:
		fruit_under = null
