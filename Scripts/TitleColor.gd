extends MeshInstance2D

func _ready():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = Shader.new()
	shader_material.shader.code = """
	shader_type canvas_item;

	uniform vec4 color : hint_color;

	void fragment() {
		COLOR = color;
	}
	"""
	shader_material.set_shader_param("color", Color(0.68, 0.85, 0.9))  # Azul claro
	self.material = shader_material
