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



func get_batch() -> Array[ProgressBatch]:
	if currently_available_batches.is_empty():
		return []

	var candidates: Array[ProgressBatch] = []
	for available_batch: ProgressBatch in currently_available_batches:
		if (
			not available_batch.prequisites.is_empty()
			and _batch_can_be_returned(available_batch)
		):
			candidates.append(available_batch)

		for following_batch: ProgressBatch in available_batch.following:
			if (
				not candidates.has(following_batch)
				and _batch_can_be_returned(following_batch)
			):
				candidates.append(following_batch)

	if candidates.is_empty():
		return []

	var selected_batch: ProgressBatch = candidates.pick_random()
	var batches: Array[ProgressBatch] = [selected_batch]

	for prequisite: ProgressBatch in selected_batch.prequisites:
		if (
			not spawned_batches.has(prequisite)
			and prequisite.prequisites.is_empty()
			and currently_available_batches.has(prequisite)
		):
			batches.append(prequisite)

	return batches

func confirm_batches_spawned(batches: Array[ProgressBatch]) -> void:
	for batch: ProgressBatch in batches:
		if spawned_batches.has(batch):
			continue
		currently_available_batches.erase(batch)
		spawned_batches.append(batch)

	for batch: ProgressBatch in batches:
		for potential_next_batch: ProgressBatch in batch.following:
			if (
				_batch_prequsites_filled(potential_next_batch.prequisites)
				and not currently_available_batches.has(potential_next_batch)
				and not spawned_batches.has(potential_next_batch)
			):
				currently_available_batches.append(potential_next_batch)

func _batch_can_be_returned(batch: ProgressBatch) -> bool:
	if batch == null or batch.prequisites.is_empty() or spawned_batches.has(batch):
		return false

	for prequisite: ProgressBatch in batch.prequisites:
		if spawned_batches.has(prequisite):
			continue
		if (
			prequisite.prequisites.is_empty()
			and currently_available_batches.has(prequisite)
		):
			continue
		return false

	return true

func _batch_prequsites_filled(prequisites: Array[ProgressBatch]):
	for prequisite: ProgressBatch in prequisites:
		if not spawned_batches.has(prequisite):
			return false
	return true
