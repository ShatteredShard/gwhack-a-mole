extends Area2D

var fruits_under:Array = []

var id := 0

var display_name = 'b'

var is_host:=false

func _ready():
	$label.text=display_name
	$sprite.material=$sprite.material.duplicate()
	if is_network_master():
		$sprite.material.set_shader_param("color_replace",Color("#7278C2"))
	else:
		$sprite.material.set_shader_param("color_replace",Color("#EA3131"))

func _input(event):
	if !$animation_player.is_playing() and is_network_master():
		if event is InputEventMouseButton and event.button_index==1:
			if event.pressed:
				$animation_player.play("hit")
				rpc("anim_hit")

func _physics_process(delta):
	if is_network_master():
		var tmp=get_global_mouse_position()
		position.x = int(tmp.x)
		position.y = int(tmp.y)
		rpc_unreliable("set_pos", position)

puppet func anim_hit():
	$animation_player.play("hit")

puppet func set_pos(p_pos):
	position = p_pos

func hit():
	if fruits_under.size()>0:
		var tmp=fruits_under.pop_front()
		get_parent().rpc("hit_fruit",id,tmp.id)
		
		if !is_host:
			tmp.queue_free()


func _on_hammer_body_entered(body):
	if body is Fruit:
		if fruits_under.find(body)==-1:
			fruits_under.push_front(body)


func _on_hammer_body_exited(body):
	if body is Fruit:
		var tmp=fruits_under.find(body)
		if tmp!=-1:
			fruits_under.remove(tmp)
