extends Node3D


func _on_timer_timeout() -> void:
	print("_process")
	Telemetry.otel.add_event(Telemetry.root_span_id, "_process")
