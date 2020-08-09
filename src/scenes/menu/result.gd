extends MarginContainer


onready var ally = $v_box_container/h_box_container/ally
onready var enemy = $v_box_container/h_box_container/enemy

var self_id:int
var players_fruits:Dictionary

func init(new_self_id,new_players_fruits):
	self_id = new_self_id
	players_fruits = new_players_fruits

func _ready():
	ally.display(players_fruits[self_id])
	var enemey_key = 1
	var keys = players_fruits.keys()
	if keys.size()>1:
		for k in keys:
			if k!=self_id:
				enemey_key = k
		enemy.display(players_fruits[enemey_key])
	else:
		enemy.queue_free()

func _on_button_pressed():
	get_tree().change_scene("res://scenes/menu/menu.tscn")
