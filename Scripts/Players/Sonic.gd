extends KinematicBody

# Variáveis de movimento e física
var velocity = Vector3()
var acceleration = 2
var speed = 5
var max_speed = 20
var gravity = -9.8
var jump_speed = 15
var is_jumping = false
var is_alive = true
var is_invincible = false  # Invencibilidade temporária
var lives = 3  # Número inicial de vidas
var ring_count = 0  # Contador de anéis

# Referência ao AnimationPlayer e AudioStreamPlayer
var animation_player = null
var jump_sound = null
var stop_sound = null
var die_sound = null
var hit_sound = null  # Som de hit
var ring_loss_sound = null  # Som de perda de anéis

# Referência ao HUD para atualizar o contador de vidas
var hud = null

# Temporizador para IdleLoop
var idle_timer = 0
var idle_threshold = 5

# Temporizador de invencibilidade
var invincibility_timer = 0
var invincibility_duration = 2.0  # 2 segundos de invencibilidade

# Variáveis de momentum
var current_speed = 0
var walk_speed = 5
var run_start_speed = 10
var run_speed = 15
var deceleration = 30
var stopping = false
# Altura crítica de queda
var fall_threshold = -50  # Ajuste conforme necessário
var respawn_timer = 0
var respawn_delay = 1.5  # Tempo total antes de reiniciar o jogo
var fall_up_distance = 25.0  # Distância que Sonic sobe antes de cair
var fall_duration = 0.5  # Duração do movimento de subida/gravidade/queda
var fall_gravity_duration = 0.5  # Tempo de atuação da gravidade antes da queda

func _ready():
	# Obtém o AnimationPlayer e os AudioStreamPlayers
	animation_player = $AnimationPlayer
	jump_sound = $Jump
	stop_sound = $Stop
	die_sound = $Die  # Adicione o som de morte
	hit_sound = $Hit  # Adicione o som de hit
	ring_loss_sound = $RingLoss  # Adicione o som de perda de anéis

	# Obtenha a referência ao HUD
	hud = get_node("/root/TestStage/HUD")
	# Inicializa o número de vidas no HUD
	if hud:
		hud.update_lives_label()

func _process(delta):
	if is_alive:
		# Atualiza o movimento do Sonic
		handle_movement(delta)
		# Atualiza a animação do Sonic
		update_animation(delta)
		# Verifica se Sonic caiu de uma grande altura
		if translation.y < fall_threshold:
			die()
		# Atualiza o timer de invencibilidade
		if is_invincible:
			invincibility_timer -= delta
			if invincibility_timer <= 0:
				is_invincible = false
				show()  # Para de piscar
	else:
		# Animação e lógica de morte
		handle_death_animation(delta)

func handle_movement(delta):
	# Aplica a gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if is_jumping:
			is_jumping = false
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_speed
			is_jumping = true
			jump_sound.play()  # Toca o som de pulo

	# Reseta a velocidade horizontal
	var move_direction = Vector3()
	velocity.x = 0
	velocity.z = 0

	# Movimento horizontal em 8 direções
	var is_moving = false
	if Input.is_action_pressed("ui_up"):
		if Input.is_action_pressed("ui_right"):
			move_direction.x = speed
			move_direction.z = speed
			rotation_degrees.y = -45
		elif Input.is_action_pressed("ui_left"):
			move_direction.x = speed
			move_direction.z = -speed
			rotation_degrees.y = 45
		else:
			move_direction.x = speed
			rotation_degrees.y = 0
		is_moving = true
	elif Input.is_action_pressed("ui_down"):
		if Input.is_action_pressed("ui_right"):
			move_direction.x = -speed
			move_direction.z = speed
			rotation_degrees.y = -135
		elif Input.is_action_pressed("ui_left"):
			move_direction.x = -speed
			move_direction.z = -speed
			rotation_degrees.y = 135
		else:
			move_direction.x = -speed
			rotation_degrees.y = 180
		is_moving = true
	elif Input.is_action_pressed("ui_right"):
		move_direction.z = speed
		rotation_degrees.y = -90
		is_moving = true
	elif Input.is_action_pressed("ui_left"):
		move_direction.z = -speed
		rotation_degrees.y = 90
		is_moving = true

	# Aplica a velocidade horizontal ao Sonic com base no momentum
	if is_moving:
		current_speed = min(current_speed + acceleration * delta, max_speed)
		idle_timer = 0  # Reseta o temporizador de inatividade quando se move
		stopping = false  # Reseta o estado de parada quando se move
	else:
		if current_speed >= run_start_speed:
			stopping = true
			current_speed = max(current_speed - deceleration * delta, 0)
			if current_speed == 0:
				stop_sound.play()  # Toca o som de parada
				animation_player.play("Idle")
		else:
			stopping = false
			if current_speed > 0:
				current_speed = max(current_speed - deceleration * delta, 0)
			if current_speed == 0:
				is_jumping = false  # Reseta o estado de pulo se parado
				idle_timer += delta  # Incrementa o temporizador de inatividade

	move_direction = move_direction.normalized() * current_speed
	velocity.x = move_direction.x
	velocity.z = move_direction.z

	# Move o Sonic e detecta colisões
	velocity = move_and_slide(velocity, Vector3.UP)

	# Verifica se Sonic caiu ou perdeu todos os anéis
	if is_off_level() or is_hit():
		die()

