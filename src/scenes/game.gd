extends Node


# Declare member variables here. Examples:
const PORT = 8070

const HAMMER_PACKED = preload("res://scenes/entities/hammer.tscn")
const FRUIT_PACKED = preload("res://scenes/entities/fruit.tscn")

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
		else:
			var peer = NetworkedMultiplayerENet.new()
			peer.create_client(Gotm.lobby.host.address, PORT)
			get_tree().set_network_peer(peer)
			rpc("set_player_name",get_tree().get_network_unique_id(),Gotm.user.display_name)
		get_tree().connect("server_disconnected", self, "_server_disconnected")
	else:
		get_tree().change_scene("res://scenes/menu/menu.tscn")


func _player_connected(id):
	if Gotm.lobby.is_host():
		if !Gotm.lobby.hidden:
			Gotm.lobby.hidden = true
			players_id.push_back(id)
			rpc("_start_game")
		else:
			pass

remotesync func set_player_name(id,name):
	players_name[id]=name
	if id==get_tree().get_network_unique_id():
		$hud/label_host.text=name
	else:
		$hud/label_peer.text=name

remotesync func _start_game():
	rpc("set_player_name",get_tree().get_network_unique_id(),Gotm.user.display_name)
	state = STATE.starting
	$waiting.hide()
	if Gotm.lobby !=null:
		if Gotm.lobby.is_host():
			for id in players_id:
				players_fruits[id]=[]
				rpc("create_hammer",id)
			rpc("players_fruits",players_fruits,players_id)

remotesync func players_fruits(new_players_fruits,new_players_id):
	players_id = new_players_id
	players_fruits=new_players_fruits
#	for id in players_id:
#		if players_fruits.has(id):
#			if id==get_tree().get_network_unique_id():
#				$hud/label_host.text=str(players_fruits[id])
#			else:
#				$hud/label_peer.text=str(players_fruits[id])

remotesync func create_hammer(id):
	var hammer = HAMMER_PACKED.instance()
	hammer.position = Vector2(512/4+512/2*id,288/2)
	hammer.id = id
	if Gotm.lobby !=null:
		if Gotm.lobby.is_host():
			hammer.is_host=true
	hammer.set_network_master(id)
	add_child(hammer)

remotesync func pop_fruit(pos,id):
	var fruit = FRUIT_PACKED.instance()
	fruit.position = pos
	fruit.id = id
	$map/tile_wall.add_child(fruit)

func _on_btn_back_pressed():
	if Gotm.lobby !=null:
		Gotm.lobby.leave()
		var peer = NetworkedMultiplayerENet.new()
		peer.close_connection()
		get_tree().change_scene("res://scenes/menu/menu.tscn")

func _server_disconnected():
	get_tree().change_scene("res://scenes/menu/menu.tscn")


func _on_btn_alone_pressed():
	_start_game()


func _on_timer_timeout():
	print("oui")
	if Gotm.lobby!=null:
		if Gotm.lobby.is_host() and state==STATE.starting:
			var pos=Vector2(randi()%512,randi()%288)
			pos=$map/navigation_2d.get_closest_point(pos)
			rpc("pop_fruit",pos,fruit_count)
			fruit_count +=1
	$timer.start(randi()%5+2)

master func hit_fruit(id_player,id_fruit):
	print("like")
	for obj in $map/tile_wall.get_children():
		if obj is Fruit:
			if obj.id == id_fruit:
				obj.queue_free()
				players_fruits[id_player].push_back(id_fruit)
				rpc("players_fruits",players_fruits,players_id)
				rpc("destroy_fruit",id_fruit)

remote func destroy_fruit(id):
	for obj in $map/tile_wall.get_children():
		if obj is Fruit:
			if obj.id == id:
				obj.queue_free()
