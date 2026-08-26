class_name ProgressBatch extends Resource

@export var buildings: Array[HexData]
@export var prequisites: Array[ProgressBatch]
var following: Array[ProgressBatch] = [] # Set on runtime what's next
