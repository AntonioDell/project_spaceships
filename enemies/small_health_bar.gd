extends Sprite3D

@export var health_tracker_component: HealthTrackerComponent

@onready var progress_bar := %ProgressBar

func _ready():
	#texture = $SubViewport.get_texture()
	if not health_tracker_component: 
		push_warning("No health tracker connected", self)
		return
	health_tracker_component.health_changed.connect(_on_health_changed)
	progress_bar.max_value = health_tracker_component.max_health
	progress_bar.value = health_tracker_component.health
	visible = false
	


func _on_health_changed(current_health: int, _previous_health: int, max_health: int):
	progress_bar.max_value = max_health
	progress_bar.value = current_health
	visible = true
	$VisibilityTimer.start()
	await $VisibilityTimer.timeout
	visible = false
