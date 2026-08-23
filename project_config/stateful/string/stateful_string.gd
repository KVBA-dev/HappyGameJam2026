class_name StringSF extends StatefulType


var value: String = "":
    set(_value):
        value = _value
        changed.emit(value)
signal changed(new_value: String)