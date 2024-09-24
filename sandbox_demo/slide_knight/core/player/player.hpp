#include "api.hpp"

struct AnimatedSprite2D : public Node2D {
	AnimatedSprite2D(std::string_view path) : Node2D(path) {}

	void play(Variant animation) { this->voidcall("play", animation); }
	Variant animation() { return this->get("animation"); }
};
