class_name BoolSF extends StatefulType

var value: bool = false:
    set(_value):
        value = _value
        changed.emit(value)
signal changed(new_value: bool)