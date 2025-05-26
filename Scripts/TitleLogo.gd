extends Sprite
# Variável da animação do título
onready var title_anim = $AnimationPlayer
# Iniciar animação
func _ready():
	title_anim.play("Move")
