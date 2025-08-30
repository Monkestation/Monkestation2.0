/datum/enchantment/electricution
	max_level = 3
	examine_description = "It has been blessed with the power of electricity and will shock targets."

/datum/enchantment/electricution/register_item(obj/item/target)
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(shock_target))

/datum/enchantment/electricution/unregister_item(obj/item/target)
	UnregisterSignal(target, COMSIG_ITEM_ATTACK)

/datum/enchantment/electricution/proc/shock_target(obj/item/source, atom/movable/target, mob/living/user)
	user.Beam(target, icon_state = "lightning[rand(1,12)]", time = 2, maxdistance = 32)
	if(!iscarbon(target))
		return
	var/datum/component/enchanted/comp = get_component_from_parent(source)
	if(!comp)
		return

	var/mob/living/carbon/carbon_target = target
	if(carbon_target.electrocute_act(comp.level * 3, user, 1, SHOCK_NOSTUN)) //need to make this ark, also this seems to work on any living mob
		carbon_target.visible_message(span_danger("[user] electrocutes [target]!"), span_userdanger("[user] electrocutes you!"))
