extends Node2D

# Carrega o recurso Ring
var Ring = preload("res://Scenes/Objects/Ring.tscn")  # Caminho correto do seu arquivo Ring

# Variáveis para armazenar os contadores
var ring_count = 0
var time_left = 599.0  # Tempo inicial em segundos (9:59)
var score = 0
var lives = 3  # Número inicial de vidas

# Referências aos Labels
var ring_label = null
var time_label = null
var score_label = null
var lives_label = null

# Referência aos anéis na cena
var ring_bases = []

func _ready():
	# Obtém referências aos Labels
	ring_label = $RingLabel
	time_label = $TimeLabel
	score_label = $ScoreLabel
	lives_label = $LivesLabel

	# Inicializa os textos dos labels
	update_ring_label()
	update_time_label()
	update_score_label()
	update_lives_label()

	# Obtém referências aos anéis na cena
	ring_bases = get_tree().get_nodes_in_group("RingBase")

	set_process(true)

func _process(delta):
	if time_left > 0:
		time_left -= delta
		update_time_label()
	elif time_left <= 0 and lives > 0:
		lives -= 1
		update_lives_label()
		reset_time()
	elif time_left <= 0 and lives <= 0:
		if get_node("/root/TestStage/Sonic"):
			get_node("/root/TestStage/Sonic").die()

func update_ring_label():
	ring_label.text = "Rings: " + str(ring_count)

func update_time_label():
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	time_label.text = "Time: " + str(minutes) + ":" + str("%02d" % seconds)

func update_score_label():
	score_label.text = "Score: " + str(score)

func update_lives_label():
	lives_label.text = "Lives: " + str(lives)

# Funções para incrementar os contadores
func increment_ring_count(amount):
	ring_count += amount
	update_ring_label()

func increment_score(amount):
	score += amount
	update_score_label()

func decrement_life():
	if lives > 0:
		lives -= 1
		update_lives_label()

func reset_time():
	time_left = 599.0
	update_time_label()

# Função para resetar os labels
func reset_labels():
	ring_count = 0
	score = 0
	time_left = 599.0
	update_ring_label()
	update_score_label()
	update_time_label()

# Função para reaparecer os anéis
func respawn_rings():
	for ring_base in ring_bases:
		ring_base.queue_free()  # Remove os anéis RingBase atuais
	ring_bases.clear()
	
	# Recrie os anéis na cena (supondo que a posição original está salva)
	var test_stage = get_tree().root.get_node("TestStage")
	for original_ring in test_stage.get_children():
		if original_ring.name.begins_with("RingBase"):
			var new_ring_base = original_ring.duplicate()
			test_stage.add_child(new_ring_base)
			ring_bases.append(new_ring_base)

# Função para resetar tudo ao tentar novamente
func reset_game():
	ring_count = 0
	score = 0
	lives = 3
	time_left = 599.0
	update_ring_label()
	update_score_label()
	update_time_label()
	update_lives_label()
	respawn_rings()

# Função para espalhar os anéis quando Sonic é atingido
func scatter_rings(count):
	for _i in range(count):  # Prefixa a variável com um sublinhado para indicar que não será usada
		# Crie um anel e adicione à cena
		var ring = Ring.instance()
		get_tree().root.get_node("TestStage").add_child(ring)
		
		# Coloque o anel em uma posição aleatória ao redor do Sonic
		var position = Vector3(
			randf() * 10 - 5,
			0,
			randf() * 10 - 5
		)
		ring.translation = position
		
		# Faça o anel desaparecer após um tempo
		ring.queue_free_after(3.0)  # Ajuste o tempo conforme necessário
