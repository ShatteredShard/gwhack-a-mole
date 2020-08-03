extends HBoxContainer

var count := 0 setget set_count

var id_bdd := 0

func init(new_id_bdd,new_count):
	id_bdd = new_id_bdd
	var stat = Bdd.fruits[new_id_bdd]
	$texture_rect.texture = load(stat.sprite)
	set_count(new_count)

func set_count(new_count):
	count = new_count
	$label.text = str(count)
