#include "api.hpp"
static int coins = 0;

extern "C" Variant reset_game() {
	coins = 0;
	return Nil;
}

static void add_coin(const Node& player) {
	coins ++;
	Node coinlabel = player.get_node("../Texts/CoinLabel");
	coinlabel.set("text", "You have collected "
		+ std::to_string(coins) + ((coins == 1) ? " coin" : " coins"));
}

extern "C" Variant _on_body_entered(Node2D node) {
	if (node.get_name() != "Player")
		return Nil;

	get_node().queue_free(); // Remove the current coin!
	add_coin(node);
	return Nil;
}

extern "C" Variant _ready() {
	if (is_editor()) {
		get_node()("set_process_input", false);
	}
	return Nil;
}

extern "C" Variant _process(double delta) {
	if (is_editor()) {
		Node("AnimatedSprite2D")("play", "idle");
	}
	return Nil;
}

extern "C" Variant _input(Object event) {
	if (event("is_action_pressed", "jump")) {
		get_node().set("modulate", 0xFF6060FF);
	} else if (event("is_action_released", "jump")) {
		get_node().set("modulate", 0xFFFFFFFF);
	}
	return Nil;
}
