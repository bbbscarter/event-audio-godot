@tool
extends Resource
class_name EAEventBank

@export var entries: Array[EAEvent]
    
func add_entry():
    entries.insert(0, EAEvent.new())

func delete_entry(entry: EAEvent):
    var entry_idx := entries.find(entry)
    if entry_idx >= 0:
        entries.remove_at(entry_idx)

func find_entry_with_trigger(trigger: String) -> EAEvent:
    for entry: EAEvent in entries:
        if entry.trigger_tags == trigger:
            return entry

    return null
        
func _sort_func(a: EAEvent, b: EAEvent) -> bool:
    return a.trigger_tags < b.trigger_tags
    
func sort_by_trigger():
    entries.sort_custom(_sort_func)
 
