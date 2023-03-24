class_name TargetIndicatorLine
extends MeshInstance3D


var _immediate_mesh: ImmediateMesh

func _ready():
	_immediate_mesh = mesh as ImmediateMesh


func draw_line(target: Vector3):
	_immediate_mesh.clear_surfaces()
	_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	_immediate_mesh.surface_add_vertex(global_position)
	_immediate_mesh.surface_add_vertex(target)
	_immediate_mesh.surface_end()
