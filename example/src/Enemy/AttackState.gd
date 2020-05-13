extends "ProxyState.gd"

func _init() -> void:
	name = "ATTACK"

func _process(_delta: float) -> void:
	if not target.has_enemies():
		target.state_machine.pop()
		target.state_machine.push_create(EnemyStates.PatrolState, [])
		return

	target.attack_enemies()

func _on_enter_state() -> void:
	target.say("Player Detected")

func _on_leave_state() -> void:
	target.say("No Player Detected")
