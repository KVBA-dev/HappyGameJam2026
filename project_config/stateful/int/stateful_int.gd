class_name IntSF extends StatefulType


var value: int = 0:
    set(_value):
        value = _value
        changed.emit(value)
signal changed(new_value: int)