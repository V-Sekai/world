extends Node3D

var otel: OpenTelemetry = OpenTelemetry.new()
var root_span_id: String

func _ready() -> void:
	LogManager.register_log_capture_buffered(self._log_callback)
	var version_info = Engine.get_version_info()
	var error = otel.init_tracer_provider("godot_engine_client", "localhost:4317", version_info)
	print(error)
	root_span_id = otel.start_span("client")
	
func _log_callback(log_message: Dictionary) -> void:
	var attrs: Dictionary = {
		"log.severity": log_message["type"],
		"log.message": log_message["text"]
	}
	var span_id = otel.start_span_with_parent("log", root_span_id)
	otel.set_attributes(span_id, attrs)
	if log_message["type"] == "error":
		otel.record_error(span_id, str(get_stack()))
	else:
		otel.add_event(span_id, log_message["type"])

func _exit_tree() -> void:
	LogManager.unregister_log_capture_buffered(self._log_callback)
	otel.end_span(root_span_id)
