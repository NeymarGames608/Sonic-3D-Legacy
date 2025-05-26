extends Spatial

onready var animation_player = $AnimationPlayer
onready var timer = $Timer
onready var area = $Area

func _ready():
	# Inicia a animação DEFAULT
	animation_player.play("DEFAULT")
	
	# Conecta o sinal de entrada do corpo na área
	area.connect("body_entered", self, "_on_body_entered")
	
	# Conecta o sinal timeout do timer ao método _on_timer_timeout
	timer.connect("timeout", self, "_on_timer_timeout")

# Método chamado quando Sonic encosta na placa
func _on_body_entered(body):
	if body.name == "Sonic":  # Verifica se foi Sonic que encostou
		# Inicia a animação Spin
		animation_player.play("Spin")
		# Conecta o sinal de animação finalizada para continuar a sequência
		animation_player.connect("animation_finished", self, "_on_animation_finished")

# Método chamado quando a animação termina
func _on_animation_finished(anim_name):
	if anim_name == "Spin":
		# Troca para a animação SonicCompt
		animation_player.play("SonicCompt")
		# Inicia o timer para trocar de cena após a animação SonicCompt
		timer.start(2)  # Tempo em segundos para a troca de cena

# Método chamado quando o timer é acionado
func _on_timer_timeout():
	# Transição para a cena SYND.tscn
	get_tree().change_scene("res://Scenes/SYND.tscn")
