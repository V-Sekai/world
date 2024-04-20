extends Node

var max_players := 4
var auto_join_primary_player := true
var auto_activate_on_press := true

signal player_join_ready_accepted(device: int, player: int) # ready to go
signal player_join_ready_rejected(device: int, player: int) # can't ready up (slot probably taken)
signal player_join_unready(device: int, player: int) # back up
signal player_left(device: int, player: int) # left game

signal player_join_accepted(device: int) # joined game, not full
signal player_join_rejected(device: int) # tried to join, but it was full
signal player_changed_index(device: int, old_player_index: int, new_player_index: int) # moved target slot
signal player_changed_device(player: int, simple_device_name: String)

const DEVICE_KEYBOARD: int = -1
const PLAYER_INVALID: int = -1

enum InputDeviceType {
	None,
	Keyboard,
	Gamepad_Generic,
	Gamepad_Playstation,
	Gamepad_Xbox
}

## TODO:
# handle device plug/unplugging
# handle per-player current input device type for input prompts
# per-device action remapping
# (api bug) fix per-player input focus

# TODO: save this list?
var _ignore_guids := [] #"03000000d11800000094000000010000" # stadia controller (test)

func ignore_guid(guid: String):
	_ignore_guids.append(guid)

func ignore_device(device_index: int):
	if device_index < 0:
		return
	_ignore_guids.append(Input.get_joy_guid(device_index))

var _focused: Dictionary = {}

class InputFocus extends Node:
	var player_index: int

	const GLOBAL_FOCUS_ID := -1

	func get_player_input() -> PlayerInput: # just shorthand
		return SnailInput.get_player_input(self)

	func _ready() -> void:
		# we don't want pause menu and such to break these, keep it running if it's in the tree at all
		process_mode = Node.PROCESS_MODE_ALWAYS

	func _init(p_player_index: int = GLOBAL_FOCUS_ID) -> void:
		player_index = p_player_index

	func _enter_tree() -> void:
		SnailInput._focused[player_index] = self

	func _exit_tree() -> void:
		if SnailInput._focused.has(player_index) and SnailInput._focused[player_index] == self:
			SnailInput._focused.erase(player_index)

	func is_focused() -> bool:
		# check global focus first, if we're not index -1 but something else is, we're not focused
		if player_index != GLOBAL_FOCUS_ID and SnailInput._focused.has(GLOBAL_FOCUS_ID):
			return false
		if not SnailInput._focused.has(player_index):
			return false
		return SnailInput._focused[player_index] == self

	## set this node's process priority such that it'll always take focus.
	## if this is set on multiple nodes, the last one in the tree will still win.
	func set_high_priority():
		process_priority = -0xFFFFFFFF

	func _process(_delta: float) -> void:
		SnailInput._focused[player_index] = self # last one in the scene tree wins

class InputDevice:
	var index: int
	var name: String
	var want_player_index: int = 0
	var player_index: int = PLAYER_INVALID
	var active := false

	func get_simplified_type() -> InputDeviceType:
		match name:
			"XInput Gamepad", "Xbox Series Controller", "Xbox 360 Controller", "Xbox One Controller": return InputDeviceType.Gamepad_Xbox
			"Sony DualSense", "PS5 Controller", "PS4 Controller": return InputDeviceType.Gamepad_Playstation
			"Keyboard": return InputDeviceType.Keyboard
			_: return InputDeviceType.Gamepad_Generic

	func change_index(p_new_index: int, p_limit: int, p_relative := false):
		if p_relative:
			want_player_index += p_new_index
		else:
			want_player_index = p_new_index
		while want_player_index < 0:
			want_player_index += p_limit
		want_player_index %= p_limit

	func check_event(p_event: InputEvent) -> bool:
		if p_event is InputEventJoypadButton or p_event is InputEventJoypadMotion:
			return p_event.device == index
		return index < 0

	func _init(p_index: int):
		index = p_index
		if p_index >= 0:
			name = Input.get_joy_name(p_index)
		else:
			name = "Keyboard"

