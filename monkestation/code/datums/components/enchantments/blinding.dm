/datum/enchantment/blinding
	examine_description = "It has been blessed with the power to emit a blinding light when striking a target."
	max_level = 1

/datum/enchantment/blinding/register_item(obj/item/target)
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(flash_target))

/datum/enchantment/blinding/unregister_item(obj/item/target)
	UnregisterSignal(target, COMSIG_ITEM_ATTACK)

/datum/enchantment/blinding/proc/flash_target(obj/item/source, mob/living/target, mob/living/user)
	if(!istype(target))
		return
	source.visible_message(span_danger("\The [source] emits a blinding light!"))
	target.flash_act(2, affect_silicon = TRUE, length = 3 SECONDS) //might want to make this not effect borgs
