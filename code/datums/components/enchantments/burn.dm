/datum/enchantment/burn
	examine_description = "It has been blessed with the power of fire and will set struck targets on fire."
	max_level = 3

/datum/enchantment/burn/apply_effect(obj/item/target, level)
	. = ..()
	target.damtype = BURN

/datum/enchantment/burn/register_item(obj/item/target)
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(burn_target))

/datum/enchantment/burn/unregister_item(obj/item/target)
	UnregisterSignal(target, COMSIG_ITEM_ATTACK)
	return ..()

/datum/enchantment/burn/proc/burn_target(obj/item/source, atom/movable/target, mob/living/user)
	if(!isliving(target))
		return
	var/datum/component/enchanted/comp = get_component_from_parent(source)
	if(!comp)
		return

	var/mob/living/living_target = target
	living_target.adjust_fire_stacks(comp.level)
	living_target.ignite_mob()
