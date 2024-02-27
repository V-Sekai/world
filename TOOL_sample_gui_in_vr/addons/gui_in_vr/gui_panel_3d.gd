extends StaticBody3D

@onready var viewport = $SubViewport

func _ready():
	var aspect = viewport.size.x * 1.0/viewport.size.y
	
	$CollisionShape3D.shape.size.x = aspect
	$Quad.scale.x = aspect
