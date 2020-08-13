extends MarginContainer


onready var ally = $v_box_container/h_box_container/ally
onready var enemy = $v_box_container/h_box_container/enemy

var self_id:int
var players_fruits:Dictionary
var players_name:Dictionary

var finish = false

var score_ally = -1
var score_enemy = -1

func init(new_self_id,new_players_fruits,new_players_name):
	self_id = new_self_id
	players_fruits = new_players_fruits
	players_name = new_players_name
func _ready():
	ally.display(players_fruits[self_id],players_name[self_id])
	var enemey_key = 1
	var keys = players_fruits.keys()
	if keys.size()>1:
		for k in keys:
			if k!=self_id:
				enemey_key = k
		enemy.display(players_fruits[enemey_key],players_name[enemey_key],true)
	else:
		ally.full_size()
		enemy.hide()
		score_enemy = 0

func _on_button_pressed():
	$audio_stream_player.play()
	if finish:
		get_tree().change_scene("res://scenes/menu/menu.tscn")
	else:
		ally.rush()
		enemy.rush()


func _on_result_gui_input(event):
	if event is InputEventMouseButton:
		ally.rush()
		enemy.rush()


func _on_ally_finished(score):
	score_ally = score
	if score_enemy != -1:
		finish = true
		$v_box_container/button.text='Return to menu'
		if score_ally>score_enemy:
			ally.win()


func _on_enemy_finished(score):
	score_enemy = score
	if score_ally != -1:
		finish = true
		$v_box_container/button.text='Return to menu'
		if score_ally<score_enemy:
			enemy.win()
			$loose.play()
