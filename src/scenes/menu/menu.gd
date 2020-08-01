extends Control



onready var _fetch = GotmLobbyFetch.new()

func _ready():
	refresh_lobbies()

func _on_button_pressed():
	$button.disabled = true
	var lobbies:Array = yield(_fetch.first(1), "completed")
	if lobbies.size()>0:
		var lobby = lobbies.pop_front()
		var success = yield(lobby.join(), "completed")
		if success:
			get_tree().change_scene("res://scenes/game.tscn")
		else:
			$button.disabled = false
	else:
		print("bah jvais host")
		Gotm.host_lobby(false)
		Gotm.lobby.hidden = false
		Gotm.lobby.name = "test"
		get_tree().change_scene("res://scenes/game.tscn")
		
		

func refresh_lobbies():
	var lobbies = yield(_fetch.first(5), "completed")
	$label.text = "Active lobbies : "+str(lobbies.size())

func _on_timer_timeout():
	refresh_lobbies()
