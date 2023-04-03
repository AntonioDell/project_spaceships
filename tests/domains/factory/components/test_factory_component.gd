extends GutTest


var factory_component = preload("res://domains/factory/components/factory_component.tscn")
var product_blueprint = preload("res://domains/factory/resources/product_blueprint.tres")

var factory: FactoryComponent
var production_time := 0.1

func before_all():
	product_blueprint.production_time = production_time
	product_blueprint.id = "some id"
	product_blueprint.finished_scene = null
	product_blueprint.required_resources = {}

func before_each():
	factory = factory_component.instantiate()
	get_tree().root.add_child(factory)


class TestQueueingAndProductionFlow:
	extends GutTest

	var factory_component = preload("res://domains/factory/components/factory_component.tscn")
	var product_blueprint = preload("res://domains/factory/resources/product_blueprint.tres")

	var factory: FactoryComponent
	var production_time := 0.1

	func before_all():
		product_blueprint.production_time = production_time
		product_blueprint.id = "some id"
		product_blueprint.finished_scene = null
		product_blueprint.required_resources = {}

	func before_each():
		factory = factory_component.instantiate()
		get_tree().root.add_child(factory)
		watch_signals(factory)
	
	func after_each():
		get_tree().root.remove_child(factory)

	# Test that production starts automatically when new tasks are added to an empty queue and production_started signal is emitted
	func test_production_starts_with_new_tasks():
		factory.queue_production(product_blueprint, 1)
		
		assert_signal_emitted(factory, "production_started")

	# Test that production continues to the next task when the current task is completed, and the production_completed signal is emitted for each completed task
	func test_production_continues_to_next_task():
		var amount = 2
		
		factory.queue_production(product_blueprint, amount)
		for i in amount:
			await wait_for_signal(factory.production_completed, 1)
		
		assert_signal_emit_count(factory, "production_completed", amount)

	# Test that production can be started again after aborting production and the appropriate signals are emitted
	func test_production_after_abort():
		var seconds = production_time + 0.1

		factory.queue_production(product_blueprint, 1)
		factory.abort_production()
		await wait_for_signal(factory.production_aborted, 1)
		factory.queue_production(product_blueprint, 1)
		await wait_for_signal(factory.production_completed, 1)
		
		assert_signal_emitted(factory, "production_aborted")
		assert_signal_emitted(factory, "production_started")
		assert_signal_emit_count(factory, "production_completed", 2)

	# Test that calling queue_production multiple times extends the queue and tasks are processed in the correct order
	func test_queue_production_extends_queue():
		factory.queue_production(product_blueprint, 1)
		await wait_for_signal(factory.production_completed, 1)
		factory.queue_production(product_blueprint, 2)
		await wait_for_signal(factory.production_completed, 1)
		await wait_for_signal(factory.production_completed, 1)
		
		assert_signal_emit_count(factory, "production_completed", 3)


class TestPausingResumingProduction:
	extends GutTest

	var factory_component = preload("res://domains/factory/components/factory_component.tscn")
	var product_blueprint = preload("res://domains/factory/resources/product_blueprint.tres")

	var factory: FactoryComponent
	var production_time := 0.1

	func before_all():
		product_blueprint.production_time = production_time
		product_blueprint.id = "some id"
		product_blueprint.finished_scene = null
		product_blueprint.required_resources = {}

	func before_each():
		factory = factory_component.instantiate()
		get_tree().root.add_child(factory)
		watch_signals(factory)

	func after_each():
		get_tree().root.remove_child(factory)

	# Test that production is paused when calling pause_production, and the production_paused signal is emitted
	func test_pause_production():
		factory.queue_production(product_blueprint, 1)
		factory.pause_production()
		await wait_seconds(production_time + 0.1)
		
		assert_signal_not_emitted(factory, "production_completed")
		assert_signal_emitted(factory, "production_paused")

	# Test that production resumes when calling resume_production and the appropriate signals are emitted
	func test_resume_production():
		factory.queue_production(product_blueprint, 1)
		factory.pause_production()
		factory.resume_production()
		await wait_for_signal(factory.production_completed, 1)

		assert_signal_emit_count(factory, "production_completed", 1)

	# Test that calling pause_production and resume_production multiple times does not cause side effects and production continues as expected
	func test_pause_and_resume_multiple_times():
		var amount = 3

		factory.queue_production(product_blueprint, amount)
		for _i in range(amount):
			factory.pause_production()
			factory.resume_production()
		for _i in range(amount):
			await wait_for_signal(factory.production_completed, 1)

		assert_signal_emit_count(factory, "production_completed", amount)


