# godot-pushdown-automaton

Godot Pushdown Automaton FSM (Finite State Machine)

This is a FSM for Godot that is purely code-only (no editor plugin), and implements a stack (Pushdown Automaton).

# Examples

## Setup

```gdscript
extends Node2D

const StateMachine = preload("res://addons/fsm/StateMachine.gd")
const IdleState = preload("IdleState.gd")

# Create new state machine factory
var sm: StateMachine = StateMachine.new()

func _ready() -> void:
  sm.target = self
  sm.default_state = sm.state_create(IdleState)
```

## State Machine

### State Machine Target

```gdscript
# Set the state machine's target (recursively sets on states)
sm.target = $Player

# Get state machine's target object
var player = sm.target
```

### State Machine Current State

```gdscript
# Set the state machine's current state. This really should be called internally by the state machine only.
var state = sm.get_state()
```

### (WIP) - State Machine Transition

The transition method of the state machine will validate that the id passed is a valid state. It will call the current state's `_on_leave_state` callback if implemented. It will then call the to state's `_on_enter_state` method.

```gdscript
# Transition to new state
sm.transition("patrol")
```

### State Machine Callbacks

The state manager exposes callback methods for `_process(delta)`, `_physics_process(delta)`, and `_input(event)`. Calls to these methods are proxied down to the current state's method if it has implemented them.

```gdscript
# State machine callbacks which are proxied down to the current state object
sm._physics_process(delta)
sm._process(delta)
sm._input(event)
sm._on_enter_state()
sm._on_leave_state()
```

## State

### (WIP) - State ID

Each state stores its own name.

```gdscript
var sm = StateMachine.new()
sm.target = $Player
sm.default_state = sm.create_push(IdleState)

var state = IdleState.new()
state.sm = sm
state.id = "idle"

var state_id = state.id
```

### State Target

The state and state machine have a target object, which is assumed to be where any extra required context is coded against.

```gdscript
var smf = StateMachineFactory.new()
var sm = smf.create()

var state = IdleState.new()
state.state_machine = sm
state.id = "idle"
state.target = $Player

var player = state.target
```

### State Callbacks

A state class can implement callbacks for `_process(delta)`, `_physics_process(delta)`, `_input(event)`, `_on_enter_state()`, and `_on_leave_state()`.

```gdscript
extends "res://addons/fsm/StateMachine.gd".State

var memory = 0

func _init().():
  physics_process_enabled = true

func _physics_process(delta: float) -> void:
	scan_for_enemy(delta)
	move_to_random(delta)

func scan_for_enemy(delta: float) -> void:
  pass

func move_to_random(delta: float) -> void:
	# some logic to move to a random location
	...

	# Transition to idle state if we have reached our destination
	if arrived_at_location():
    state_machine.transition("idle")

func _on_enter_state() -> void:
  memory = 100
```

# Credits / Links

Code borrowed from https://gitlab.com/reefpirate/finite_stack_machine/-/tree/master and then updated/refactored in alignment with godot-finite-state-machine, including example/demo.
