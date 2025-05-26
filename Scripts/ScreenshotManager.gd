extends Node

var screenshot_count = 0  # Contador para nomear os prints de tela

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_P:
			# Tira um print de tela quando o botão 'P' é pressionado
			_take_screenshot()

func _take_screenshot():
	var screenshot_path = "res://Screenshots/screenshot_%s.png" % screenshot_count
	var screenshot = get_viewport().get_texture().get_data()
	screenshot.flip_y()  # Corrige a orientação da imagem
	screenshot.save_png(screenshot_path)
	screenshot_count += 1
	print("Captura de tela salva em %s" % screenshot_path)
