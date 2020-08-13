extends Area2D

class_name Hammer

const IMPACT_PACKED = preload("res://scenes/fx/impact.tscn")

var fruits_under:Array = []

var selected_fruit:Fruit

var id := 0

var display_name = 'b'

var is_host:=false

func _ready():
	
	$sprite.material=$sprite.material.duplicate()
	if !is_network_master():
		
		$label.set("custom_colors/font_color", Color("#EA3131"))
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


func set_name(new_name):
	display_name = new_name
	$label.text=display_name

puppet func anim_hit():
	$animation_player.play("hit")

puppet func set_pos(p_pos):
	position = p_pos

func hit():
	var impact = IMPACT_PACKED.instance()
	if selected_fruit:
		get_parent().rpc("hit_fruit",id,selected_fruit.id)
		
		if !is_host:
			selected_fruit.queue_free()
		
		fruits_under.remove(fruits_under.find(selected_fruit))
		$smash_fruit.pitch_scale=(randf()*10+15)/10
		$smash_fruit.play()
	else:
		$smash_ground.pitch_scale=(randf()*10+10)/10
		$smash_ground.play()
	impact.position = position
	get_parent().add_child(impact)

func _on_hammer_body_entered(body):
	if body is Fruit:
		if fruits_under.find(body)==-1:
			fruits_under.push_front(body)


func _on_hammer_body_exited(body):
	if body is Fruit:
		var tmp=fruits_under.find(body)
		if tmp!=-1:
			body.select(false)
			fruits_under.remove(tmp)

func _process(delta):
	if fruits_under.size()>0:
		selected_fruit = fruits_under[0]
		for k in fruits_under.size():
			var fruit=fruits_under[k]
			fruit.select(false)
			if position.distance_to(fruit.position)<position.distance_to(selected_fruit.position):
				selected_fruit=fruit
		selected_fruit.select()
	else:
		selected_fruit=null
