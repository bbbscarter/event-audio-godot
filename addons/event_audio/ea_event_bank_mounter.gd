extends Node
class_name EAEventBankMounter
@export var _audioBankResource : EAEventBank
# @export var audioBankResources: Array[EAEventBank]

func _enter_tree():
    var player = EventAudio.instance
    player.register_bank_resource(_audioBankResource)
    # for bank_resource: EAEventBank in audioBankResources:
    #     player.register_bank_resource(bank_resource)
            
func _exit_tree():
    var player = EventAudio.instance
    player.unregister_bank_resource(_audioBankResource)

    # for bank_resource: EAEventBank in audioBankResources:
    #     player.unregister_bank_resource(bank_resource)
    
