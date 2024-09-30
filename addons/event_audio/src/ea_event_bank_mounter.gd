extends Node
class_name EAEventBankMounter
@export var _audio_bank_resource : EAEventBank
# @export var audioBankResources: Array[EAEventBank]

func _enter_tree():
    var player := EventAudio.instance
    player.register_event_bank(_audio_bank_resource)
            
func _exit_tree():
    var player := EventAudio.instance
    player.unregister_event_bank(_audio_bank_resource)
    
