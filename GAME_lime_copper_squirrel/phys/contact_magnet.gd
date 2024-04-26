extends RigidBody3D

func _integrate_forces(_state: PhysicsDirectBodyState3D) -> void:
	for contact in get_colliding_bodies():
		if contact is RigidBody3D:
			#contact.apply_central_impulse(contact.mass * (target_position - global_position))
			#contact.apply_central_force(_state.total_gravity)
			var puuuush = 10 * contact.mass * contact.global_position.direction_to(global_position) * (Vector3.ONE + global_basis.z)
			#print(puuuush)
			contact.apply_central_force(puuuush)
			DD.draw_ray_3d(contact.global_position, puuuush.normalized(), 2, Color.RED)
