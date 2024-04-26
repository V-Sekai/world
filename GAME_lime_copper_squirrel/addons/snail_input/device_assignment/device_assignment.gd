extends Control

@export var player_present: PackedScene
@export var player_missing: PackedScene

var device_container: VBoxContainer
var device_tweens: Dictionary = {}
var device_icons: Dictionary = {}

var slot_tweens: Dictionary = {}
var slot_placeholders: Dictionary = {}


func _on_player_join_ready_accepted(_device: int, player_index: int):
	print("player %d ready" % (player_index + 1))
	var active_players := SnailInput.get_active_devices()
	var ready_players := SnailInput.get_ready_devices()
	if active_players.size() == ready_players.size() and not active_players.is_empty():
		print("all players ready!")

	var slot := SnailInput.get_player_slot(player_index)
	if slot_tweens.has(slot):
		slot_tweens[slot].kill()
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(slot_placeholders[slot], "modulate:a", 0, 0.2)
	slot_tweens[slot] = t


func _on_player_join_ready_rejected(_device: int, player_index: int):
	print("player %d could not ready" % (player_index + 1))


func _on_player_join_unready(_device: int, player_index: int):
	print("player %d unready" % (player_index + 1))
	var slot := SnailInput.get_player_slot(player_index)
	if slot.devices.is_empty():
		if slot_tweens.has(slot):
			slot_tweens[slot].kill()
		var t := create_tween()
		t.set_ease(Tween.EASE_OUT)
		t.set_trans(Tween.TRANS_CUBIC)
		t.tween_property(slot_placeholders[slot], "modulate:a", 1, 0.2)
		slot_tweens[slot] = t


func _on_player_left(device: int, player_index: int):
	print("player %d left" % (player_index + 1))
	_move(device, device_container.global_position)


func _on_player_join_accepted(device: int):
	print("player using device %d joined" % (device))


func _on_player_join_rejected(device: int):
	print("player using device %d already joined" % (device))


func _on_player_changed_index(device: int, old_player_index: int, new_player_index: int):
	print("{0}: {1} -> {2}".format([device, old_player_index, new_player_index]))
	var placeholder: Control = slot_placeholders[SnailInput.get_player_slot(new_player_index)]
	_move(device, placeholder.global_position)


func _move(device: int, p_global_position: Vector2):
	if device_tweens.has(device):
		device_tweens[device].kill()
	var icon: Control = device_icons[device]
	var t := icon.create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(icon, "global_position:x", p_global_position.x, 0.2)
	t.play()
	device_tweens[device] = t


func _mk_label(p_text: String) -> Label:
	var label := Label.new()
	label.text = p_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.theme = theme
	return label


@onready var focus := SnailInput.get_input_focus()


func _ready() -> void:
	add_child(focus)
	focus.set_high_priority()

	device_container = VBoxContainer.new()
	device_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	device_container.add_child(_mk_label("Inactive"))
	for device in SnailInput.get_all_devices():
		var item := player_present.instantiate()
		if device.index >= 0:
			item.device_type = "Gamepad"
		else:
			item.device_type = "Keyboard"
		item.label = device.name
		device_container.add_child(item)
		device_icons[device.index] = item
	add_child(device_container)

	for i in SnailInput.max_players:
		var pc := VBoxContainer.new()
		pc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pc.add_child(_mk_label("Player %d" % (i + 1)))
		var placeholder := player_missing.instantiate()
		var slot := SnailInput.get_player_slot(i)
		slot_placeholders[slot] = placeholder
		pc.add_child(placeholder)
		add_child(pc)

	SnailInput.player_join_ready_accepted.connect(_on_player_join_ready_accepted)
	SnailInput.player_join_ready_rejected.connect(_on_player_join_ready_rejected)
	SnailInput.player_join_unready.connect(_on_player_join_unready)
	SnailInput.player_left.connect(_on_player_left)
	SnailInput.player_join_accepted.connect(_on_player_join_accepted)
	SnailInput.player_join_rejected.connect(_on_player_join_rejected)
	SnailInput.player_changed_index.connect(_on_player_changed_index)
	SnailInput.player_changed_device.connect(_on_player_changed_device)

	modulate.a = 0
	var t := create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_CUBIC)
	t.tween_property(self, "modulate:a", 1, 0.25)

	# due to timing issue when using new child positions, we have to do this on next update
	await get_tree().process_frame
	var devices := SnailInput.get_all_devices()
	for device in devices:
		if not device.active:
			continue
		_on_player_join_accepted(device.index)
		_on_player_changed_index(device.index, device.want_player_index, device.want_player_index)
		if device.player_index != SnailInput.PLAYER_INVALID:
			_on_player_join_ready_accepted(device.index, device.player_index)


func _on_player_changed_device(_player_index: int, name: String):
	%latest.text = name
	print(name)


func _unhandled_input(event: InputEvent) -> void:
	if not focus.is_focused():
		return

	var device := SnailInput.get_device_for_event(event)
	if not device:
		return

	if event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_DPAD_LEFT:
				SnailInput.device_move(device, -1)
			JOY_BUTTON_DPAD_RIGHT:
				SnailInput.device_move(device, 1)
			JOY_BUTTON_A:
				SnailInput.device_join(device)
			JOY_BUTTON_B:
				SnailInput.device_leave(device)
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT, KEY_A:
				SnailInput.device_move(device, -1)
			KEY_RIGHT, KEY_D:
				SnailInput.device_move(device, 1)
			KEY_ENTER, KEY_Z:
				SnailInput.device_join(device)
			KEY_ESCAPE, KEY_BACKSPACE, KEY_X:
				SnailInput.device_leave(device)
