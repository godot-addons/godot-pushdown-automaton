extends Resource

class_name PushdownAutomaton

signal enter_state(target)
signal leave_state()
signal state_duration_updated(value)
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
	# Method for processing the current state @ pos 0
	if states.size() > 0:
		# get top state info
		var state = states[0]

		# Check for first time running, and start state
		if state.started == false:
			connect("enter_state", state, "_on_enter_state")
			emit_signal("enter_state")
			state.started = true

		# Run the state's process method
		state._process(delta)

		# increment state_time by delta
		state.state_time += delta
		emit_signal("state_duration_updated", state.duration)
	elif default_state != null:
		# If state stack is empty, we push the default
		push_create(default_state.state_script, default_state.args)
		_process(delta) # and try to run it right away

func _physics_process(delta: float) -> void:
	# Method for processing the current state @ pos 0
	if states.size() > 0:
		# get top state info
		var state = states[0]

		# Check for first time running, and start state
		if state.started == false:
			connect("enter_state", state, "_on_enter_state")
			emit_signal("enter_state")
			state.started = true

		# Run the state's process method
		state._physics_process(delta)

		# increment state_time by delta
		state.state_time += delta
		emit_signal("state_duration_updated", state.duration)
	elif default_state != null:
		# If state stack is empty, we push the default
		push_create(default_state.state_script, default_state.args)
		_physics_process(delta) # and try to run it right away

# input() needs more testing!
func _input(event: InputEvent) -> void:
	# Method for processing the current state @ pos 0
	if states.size() > 0:
		# get top state info
		var state = states[0]

		# Check for first time running, and start state
		if state.started == false:
			connect("enter_state", state, "_on_enter_state")
			emit_signal("enter_state")
			state.started = true

		# Run the state's input method
		state.input(event)
	elif default_state != null:
		# If state stack is empty, we push the default
		push_create(default_state.state_script, default_state.args)
		_input(event) # and try to run it right away

func push(state: State) -> void:
	# add a state to front of state stack
	states.push_front(state)
	emit_signal("states_changed")

func add(state: State) -> void:
	# add a state to end of state stack
	states.append(state)
	emit_signal("states_changed")

func push_create(state_script: Script, args: Array = []) -> void:
	# create and add a state class with args to front of state stack
	push(state_create(state_script, args))

func add_create(state_script: Script, args: Array = []) -> void:
	# create and add a state class and args to end of state stack
	add(state_create(state_script, args))

func pop() -> void:
	# pop the top state from the from state stack
	var state = states.pop_front()

	# process leave_state event for the popped state
	emit_signal("leave_state")
	disconnect("enter_state", state, "_on_enter_state")
	disconnect("leave_state", state, "_on_leave_state")

	emit_signal("states_changed")

func state_create(state_script: Script, args: Array = []) -> State:
	# creates an entry appropriate for the _states array
	# [state_ref, [arg1, arg2, ...]]
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
	var state_machine: PushdownAutomaton

	# Reference to script to "new"
	var state_script: Script

	# Array of args/params to use for this state
	var args: Array = []

	# Duration of time this state has been running
	var duration: float = 0.0

	# Has this state been started
	var started: bool = false

	# State machine callback called during transition when entering this state
	func _on_enter_state() -> void:
		pass

	# State machine callback called during transition when leaving this state
	func _on_leave_state() -> void:
		pass

	func _process(delta: float) -> void:
		pass

	func _physics_process(delta: float) -> void:
		pass

	func _input(event: InputEvent) -> void:
		pass
