extends Node


# Declare member variables here. Examples:
const PORT = 8070

const HAMMER_PACKED = preload("res://scenes/entities/hammer.tscn")
const FRUIT_PACKED = preload("res://scenes/entities/fruit.tscn")
const FRUIT_HUD_PACKED = preload("res://scenes/menu/fruit_hud.tscn")

enum STATE{
	waiting,
	starting
}

var state = STATE.waiting

var players_id := []

var players_name := {}

var players_fruits := {}

var fruit_count = 0

func _ready():
	randomize()
	if Gotm.lobby !=null:
		if Gotm.lobby.is_host():
			var peer = NetworkedMultiplayerENet.new()
			peer.create_server(PORT)
			get_tree().set_network_peer(peer)
			$waiting.show()
			players_id.push_back(get_tree().get_network_unique_id())
			get_tree().connect("network_peer_connected", self, "_player_connected")
			get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		else:
			var peer = NetworkedMultiplayerENet.new()
			peer.create_client(Gotm.lobby.host.address, PORT)
			get_tree().set_network_peer(peer)
		get_tree().connect("server_disconnected", self, "_server_disconnected")
	else:
		get_tree().change_scene("res://scenes/menu/menu.tscn")


func _player_connected(id):
	print(id)
	if Gotm.lobby.is_host():
		if !Gotm.lobby.hidden:
			Gotm.lobby.hidden = true
			players_id.push_back(id)
			rpc("_start_game",players_id)
		else:
			pass
func _player_disconnected(id):
	for obj in get_children():
		if obj is Hammer:
			if obj.id == id:
				queue_free()

remotesync func _start_game(new_players_id=players_id):
	$timer_end.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	state = STATE.starting
	$waiting.hide()
	if Gotm.lobby !=null:
		if Gotm.lobby.is_host():
			$timer_spawn.start()
			for id in players_id:
				players_fruits[id]={}
				print(Gotm.user.display_name)
				var name = Gotm.user.display_name if Gotm.user.display_name!='' else 'Guest'
				rpc("create_hammer",id,name if get_tree().get_network_unique_id()==id else 'Guest2')
			rpc("players_fruits",players_fruits)
		else:
			players_id=new_players_id

remotesync func players_fruits(new_players_fruits):
	players_fruits=new_players_fruits
	print(players_fruits)
	print(players_id)
	for id in players_id:
		if players_fruits.has(id):
			var count=0
			for id_bdd in players_fruits[id]:
				var node=$hud/cont_enemy
				if id==get_tree().get_network_unique_id():
					node=$hud/cont_ally
					count += players_fruits[id][id_bdd]*Bdd.fruits[id_bdd].points
#				if node.has_node(str(id_bdd)):
#					node.get_node(str(id_bdd)).set_count(players_fruits[id][id_bdd])
#				else:
#					var tmp=FRUIT_HUD_PACKED.instance()
#					tmp.init(id_bdd,players_fruits[id][id_bdd])
#					tmp.name = str(id_bdd)
#					node.add_child(tmp)
			if id==get_tree().get_network_unique_id():
				$hud/points.text = str(count)
remotesync func create_hammer(id,n):
	var hammer = HAMMER_PACKED.instance()
	hammer.position = Vector2(512/4+512/2*id,288/2)
	hammer.id = id
	
	if id==get_tree().get_network_unique_id():
		if Gotm.lobby !=null:
			if Gotm.lobby.is_host():
				hammer.is_host=true
			elif Gotm.user.display_name!='':
				n=Gotm.user.display_name
				rpc_id(1,"set_player_name",id,Gotm.user.display_name)
				
		$hud/pseudo.text = n
	hammer.set_network_master(id)
	add_child(hammer)
	hammer.set_name(n)
	
master func set_player_name(id, name):
	for obj in get_children():
		if obj is Hammer:
			if obj.id == id:
				obj.set_name(name)

remotesync func pop_fruit(pos,id,id_bdd):
	var fruit = FRUIT_PACKED.instance()
	fruit.init(pos,id,id_bdd)
	$map/tile_wall.add_child(fruit)

func _on_btn_back_pressed():
	if Gotm.lobby !=null:
		Gotm.lobby.leave()
		var peer = NetworkedMultiplayerENet.new()
		peer.close_connection()
		get_tree().change_scene("res://scenes/menu/menu.tscn")

func _server_disconnected():
	if Gotm.lobby !=null:
		Gotm.lobby.leave()
	get_tree().change_scene("res://scenes/menu/menu.tscn")


func _on_btn_alone_pressed():
	_start_game()



func _on_timer_spawn_timeout():
	if Gotm.lobby!=null:
		if Gotm.lobby.is_host() and state==STATE.starting:
			var pos=Vector2(randi()%512,randi()%288)
			pos=$map/navigation_2d.get_closest_point(pos)
			var id=randi()%11
			rpc("pop_fruit",pos,fruit_count,id)
			fruit_count +=1
	$timer_spawn.start((randi()%5+2)/(fruit_count+1))

master func hit_fruit(id_player,id_fruit):
	print("like")
	for obj in $map/tile_wall.get_children():
		if obj is Fruit:
			if obj.id == id_fruit:
				obj.queue_free()
				if players_fruits[id_player].has(obj.id_bdd):
					players_fruits[id_player][obj.id_bdd] += 1
				else:
					players_fruits[id_player][obj.id_bdd] = 1
				rpc("players_fruits",players_fruits)
				rpc("destroy_fruit",id_fruit)

remote func destroy_fruit(id):
	for obj in $map/tile_wall.get_children():
		if obj is Fruit:
			if obj.id == id:
				obj.queue_free()

func _process(delta):
	if state == STATE.waiting:
		if $timer_alone.time_left>0:
			$waiting/v_box_container/h_box_container/btn_alone.text=str(ceil($timer_alone.time_left))
		else:
			$waiting/v_box_container/h_box_container/btn_alone.text="Play alone"
			$waiting/v_box_container/h_box_container/btn_alone.disabled = false
	if state == STATE.starting:
		$hud/label_timer.text = str(ceil($timer_end.time_left))+" s"


func _on_timer_end_timeout():
	pass # Replace with function body.