class PlayerSlot:
	var primary_player := false
	var ready := false
	var devices: Array[InputDevice] = []
	var last_device: InputDevice

	func get_most_recent_device_hint() -> String:
		if not last_device:
			return "keyboard"

		match last_device.get_simplified_type():
			InputDeviceType.Gamepad_Generic: return "generic"
			InputDeviceType.Gamepad_Playstation: return "playstation"
			InputDeviceType.Gamepad_Xbox: return "xbox"
			_: return "keyboard" # default to keyboard if we don't know better

	func remove_device(p_device: InputDevice):
		if devices.has(p_device):
			devices.erase(p_device)

	func add_device(p_device: InputDevice):
		if not devices.has(p_device):
			devices.append(p_device)

	func has_device(p_device: InputDevice):
		return devices.has(p_device)

class PlayerInput:
	var _devices: Array[InputDevice] = []
	var _actions: Array = []
	var _prefix: String
	const _fixed_prefix: String = "_player_"

	func _init(p_slot_index: int) -> void:
		_prefix = "%s%d_" % [_fixed_prefix, p_slot_index]

	func has_keyboard() -> bool:
		for device in _devices:
			if device.index < 0:
				return true
		return false

	func _generate_device_actions(p_base_action: String, p_new_action: String):
		for event in InputMap.action_get_events(p_base_action):
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				if not InputMap.has_action(p_new_action):
					InputMap.add_action(p_new_action, InputMap.action_get_deadzone(p_base_action))
				for device in _devices:
					if device.index < 0:
						continue # skip keyboard
					var device_event := event.duplicate()
					device_event.device = device.index
					InputMap.action_add_event(p_new_action, device_event)
			elif event is InputEventKey or event is InputEventMouse:
				if not InputMap.has_action(p_new_action):
					InputMap.add_action(p_new_action, InputMap.action_get_deadzone(p_base_action))
				for device in _devices:
					if device.index >= 0:
						continue # skip gamepads
					InputMap.action_add_event(p_new_action, event.duplicate())

	func update_devices(p_devices: Array[InputDevice]):
		for action in _actions:
			if InputMap.has_action(action):
				InputMap.erase_action(action)
		_actions.clear()
		_devices = p_devices
		for base_action in InputMap.get_actions():
			if not base_action.begins_with(_fixed_prefix):
				_actions.append(_prefix + base_action)
				_generate_device_actions(base_action, _actions.back())

	func get_action_strength(action: String) -> float:
		return Input.get_action_strength(get_mapped_action(action))

	func get_axis(negative_action: StringName, positive_action: StringName) -> float:
		return Input.get_axis(get_mapped_action(negative_action), get_mapped_action(positive_action))

	func get_vector(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = -1.0) -> Vector2:
		return Input.get_vector(
			get_mapped_action(negative_x),
			get_mapped_action(positive_x),
			get_mapped_action(negative_y),
			get_mapped_action(positive_y),
			deadzone
		)

	func is_anything_just_pressed() -> bool:
		for action in _actions:
			if InputMap.has_action(action) and Input.is_action_just_pressed(action):
				return true
		return false

	func is_anything_pressed() -> bool:
		for action in _actions:
			if InputMap.has_action(action) and Input.is_action_pressed(action):
				return true
		return false

	func is_action_just_pressed(action: StringName, exact_match: bool = false) -> bool:
		return Input.is_action_just_pressed(get_mapped_action(action), exact_match)

	func is_action_just_released(action: StringName, exact_match: bool = false) -> bool:
		return Input.is_action_just_released(get_mapped_action(action), exact_match)

	func is_action_pressed(action: StringName, exact_match: bool = false) -> bool:
		return Input.is_action_pressed(get_mapped_action(action), exact_match)

	func get_mapped_action(action: String) -> String:
		return _prefix + action

var _player_slots: Array[PlayerSlot] = []
var _input_devices: Array[InputDevice] = []
var _last_seen_devices: Array[int] = []
var _player_inputs: Array[PlayerInput] = []

