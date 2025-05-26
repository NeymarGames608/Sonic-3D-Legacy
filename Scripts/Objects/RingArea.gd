extends Area

# Referência ao AnimationPlayer e AudioStreamPlayer
var animation_player = null
var ring_sound = null

# Referência ao HUD
var hud = null

func _ready():
	animation_player = $AnimationPlayer
	ring_sound = $RingSound
	
	# Certifique-se de que o caminho para o HUD está correto
	hud = get_node("/root/TestStage/HUD")

	# Conecta o sinal de área entrando para detectar colisão
	connect("body_entered", self, "_on_body_entered")
	
	# Toca a animação Idle inicialmente
	animation_player.play("Idle")

func _on_body_entered(body):
	if body.name == "Sonic":
		ring_sound.play()  # Toca o som do anel
		animation_player.play("Collect")  # Toca a animação de coleta
		
		# Incrementa a contagem de rings no HUD
		if hud:
			hud.increment_ring_count(1)
			hud.increment_score(100)
		
		# Remove o anel após 0,4 segundos
		yield(get_tree().create_timer(0.4), "timeout")
		queue_free()  # Remove o anel da cena
