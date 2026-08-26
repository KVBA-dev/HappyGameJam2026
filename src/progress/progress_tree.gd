class_name ProgressTree extends Resource

@export var goal: ProgressBatch:
	set(value):
		goal = value
		rebuild()

var currently_available_batches: Array[ProgressBatch] = []
var spawned_batches: Array[ProgressBatch] = []

func rebuild() -> void:
	currently_available_batches.clear()
	spawned_batches.clear()

	if goal == null:
		return

	var pending_batches: Array[ProgressBatch] = [goal]
	var discovered_batches: Dictionary[ProgressBatch, bool] = {goal: true}

	while len(pending_batches):
		var batch: ProgressBatch = pending_batches.pop_front()
		if batch.prequisites.is_empty():
			if not currently_available_batches.has(batch):
				currently_available_batches.append(batch)
			continue

		for prequisite: ProgressBatch in batch.prequisites:
			if prequisite == null:
				continue

			if not discovered_batches.has(prequisite):
				discovered_batches[prequisite] = true
				pending_batches.append(prequisite)

			if not prequisite.following.has(batch):
				prequisite.following.append(batch)



func get_batch() -> ProgressBatch:
	if currently_available_batches.is_empty():
		return null

	var batch: ProgressBatch = currently_available_batches.pick_random()
	currently_available_batches.erase(batch)
	spawned_batches.append(batch)

	for potential_next_batch: ProgressBatch in batch.following:
		if _batch_prequsites_filled(potential_next_batch.prequisites):
			currently_available_batches.append(potential_next_batch)

	return batch

func _batch_prequsites_filled(prequisites: Array[ProgressBatch]):
	for prequisite: ProgressBatch in prequisites:
		if not spawned_batches.has(prequisite):
			return false
	return true