class TestAbortingProduction:
	extends GutTest

	var factory_component = preload("res://domains/factory/components/factory_component.tscn")
	var product_blueprint = preload("res://domains/factory/resources/product_blueprint.tres")

	var factory: FactoryComponent
	var production_time := 0.1

	func before_all():
		product_blueprint.production_time = production_time
		product_blueprint.id = "some id"
		product_blueprint.finished_scene = null
		product_blueprint.required_resources = {}

	func before_each():
		factory = factory_component.instantiate()
		get_tree().root.add_child(factory)
		watch_signals(factory)

	func after_each():
		get_tree().root.remove_child(factory)

	# Test that all tasks are removed from the queue when calling abort_production, and the production_aborted signal is emitted
	func test_abort_production_removes_all_tasks():
		factory.queue_production(product_blueprint, 3)
		factory.abort_production()

		assert_signal_emitted(factory, "production_aborted")
		await wait_seconds(production_time * 4)
		assert_signal_not_emitted(factory, "production_completed")

	# Test that the current task is canceled when aborting production and the production_aborted signal is emitted
	func test_abort_production_cancels_current_task():
		factory.queue_production(product_blueprint, 1)
		factory.abort_production()

		assert_signal_emitted(factory, "production_aborted")
		await wait_seconds(production_time * 2)
		assert_signal_not_emitted(factory, "production_completed")

	# Test that calling abort_production multiple times has no side effects and the production_aborted signal is emitted only once
	func test_abort_production_multiple_times():
		factory.queue_production(product_blueprint, 1)
		factory.abort_production()
		factory.abort_production()

		assert_signal_emit_count(factory, "production_aborted", 1)


class TestEdgeCases:
	extends GutTest

	var factory_component = preload("res://domains/factory/components/factory_component.tscn")
	var product_blueprint = preload("res://domains/factory/resources/product_blueprint.tres")

	var factory: FactoryComponent
	var production_time := 0.1

	func before_all():
		product_blueprint.production_time = production_time
		product_blueprint.id = "some id"
		product_blueprint.finished_scene = null
		product_blueprint.required_resources = {}

	func before_each():
		factory = factory_component.instantiate()
		get_tree().root.add_child(factory)
		watch_signals(factory)

	func after_each():
		get_tree().root.remove_child(factory)

	# Test that pausing production during the timer's timeout does not cause issues and the appropriate signals are emitted
	func test_pause_production_during_timeout():
		factory.queue_production(product_blueprint, 1)
		await wait_seconds(production_time / 2)
		factory.pause_production()

		assert_signal_emitted(factory, "production_paused")
		await wait_seconds(production_time * 2)
		assert_signal_not_emitted(factory, "production_completed")

	# Test that aborting production during the timer's timeout does not cause issues and the appropriate signals are emitted
	func test_abort_production_during_timeout():
		factory.queue_production(product_blueprint, 1)
		await wait_seconds(production_time / 2)
		factory.abort_production()

		assert_signal_emitted(factory, "production_aborted")
		await wait_seconds(production_time * 2)
		assert_signal_not_emitted(factory, "production_completed")

	# Test that calling queue_production during the timer's timeout does not cause issues and the appropriate signals are emitted
	func test_queue_production_during_timeout():
		factory.queue_production(product_blueprint, 1)
		await wait_seconds(production_time / 2)
		factory.queue_production(product_blueprint, 1)

		await wait_for_signal(factory.production_completed, 1)
		await wait_for_signal(factory.production_completed, 1)

		assert_signal_emit_count(factory, "production_completed", 2)
		
	
	# Test that no signals are emitted when calling pause_production or resume_production on an empty queue.
	func test_no_signals_on_pause_resume_empty_queue():
		factory.pause_production()
		factory.resume_production()

		assert_signal_not_emitted(factory, "production_paused")
		assert_signal_not_emitted(factory, "production_started")

	# Test that no signals are emitted when calling abort_production on an empty queue.
	func test_no_signals_on_abort_empty_queue():
		factory.abort_production()

		assert_signal_not_emitted(factory, "production_aborted")


