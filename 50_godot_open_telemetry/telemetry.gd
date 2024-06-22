extends Node3D

var otel: OpenTelemetry = OpenTelemetry.new()
var root_span_id: String

func _ready() -> void:
	LogManager.register_log_capture_buffered(_log_callback)
	var version_info = Engine.get_version_info()
	var error: String = otel.init_tracer_provider(ProjectSettings.get_setting("application/config/name"), "collector.aspecto.io", version_info, "9f6c7761-67c3-47b5-82b5-34671de23229")
	if not error.is_empty():
		print("Error initializing OpenTelemetry: ", error)
	root_span_id = otel.start_span("client")
	
func _log_callback(log_message: Dictionary) -> void:
	var attrs: Dictionary = {
		"log.severity": log_message["type"],
		"log.message": log_message["text"]
	}
	
	if log_message.has("file"):
		attrs["log.file"] = log_message["file"]
	if log_message.has("line"):
		attrs["log.line"] = log_message["line"]
	if log_message.has("function"):
		attrs["log.function"] = log_message["function"]
	if log_message.has("rationale"):
		attrs["log.rationale"] = log_message["rationale"]

	var span_id = otel.start_span_with_parent("log", root_span_id)
	otel.set_attributes(span_id, attrs)
	if log_message["type"] == "error":
		otel.record_error(span_id, str(get_stack()))
	else:
		otel.add_event(span_id, log_message["type"])
	otel.end_span(span_id)

func _exit_tree() -> void:
	LogManager.unregister_log_capture_buffered(self._log_callback)
	otel.end_span(root_span_id)
