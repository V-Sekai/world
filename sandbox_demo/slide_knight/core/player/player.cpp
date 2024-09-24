#include "player.hpp"

static float jump_velocity = -300.0f;
static float player_speed = 150.0f;
static float direction = 0.0f;
static std::string player_name = "Slight Knight";

SANDBOXED_PROPERTIES(3, {
	.name = "player_speed",
	.type = Variant::FLOAT,
	.getter = []() -> Variant { return player_speed; },
	.setter = [](Variant value) -> Variant { return player_speed = value; },
	.default_value = Variant{player_speed},
}, {
	.name = "player_jump_vel",
	.type = Variant::FLOAT,
	.getter = []() -> Variant { return jump_velocity; },
	.setter = [](Variant value) -> Variant { return jump_velocity = value; },
	.default_value = Variant{jump_velocity},
}, {
	.name = "player_name",
	.type = Variant::STRING,
	.getter = []() -> Variant { return player_name; },
	.setter = [](Variant value) -> Variant { return player_name = value.as_std_string(); },
	.default_value = Variant{"Slight Knight"},
});

extern "C" Variant _physics_process(double delta) {
	if (is_editor()) {
		if (is_part_of_tree(get_node())) {
			Dictionary d = Dictionary::Create();
			d["test"] = Node("AnimatedSprite2D");
			d["test"]("play", "idle");
		}
		return Nil;
	}

	Node2D player = get_node();
	Object input = Input::get_singleton();
	Vector2 velocity = player.get("velocity");

	// Add the gravity.
	if (!player("is_on_floor")) {
		velocity += player("get_gravity").v2() * float(delta);
	}
	
	AnimatedSprite2D animated_sprite("AnimatedSprite2D");
	const bool has_died = animated_sprite.animation() == "died";
	if (has_died)
		goto velocity_calculations;

	// Get the input direction and handle the movement/deceleration.
	direction = input("get_axis", "move_left", "move_right");

	// Handle jump.
	if (input("is_action_just_pressed", "jump") && player("is_on_floor"))
		velocity.y = jump_velocity;

	if (direction != 0)
		animated_sprite.set("flip_h", (direction < 0));

	if (player("is_on_floor")) {
		if (direction == 0) {
			animated_sprite.play("idle");
		} else {
			animated_sprite.play("run");
		}
	} else {
		animated_sprite.play("jump");
	}

velocity_calculations:
	if (direction != 0)
		velocity.x = direction * player_speed;
	else
		velocity.x = std::fmin(velocity.x, player_speed);
	player.set("velocity", velocity);

	return player("move_and_slide");
}

static float x = 0.0f;
static float z = 0.0f;

extern "C" Variant _process() {
	static constexpr float period = 1.0f;

	AnimatedSprite2D animated_sprite("AnimatedSprite2D");
	const bool has_died = animated_sprite.animation() == "died";
	if (!has_died)
		return Nil;

	// Rainbow color modulation
	const int r = Math::sin(x * period) * 127 + 128;
	const int g = Math::sin(z * period) * 127 + 128;
	const int b = Math::sin((x + z) * period) * 127 + 128;

	const uint32_t mod = 255 | r << 8 | g << 16 | b << 24;
	get_node("AnimatedSprite2D").set("modulate", mod);
	x += 0.1f;
	z += 0.01f;
	return Nil;
}
