extends Node


# Declare member variables here. Examples:
const PORT = 8070
enum STATE{
	waiting,
	starting
}

var state = STATE.waiting

func _ready():
	if Gotm.lobby !=null:
		if Gotm.lobby.is_host():
			var peer = NetworkedMultiplayerENet.new()
			peer.create_server(PORT)
			get_tree().set_network_peer(peer)
			$waiting.show()
			get_tree().connect("network_peer_connected", self, "_player_connected")
		else:
			var peer = NetworkedMultiplayerENet.new()
			peer.create_client(Gotm.lobby.host.address, PORT)
			get_tree().set_network_peer(peer)
		get_tree().connect("server_disconnected", self, "_server_disconnected")
	else:
		get_tree().change_scene("res://scenes/menu/menu.tscn")


func _player_connected(id):
	rpc("_start_game")

func _start_game():
	Gotm.lobby.hidden = true
	state = STATE.starting
	$waiting.hide()

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
