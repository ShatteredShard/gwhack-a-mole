extends Control

signal finished(score)

const FRUIT_HUD_PACKED = preload("res://scenes/menu/fruit_hud.tscn")
onready var cont = $v_box_container/panel/v_box_container/grid_container
onready var label_name = $v_box_container/panel/v_box_container/label
onready var label_score = $v_box_container/panel/v_box_container/score
var player_fruits:Dictionary

var keys:Array

var score = 0
var display_score = 0

var speed = 0.5

func display(new_player_fruits,new_name,is_enemy):
	player_fruits = new_player_fruits
	keys = player_fruits.keys()
	$timer.start()
	label_name.text=new_name
	if is_enemy:
		label_name.set("custom_colors/font_color", Color("#EA3131"))

func full_size():
	$v_box_container/panel/v_box_container/grid_container.columns = 6

func _on_timer_timeout():
	if keys.size()>0:
		var id_bdd = keys.pop_front()
		var tmp = FRUIT_HUD_PACKED.instance()
		tmp.init(id_bdd,player_fruits[id_bdd])
		tmp.name = str(id_bdd)
		cont.add_child(tmp)
		$timer.start(speed)
		score += player_fruits[id_bdd]*Bdd.fruits[id_bdd].points
		$tween.interpolate_property(self,"display_score",display_score,score,speed,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		$tween.start()
	else:
		emit_signal("finished",score)

func rush():
	$timer.stop()
	$tween.stop_all()
	for id_bdd in keys:
		var tmp = FRUIT_HUD_PACKED.instance()
		tmp.init(id_bdd,player_fruits[id_bdd])
		tmp.name = str(id_bdd)
		tmp.instant = true
		cont.add_child(tmp)
		score += player_fruits[id_bdd]*Bdd.fruits[id_bdd].points
	label_score.text = str(int(score))
	emit_signal("finished",score)

func _on_tween_tween_step(object, key, elapsed, value):
	label_score.text = str(int(display_score))

func win():
	$v_box_container/label.self_modulate.a = 255
