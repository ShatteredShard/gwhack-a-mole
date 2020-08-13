extends Control



onready var _fetch = GotmLobbyFetch.new()

onready var button = $v_box_container/h_box_container/control/button

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	refresh_lobbies()

func _on_button_pressed():
	button.disabled = true
	var lobbies:Array = yield(_fetch.first(1), "completed")
	var yes=false
	if lobbies.size()>0:
		var lobby = lobbies.pop_front()
		if !lobby.hidden:
			var success = yield(lobby.join(), "completed")
			if success:
				get_tree().change_scene("res://scenes/game.tscn")
				yes = true
			else:
				button.disabled = false
	if !yes:
		Gotm.host_lobby(false)
		Gotm.lobby.hidden = false
		Gotm.lobby.name = str(randi())
		get_tree().change_scene("res://scenes/game.tscn")
		
		

func refresh_lobbies():
	var lobbies = yield(_fetch.first(5), "completed")
	$label.text = "Active lobbies : "+str(lobbies.size())

func _on_timer_timeout():
	refresh_lobbies()
