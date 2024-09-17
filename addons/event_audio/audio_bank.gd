extends Node
class_name AudioBank
@export var _audioBankResource : AudioBankResource
# @export var audioBankResources: Array[AudioBankResource]

func _enter_tree():
    var player = EventAudio.instance
    player.register_bank_resource(_audioBankResource)
    # for bank_resource: AudioBankResource in audioBankResources:
    #     player.register_bank_resource(bank_resource)
            
func _exit_tree():
    var player = EventAudio.instance
    player.unregister_bank_resource(_audioBankResource)

    # for bank_resource: AudioBankResource in audioBankResources:
    #     player.unregister_bank_resource(bank_resource)
    
