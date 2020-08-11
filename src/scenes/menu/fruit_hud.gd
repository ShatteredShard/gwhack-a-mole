extends HBoxContainer

var count := 0 setget set_count

var actual_count :=0

var id_bdd := 0

var instant = false

func init(new_id_bdd,new_count):
	id_bdd = new_id_bdd
	var stat = Bdd.fruits[new_id_bdd]
	$texture_rect.texture = load(stat.sprite)
	set_count(new_count)

func set_count(new_count):
	count = new_count

func _ready():
	if instant:
		$label.text=str(count)
	else:
		$tween.interpolate_property(self,"actual_count",0,count,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		$tween.start()


func _on_tween_tween_step(object, key, elapsed, value):
	$label.text=str(actual_count)
