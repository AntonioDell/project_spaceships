class_name FactoryComponent
extends Node


enum PauseReason {
	INSUFFICIENT_RESOURCES,
	MANUAL_PAUSE
}

enum AbortReason {
	MANUAL_ABORT
}


signal production_started
signal production_paused(reason: PauseReason)
signal production_aborted(reason: AbortReason)
signal production_completed(product_id: String)


var _production_queue: Array[ProductBlueprint] = []
var _paused = false:
	set(new_value):
		_paused = new_value
		_production_timer.paused = _paused

@onready var _production_timer := $ProductionTimer as Timer


func queue_production(product_blueprint: ProductBlueprint, amount: int):
	for _i in range(amount):
		_production_queue.push_back(product_blueprint)

	if _production_timer.is_stopped():
		emit_signal("production_started")
		_start_next_task()


func abort_production():
	if _production_queue.is_empty(): return
	_production_queue.clear()
	_production_timer.stop()
	emit_signal("production_aborted", AbortReason.MANUAL_ABORT)


func pause_production():
	if _paused or _production_queue.is_empty(): return
	_paused = true
	emit_signal("production_paused", PauseReason.MANUAL_PAUSE)


func resume_production():
	_paused = false


func finish_production(product_blueprint: ProductBlueprint):
	emit_signal("production_completed", product_blueprint.id)


func _start_next_task():
	if _paused or _production_queue.is_empty(): return
	
	var _current_task := _production_queue.front() as ProductBlueprint
	_production_timer.start(_current_task.production_time)
	await _production_timer.timeout
	
	if not _paused:
		finish_production(_current_task)
		_production_queue.pop_front()
		_start_next_task()
