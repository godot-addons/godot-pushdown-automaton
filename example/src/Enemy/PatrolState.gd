extends "ProxyState.gd"

const PATROL_MAX_X: float = 600.0
const PATROL_MIN_X: float = 200.0
const PATROL_MAX_Y: float = 400.0
const PATROL_MIN_Y: float = 200.0

var _patrol_direction = Vector2(1, 1)

func _init() -> void:
	name = "PATROL"

func _process(_delta: float) -> void:
	check_for_new_patrol_direction()

	# Move target along a path
	target.position += _patrol_direction

	# We're close to the target, let's attack them
	if target.has_enemies():
		target.state_machine.pop()
		target.state_machine.push_create(EnemyStates.AttackState, [])

	# We're far from the player, stop patrolling
	elif not target.should_patrol():
		target.state_machine.pop()

func check_for_new_patrol_direction() -> void:
	"""
	Checks to see whether the unit has left the bounds in one
	direction or the other.

	If the unit is outside bounds, reverse it's walking direction for that axis
	"""
	var position = target.position

	# We've gone too far left or right
	if position.x > PATROL_MAX_X or position.x < PATROL_MIN_X:
		_patrol_direction *= Vector2(-1, 1)
		return

	# We've gone too far up or down
	if position.y > PATROL_MAX_Y or position.y < PATROL_MIN_Y:
		_patrol_direction *= Vector2(1, -1)
		return

	_patrol_direction = position
