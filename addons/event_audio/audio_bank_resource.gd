@tool
extends Resource
class_name AudioBankResource

@export var entries: Array[AudioBankEntry]
    
func add_entry():
    entries.insert(0, AudioBankEntry.new())

func delete_entry(entry: AudioBankEntry):
    var entry_idx := entries.find(entry)
    if entry_idx >= 0:
        entries.remove_at(entry_idx)

func find_entry_with_trigger(trigger: String) -> AudioBankEntry:
    for entry: AudioBankEntry in entries:
        if entry.trigger_tags == trigger:
            return entry

    return null
        
func _sort_func(a: AudioBankEntry, b: AudioBankEntry) -> bool:
    return a.trigger_tags < b.trigger_tags
    
func sort_by_trigger():
    entries.sort_custom(_sort_func)
 
