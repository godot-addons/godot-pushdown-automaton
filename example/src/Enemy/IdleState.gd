extends ProxyState

class_name IdleState

func _init() -> void:
	name = "IDLE"

func _process(_delta: float) -> void:
	# Start patrolling when the player gets closer to us
	if target.should_patrol():
		target.state_machine.pop()
		target.state_machine.push_create(PatrolState, [])

func _on_enter_state() -> void:
	target.say("I feel at peace.")

func _on_leave_state() -> void:
	target.say("I feel uneasy...")
