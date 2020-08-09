extends Control

const FRUIT_HUD_PACKED = preload("res://scenes/menu/fruit_hud.tscn")
onready var cont = $v_box_container/panel/v_box_container/grid_container

var player_fruits:Dictionary

func display(new_player_fruits):
	player_fruits = new_player_fruits
	for id_bdd in player_fruits:
		var tmp=FRUIT_HUD_PACKED.instance()
		tmp.init(id_bdd,player_fruits[id_bdd])
		tmp.name = str(id_bdd)
		cont.add_child(tmp)


func _on_timer_timeout():
	pass # Replace with function body.
