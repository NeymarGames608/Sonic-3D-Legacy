extends StaticBody

# Velocidade e direção de movimento
var speed = 5  # Aumenta a velocidade
var direction = 1
var movement_range = 20  # Aumenta a distância total que a plataforma percorre
var start_position = Vector3()

# Sonic (Nó que representa o jogador)
var sonic = null

func _ready():
	start_position = translation
	# Conecta o sinal de detecção do Sonic na área
	$Area.connect("body_entered", self, "_on_body_entered")
	$Area.connect("body_exited", self, "_on_body_exited")

func _process(delta):
	# Move a plataforma
	move_platform(delta)

func move_platform(delta):
	var displacement = speed * direction * delta
	translation.x += displacement
	
	# Verifica se a plataforma chegou ao final do movimento e inverte a direção
	if abs(translation.x - start_position.x) >= movement_range:
		direction *= -1

	# Se Sonic estiver sobre a plataforma, move Sonic junto
	if sonic:
		sonic.global_translate(Vector3(displacement, 0, 0))

func _on_body_entered(body):
	if body.name == "Sonic":
		sonic = body

func _on_body_exited(body):
	if body == sonic:
		sonic = null
