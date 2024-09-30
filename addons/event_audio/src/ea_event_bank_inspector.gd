@tool
extends EditorInspectorPlugin

func _can_handle(object):
    return object is EAEventBank

func _parse_property(_object, _type, name, _hint_type, _hint_string, _usage_flags, _wide):
    if name == "entries":
        add_property_editor(name, EAEventBankProperty.new())
        return true
    return false
