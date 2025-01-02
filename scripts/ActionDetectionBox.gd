extends Area2D
class_name ActionDetectionBox

func _init():
	collision_layer = 0
	collision_mask = 4
	
func _ready():
	connect("area_entered", _on_area_entered)
	
func _on_area_entered(action_box: ActionBox):
	if ( action_box == null ):
		return
	
	if ( owner.has_method("lift_curse") ):
		owner.lift_curse()
