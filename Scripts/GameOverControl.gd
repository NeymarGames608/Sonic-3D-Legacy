extends Control

func _ready():
	$TryAgainButton.connect("pressed", self, "_on_TryAgainButton_pressed")
	$ExitButton.connect("pressed", self, "_on_ExitButton_pressed")

func _on_TryAgainButton_pressed():
	# Reinicia o estado do jogo
	var hud = get_node("res://Scenes/Objects/HUD.tscn")
	if hud:
		hud.reset_game()
	get_tree().change_scene("res://Scenes/Stages/TestStage.tscn")  # Caminho atualizado para sua cena de jogo

func _on_ExitButton_pressed():
	get_tree().quit()