func is_off_level() -> bool:
	# Checa se o Sonic caiu fora da área do nível
	return translation.y < fall_threshold  # Ajuste este valor conforme necessário
func update_animation(_delta):
	if animation_player != null:
		if is_jumping and velocity.y != 0:
			animation_player.play("JumpRoll")
		elif current_speed == 0:
			handle_idle_animation()
		else:
			idle_timer = 0
			if stopping and animation_player.current_animation != "Stop":
				animation_player.play("Stop")
			else:
				if current_speed < run_start_speed:
					animation_player.play("Walk")
				else:
					animation_player.play("Run")

func handle_idle_animation():
	if idle_timer >= idle_threshold:
		if animation_player.current_animation == "IdleLoopStart" and not animation_player.is_playing():
			animation_player.play("IdleLoop")
		elif animation_player.current_animation != "IdleLoopStart" and animation_player.current_animation != "IdleLoop":
			animation_player.play("IdleLoopStart")
	else:
		if animation_player.current_animation != "Idle" and animation_player.current_animation != "IdleLoop":
			animation_player.play("Idle")
func die():
	if is_alive:
		is_alive = false
		lives -= 1  # Decrementa uma vida
		if hud:
			hud.decrement_life()  # Atualiza o HUD
		die_sound.play()  # Toca o som de morte
		animation_player.stop()  # Para qualquer animação atual
		animation_player.play("Die")  # Toca a animação de morte
		set_collision_layer(0)  # Desativa a colisão
		set_collision_mask(0)
		respawn_timer = respawn_delay

func handle_hit():
	if not is_invincible:
		is_invincible = true
		invincibility_timer = invincibility_duration
		hide()  # Pisca para indicar invencibilidade
		hit_sound.play()  # Toca o som de hit
		animation_player.stop()  # Para qualquer animação atual
		animation_player.play("Hit")  # Toca a animação de hit

		# Sonic sobe um pouco e cai
		velocity.y = jump_speed / 2

		# Espalha os anéis
		ring_loss_sound.play()  # Toca o som de perda de anéis
		if hud:
			hud.scatter_rings(ring_count)
			ring_count = 0
			hud.update_ring_label()
func handle_death_animation(delta):
	if respawn_timer > 0:
		if respawn_timer > respawn_delay - fall_gravity_duration - fall_duration:
			# Primeira fase: Sonic sobe
			translation.y += (fall_up_distance / fall_duration) * delta
		elif respawn_timer > respawn_delay - fall_gravity_duration:
			# Segunda fase: Gravidade atuando
			velocity.y += gravity * delta
		else:
			# Terceira fase: Sonic cai
			translation.y -= (fall_up_distance / fall_duration) * delta
		respawn_timer -= delta
	else:
		if lives > 0:
			respawn()
		else:
			get_tree().change_scene("res://Scenes/GameOver.tscn")

func respawn():
	# Resetar a posição do Sonic para a posição inicial ou ponto de checkpoint
	translation = Vector3(0, 1, 0)
	is_alive = true
	set_collision_layer(1)  # Reativa a colisão
	set_collision_mask(1)  # Reativa a colisão
	# Resetar os contadores e reaparecer os anéis
	if hud:
		hud.reset_labels()
		hud.respawn_rings()
func is_hit() -> bool:
	# Lógica para determinar se o Sonic foi atingido
	# Por exemplo, pode ser uma colisão com um inimigo ou obstáculo
	# Aqui você deve implementar sua própria lógica de detecção de hit
	return false
