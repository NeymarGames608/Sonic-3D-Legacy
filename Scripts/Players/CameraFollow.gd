extends Spatial

# Posição e rotação iniciais da câmera
var initial_camera_position = Vector3(-15, 6.5, 0)
var initial_camera_rotation = Vector3(0, -90, 0)

# Referência ao Sonic (ou ao nó que deve ser seguido)
var target_node = null

func _ready():
	# Configura a posição e rotação iniciais da câmera
	translation = initial_camera_position
	rotation_degrees = initial_camera_rotation

	# Substitua "Sonic" pelo caminho para o nó do Sonic no seu jogo
	target_node = get_node("/root/TestStage/Sonic/Sonic")

func _process(_delta):
	if target_node != null:
		# Atualiza a posição do nó CameraFollow para seguir o Sonic com posição relativa fixa
		global_transform.origin = target_node.global_transform.origin + initial_camera_position
		# Mantém a rotação inicial da câmera
		rotation_degrees = initial_camera_rotation
