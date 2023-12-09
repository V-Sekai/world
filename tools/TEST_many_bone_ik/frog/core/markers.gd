extends Marker3D

var lasso_point : LassoPoint 

func _enter_tree():
	lasso_point = LassoPoint.new()