class TestProductionTimingAndCompletion:
	extends GutTest

	var factory_component = preload("res://domains/factory/components/factory_component.tscn")
	var product_blueprint = preload("res://domains/factory/resources/product_blueprint.tres")

	var factory: FactoryComponent
	var production_time := 0.1

	func before_all():
		product_blueprint.production_time = production_time
		product_blueprint.id = "some id"
		product_blueprint.finished_scene = null
		product_blueprint.required_resources = {}

	func before_each():
		factory = factory_component.instantiate()
		get_tree().root.add_child(factory)
		watch_signals(factory)

	func after_each():
		get_tree().root.remove_child(factory)

	# Test that the task completion time is based on the ProductBlueprint.production_time value by observing the time difference between the production_started and production_completed signals
	func test_task_completion_based_on_production_time():
		var start_time = Time.get_ticks_msec()

		factory.queue_production(product_blueprint, 1)
		await wait_for_signal(factory.production_completed, 1)

		var end_time = Time.get_ticks_msec()
		var elapsed_time = (end_time - start_time) / 1000.0

		assert_almost_eq(elapsed_time, production_time, 0.05, "Task completion time should be based on ProductBlueprint.production_time")

	# Test that no tasks are processed when the queue is empty
	func test_no_tasks_processed_when_queue_empty():
		await wait_seconds(production_time * 2)

		assert_signal_not_emitted(factory, "production_started")
		assert_signal_not_emitted(factory, "production_completed")
	
	# Test that production does not start automatically when the queue is empty.
	func test_no_automatic_production_on_empty_queue():
		await wait_seconds(production_time * 2)

		assert_signal_not_emitted(factory, "production_started")


class TestProductBlueprints:
	extends GutTest
	var factory_component = preload("res://domains/factory/components/factory_component.tscn")
	var product_blueprint = preload("res://domains/factory/resources/product_blueprint.tres")
	var another_product_blueprint = preload("res://domains/factory/resources/product_blueprint.tres")

	var factory: FactoryComponent
	var production_time := 0.1

	func before_all():
		product_blueprint.production_time = production_time
		product_blueprint.id = "some id"
		product_blueprint.finished_scene = null
		product_blueprint.required_resources = {}

		another_product_blueprint.production_time = production_time * 2
		another_product_blueprint.id = "another id"
		another_product_blueprint.finished_scene = null
		another_product_blueprint.required_resources = {}

	func before_each():
		factory = factory_component.instantiate()
		get_tree().root.add_child(factory)
		watch_signals(factory)

	func after_each():
		get_tree().root.remove_child(factory)

	# Test that the production queue works correctly with multiple different ProductBlueprint instances.
	func test_production_queue_with_different_product_blueprints():
		factory.queue_production(product_blueprint, 1)
		factory.queue_production(another_product_blueprint, 1)

		await wait_for_signal(factory.production_completed, 1)
		assert_signal_emitted(factory, "production_completed", product_blueprint.id)
		await wait_for_signal(factory.production_completed, 1)
		assert_signal_emitted(factory, "production_completed", another_product_blueprint.id)

	# Test that production continues even if the same ProductBlueprint is added to the queue multiple times.
	func test_production_queue_with_same_product_blueprints():
		factory.queue_production(product_blueprint, 1)
		factory.queue_production(product_blueprint, 1)

		await wait_for_signal(factory.production_completed, 1)
		assert_signal_emitted(factory, "production_completed", product_blueprint.id)
		await wait_for_signal(factory.production_completed, 1)
		assert_signal_emitted(factory, "production_completed", product_blueprint.id)
