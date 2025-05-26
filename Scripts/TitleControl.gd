extends Control

func _ready():
	$PlayButton.connect("pressed", self, "_on_PlayButton_pressed")
	$ExitButton.connect("pressed", self, "_on_ExitButton_pressed")

func _on_PlayButton_pressed():
	get_tree().change_scene("res://Scenes/Stages/TestStage.tscn")  # Caminho atualizado para sua cena de jogo

func _on_ExitButton_pressed():
	get_tree().quit()
