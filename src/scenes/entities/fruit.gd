extends KinematicBody2D

class_name Fruit

var id:=0
var id_bdd
var display_name = ''

func init(pos,new_id,new_id_bdd):
	position = pos
	id = new_id
	id_bdd = new_id_bdd
	var stat = Bdd.fruits[id_bdd]
	display_name = stat.name
	$sprite.texture = load(stat.sprite)
