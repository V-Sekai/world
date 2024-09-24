#include "api.hpp"

extern "C" Variant _on_body_entered(Object bodyVar) {
	Engine::set_time_scale(0.5);

	Node2D body = cast_to<Node2D> (bodyVar);
	body.set("velocity", Vector2(0.0f, -120.0f));
	body.get_node("CollisionShape2D").queue_free();
	print("Playing dead");
	body.get_node("AnimatedSprite2D")("play", std::u32string(U"died"));

	Timer::native_oneshot(1.0f, [] (Object timer) -> Variant {
		timer.as_node().queue_free();
		Engine::set_time_scale(1.0);

		get_tree().call_deferred("reload_current_scene");
		return {};
	});
	return {};
}
