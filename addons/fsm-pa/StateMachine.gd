extends Resource

class_name StateMachine

signal enter_state()
signal leave_state()
signal state_duration_updated(duration)
signal states_changed()

# Entity that the stateStack is attached to
var target: Node

# This member array is the heart of the whole operation.
# It looks like this:
# [[state_object1, [arg1, arg2, ...]], [state_object2, [arg1, arg2, ...]], ...]
var states: Array = []

# a place to store a fallback state
var default_state: State

func _process(delta: float) -> void:
	var state = get_state()

	if state != null:
		# Run the state's _process method
		state._process(delta)

		# increment state_time by delta
		state.duration += delta
		emit_signal("state_duration_updated", state.duration)
	elif default_state != null:
		# If state stack is empty, we push the default
		push_create(default_state.state_script, default_state.args)
		_process(delta) # and try to run it right away

func _physics_process(delta: float) -> void:
	var state = get_state()

	if state != null:
		# Run the state's _physics_process method
		state._physics_process(delta)

		# increment state_time by delta
		state.duration += delta
		emit_signal("state_duration_updated", state.duration)
	elif default_state != null:
		# If state stack is empty, we push the default
		push_create(default_state.state_script, default_state.args)
		_physics_process(delta) # and try to run it right away

func _input(event: InputEvent) -> void:
	var state = get_state()

	if state != null:
		# Run the state's _input method
		state._input(event)
	elif default_state != null:
		# If state stack is empty, we push the default
		push_create(default_state.state_script, default_state.args)
		_input(event) # and try to run it right away

func get_state() -> State:
	"""
	Returns the current state after checking if it was started, and starts
	the state if it was not started, emitting the enter_state signal.
	"""
	# Method for processing the current state @ pos 0
	if states.size() <= 0:
		return null

	# get top state info
	var state = states[0]

	# Check for first time running, and start state
	if state.started == false:
		connect("enter_state", state, "_on_enter_state")
		connect("leave_state", state, "_on_leave_state")

		emit_signal("enter_state")

		state.started = true

	return state

func push(state: State) -> void:
	"""
	Push a state to front of the states stack (array)
	"""
	states.push_front(state)
	emit_signal("states_changed")

func add(state: State) -> void:
	"""
	Add a state to end of states stack (array)
	"""
	states.append(state)
	emit_signal("states_changed")

func push_create(state_script: Script, args: Array = []) -> void:
	"""
	Create and add a state class with args to front of the states stack
	"""
	push(state_create(state_script, args))

func add_create(state_script: Script, args: Array = []) -> void:
	"""
	Create and add a state class and args to the end of the states stack
	"""
	add(state_create(state_script, args))

func pop() -> void:
	"""
	Pop the top state from the from the states stack (array)
	"""
	var state = states.pop_front()

	# process leave_state event for the popped state
	emit_signal("leave_state")
	disconnect("enter_state", state, "_on_enter_state")
	disconnect("leave_state", state, "_on_leave_state")

	emit_signal("states_changed")

func state_create(state_script: Script, args: Array = []) -> State:
	"""
	Creates an entry appropriate for the states array
	[state_ref, [arg1, arg2, ...]]
	"""
	var state = state_script.new()
	state.target = target
	state.state_script = state_script
	state.args = args

	return state

class State:
	extends Resource

	# State name
	var name: String = resource_name

	# Target for the state (object, node, etc)
	var target: Node

	# Reference to state machine
	var state_machine: StateMachine

	# Reference to script to "new"
	var state_script: Script

	# Array of args/params to use for this state
	var args: Array = []

	# Duration of time this state has been running
	var duration: float = 0.0

	# Has this state been started
	var started: bool = false

	func _on_enter_state() -> void:
		"""
		State machine callback called during transition when entering this state
		"""
		pass

	func _on_leave_state() -> void:
		"""
		State machine callback called during transition when leaving this state
		"""
		pass

	func _process(delta: float) -> void:
		pass

	func _physics_process(delta: float) -> void:
		pass

	func _input(event: InputEvent) -> void:
		pass