func _rescan_devices():
	var connected: Array[int] = Input.get_connected_joypads()
	var changed := connected.size() != _last_seen_devices.size()
	if not changed:
		for device in connected:
			if not _last_seen_devices.has(device):
				changed = true
				break

	if changed:
		print("devices changed ", connected)

	_last_seen_devices = connected

	_input_devices.clear()
	_input_devices.append(InputDevice.new(DEVICE_KEYBOARD))
	for i in connected:
		var device_guid := Input.get_joy_guid(i)
		if _ignore_guids.has(device_guid):
			print("input device %d (%s, guid: %s) ignored by user configuration" % [i, Input.get_joy_name(i), device_guid])
			continue

		if Input.is_joy_known(i):
			_input_devices.append(InputDevice.new(i))

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_rescan_devices()

	for i in max_players:
		_player_slots.append(PlayerSlot.new())
		_player_inputs.append(PlayerInput.new(i))
		_player_inputs.back().update_devices(get_player_devices(i))
	_player_inputs.append(PlayerInput.new(_player_inputs.size()))
	_player_inputs.back().update_devices([] as Array[InputDevice])

func get_primary_player() -> int:
	var players := get_ready_players()
	for i in players.size():
		if players[i].primary_player:
			return i
	if not players.is_empty():
		players[0].primary_player = true
	return 0

func get_player_slot(index: int) -> PlayerSlot:
	return _player_slots[index % _player_slots.size()]

func get_player_devices(index: int) -> Array[InputDevice]:
	return get_player_slot(index).devices

func get_all_devices() -> Array[InputDevice]:
	var connected := Input.get_connected_joypads() # don't include since-disconnected devices
	return _input_devices.filter(func(dev): return dev.index < 0 or connected.has(dev.index))

func get_active_devices() -> Array[InputDevice]:
	return _input_devices.filter(func(dev): return dev.active)

func get_ready_devices() -> Array[InputDevice]:
	return _input_devices.filter(func(dev): return dev.active and dev.player_index >= 0)

func get_ready_players() -> Array[PlayerSlot]:
	return _player_slots.filter(func(slot): return slot.ready)

func get_player_input(focus: InputFocus, player_index := -1) -> PlayerInput:
	# input focus is not inside scene tree, focus will always return false.
	# you really don't want that.
	assert(focus.is_inside_tree())

	var null_device := _player_inputs[max_players]
	if focus.is_focused():
		var want_index := focus.player_index
		if player_index >= 0 and focus.player_index == InputFocus.GLOBAL_FOCUS_ID:
			want_index = player_index
		elif player_index != InputFocus.GLOBAL_FOCUS_ID and focus.player_index != player_index: # invalid request, no focus
			return null_device
		elif player_index == -1 and focus.player_index == InputFocus.GLOBAL_FOCUS_ID:
			want_index = get_primary_player()
		return _player_inputs[want_index % max_players]
	return null_device

func get_player_input_always(index: int) -> PlayerInput:
	return _player_inputs[index % max_players]

func get_primary_input(focus: InputFocus) -> PlayerInput:
	if focus.player_index == get_primary_player() || focus.player_index == InputFocus.GLOBAL_FOCUS_ID:
		return get_player_input(focus)
	return _player_inputs[max_players] # null device

func get_primary_input_always() -> PlayerInput:
	return get_player_input_always(get_primary_player())

func get_input_focus(parent: Node = null, player_index := -1) -> InputFocus:
	var focus := InputFocus.new(player_index)
	if parent:
		parent.add_child(focus)
	return focus

func device_move(p_device: InputDevice, p_direction: int):
	var start_slot := get_player_slot(p_device.want_player_index)
	if p_device.active and not start_slot.has_device(p_device):
		var old_index := p_device.want_player_index
		if p_direction > 0:
			p_device.change_index(1, _player_slots.size(), true)
		elif p_direction < 0:
			p_device.change_index(-1, _player_slots.size(), true)
		else:
			return
		player_changed_index.emit(p_device.index, old_index, p_device.want_player_index)
	elif not p_device.active:
		device_join(p_device)

