/datum/enchantment/soul_tap
	examine_description = "It has been blessed with the power of ripping the energy from target's souls and will heal the wielder when a target is struck."
	max_level = 3

/datum/enchantment/soul_tap/unregister_item(obj/item/target)
	UnregisterSignal(target, COMSIG_ITEM_ATTACK)

/datum/enchantment/soul_tap/register_item(obj/item/target)
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(tap_soul))

/datum/enchantment/soul_tap/proc/tap_soul(obj/item/source, mob/living/target, mob/living/user)
	if(!istype(target) || target.stat != CONSCIOUS)
		return
	var/datum/component/enchanted/comp = get_component_from_parent(source)
	if(!comp)
		return
	var/health_back = CEILING(comp.level * source.force * 0.1, 1)
	user.heal_overall_damage(health_back, health_back)
	new /obj/effect/temp_visual/heal(get_turf(user), "#eeba6b")
