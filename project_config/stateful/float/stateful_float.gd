class_name FloatSF extends StatefulType

var value: float = 0.0:
    set(_value):
        value = _value
        changed.emit(value)
signal changed(new_value: float)