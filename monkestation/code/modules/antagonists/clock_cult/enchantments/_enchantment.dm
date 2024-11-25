/datum/component/enchantment
	///Examine text
	var/examine_description
	///Maximum enchantment level
	var/max_level = 1
	///Current enchantment level
	var/level
	///The span we warp our examine text in
	var/used_span = "<span class='purple'>"

/datum/component/enchantment/Initialize(level_override)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(on_reebe(parent)) //currently this is only added by stargazers so this should work fine
		max_level = 1

	level = level_override || rand(1, max_level)
	apply_effect(parent)
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/enchantment/Destroy()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	return ..()

/datum/component/enchantment/proc/apply_effect(obj/item/target)
	return

/datum/component/enchantment/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!examine_description)
		return

	if(isobserver(user) || HAS_MIND_TRAIT(user, TRAIT_MAGICALLY_GIFTED))
		if(used_span)
			examine_list += "[used_span][examine_description]</span>"
			examine_list += "[used_span]It's blessing has a power of [level]!</span>"
			return
		examine_list += "[examine_description]"
		examine_list += "It's blessing has a power of [level]!"
	else
		examine_list += "It is glowing slightly!"
		var/mob/living/living_user = user
		if(istype(living_user.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses/science))
			examine_list += "It emits a readable EMF factor of [level]."
