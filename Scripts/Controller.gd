extends Control

onready var analog_base = $AnalogBase
onready var analog_handle = $AnalogBase/AnalogHandle
onready var jump_button = $JumpButton
var is_dragging = false
var start_pos = Vector2()
var analog_pos = Vector2()

func _ready():
	# Configura a posição inicial do AnalogHandle no centro da base
	analog_handle.rect_position = (analog_base.rect_size - analog_handle.rect_size) / 2
	analog_base.connect("gui_input", self, "_on_analog_input")
	jump_button.connect("pressed", self, "_on_jump_button_pressed")
	jump_button.connect("released", self, "_on_jump_button_released")

func _on_analog_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			start_pos = event.position
			analog_handle.rect_position = start_pos - analog_handle.rect_size / 2
		else:
			is_dragging = false
			analog_pos = Vector2.ZERO  # Reseta a posição do analógico
			analog_handle.rect_position = (analog_base.rect_size - analog_handle.rect_size) / 2
			release_movement_inputs()
	elif event is InputEventScreenDrag and is_dragging:
		analog_pos = (event.position - start_pos).clamp_length(analog_base.rect_size.x / 2)
		analog_handle.rect_position = start_pos + analog_pos - analog_handle.rect_size / 2
		update_movement_inputs()

func _process(delta):
	if is_dragging:
		update_movement_inputs()

func _on_jump_button_pressed():
	Input.action_press("jump")

func _on_jump_button_released():
	Input.action_release("jump")

func update_movement_inputs():
	Input.action_release("ui_up")
	Input.action_release("ui_down")
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	
	if analog_pos.y < -analog_base.rect_size.y / 4:
		Input.action_press("ui_up")
	elif analog_pos.y > analog_base.rect_size.y / 4:
		Input.action_press("ui_down")
	
	if analog_pos.x < -analog_base.rect_size.x / 4:
		Input.action_press("ui_left")
	elif analog_pos.x > analog_base.rect_size.x / 4:
		Input.action_press("ui_right")

func release_movement_inputs():
	Input.action_release("ui_up")
	Input.action_release("ui_down")
	Input.action_release("ui_left")
	Input.action_release("ui_right")