func device_join(p_device: InputDevice):
	var active_devices := get_active_devices()
	var any_slots_available := active_devices.size() < max_players
	if p_device.active: # try to ready up if active
		var slot := get_player_slot(p_device.want_player_index)
		if (slot.ready or p_device.player_index >= 0) and (not auto_join_primary_player and p_device.want_player_index == 0):
			player_join_ready_rejected.emit(p_device.index, p_device.want_player_index)
		else:
			p_device.player_index = p_device.want_player_index
			slot.ready = true
			slot.add_device(p_device)
			get_player_input_always(p_device.want_player_index).update_devices(slot.devices)
			print("updated input map")
			player_join_ready_accepted.emit(p_device.index, p_device.player_index)
	elif any_slots_available: # join the game
		p_device.active = true
		player_join_accepted.emit(p_device.index)
		for i in _player_slots.size():
			var slot := get_player_slot(i)
			if slot.devices.is_empty() or auto_join_primary_player:
				p_device.change_index(i, max_players)
				if i == 0 and auto_join_primary_player:
					device_join(p_device) # auto-confirm in this case
				break
		player_changed_index.emit(p_device.index, p_device.want_player_index, p_device.want_player_index)
	else: # game is full
		player_join_rejected.emit(p_device.index)

func device_leave(p_device: InputDevice):
	if not p_device.active:
		return

	var slot := get_player_slot(p_device.want_player_index)
	if slot.ready:
		slot.ready = false
		slot.remove_device(p_device)
		player_join_unready.emit(p_device.index, p_device.want_player_index)
		get_player_input_always(p_device.want_player_index).update_devices(slot.devices)
	else:
		p_device.active = false
		player_left.emit(p_device.index, p_device.want_player_index)
	p_device.player_index = PLAYER_INVALID

func get_device_for_event(event: InputEvent) -> InputDevice:
	var valid_devices := _input_devices.filter(func(dev): return dev.check_event(event))
	if valid_devices.is_empty():
		return null
	return valid_devices[0] as InputDevice

var _device_overlay: Node
var _device_join_input := false

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton:
		var device := get_device_for_event(event)
		if device.active:
			if device.player_index >= 0:
				var slot := get_player_slot(device.player_index)
				slot.last_device = device
				player_changed_device.emit(device.player_index, slot.get_most_recent_device_hint())

	if event is InputEventKey:
		if not event.pressed:
			return
		if event.keycode == KEY_F2:
			if not _device_overlay:
				var device_assignment := preload("res://addons/snail_input/device_assignment/device_assignment.tscn")
				_device_overlay = device_assignment.instantiate()
				get_tree().root.add_child(_device_overlay)
			elif not _device_join_input:
				if _device_overlay is Control:
					var t := _device_overlay.create_tween()
					t.set_ease(Tween.EASE_OUT)
					t.set_trans(Tween.TRANS_CUBIC)
					t.tween_property(_device_overlay, "modulate:a", 0, 0.25)
					var node := _device_overlay
					_device_overlay = null
					await t.finished
					node.queue_free()
				else:
					_device_overlay.queue_free()
					_device_overlay = null

	if event is InputEventMouseMotion and Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		_try_auto_join(event)
	elif event is InputEventJoypadMotion or event is InputEventMouseMotion:
		return # only care about button events after here
	elif Input.is_anything_pressed():
		_try_auto_join(event)

func _try_auto_join(event: InputEvent):
	var auto_join := auto_activate_on_press or auto_join_primary_player
	if not auto_join:
		return

	var device := get_device_for_event(event)
	if not device:
		return
	if device.active:
		return
	if auto_join_primary_player:
		device.want_player_index = 0
	device_join(device)
	_device_join_input = true
	#Input.parse_input_event(event.duplicate()) # resubmit input event now that it's remapped, so the first press isn't eaten
	await get_tree().physics_frame
	_device_join_input = false
