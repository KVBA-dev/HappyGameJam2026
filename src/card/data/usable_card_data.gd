class_name UsableCardData extends CardData

enum UsableType {
    DUPLICATE = 0,
    DELETE = 1,
    BACK_TO_HAND = 2,
}

@export var usable_type: UsableType