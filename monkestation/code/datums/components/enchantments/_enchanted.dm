/datum/component/enchanted
	dupe_mode = COMPONENT_DUPE_ALLOWED
	///Current enchantment level
	var/level
	///The span we warp our examine text in
	var/used_span = "<span class='purple'>"
	///A ref to the enchantment datum we are using
	var/datum/enchantment/used_enchantment
	///A list of all enchantments
	var/static/list/all_enchantments

/datum/component/enchanted/Initialize(level_override)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	//if(on_reebe(parent)) currently this is only added by stargazers so this should work fine
	//	max_level = 1

	//level = level_override || rand(1, max_level)

/datum/component/enchanted/RegisterWithParent()
	var/list/component_list = used_enchantment.components_by_parent[parent]
	if(!component_list)
		used_enchantment.components_by_parent[parent] = list(used_enchantment = src)
	else
		component_list[used_enchantment] = src
	used_enchantment.apply_effect(parent, level)
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/enchanted/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	var/list/component_list = used_enchantment.components_by_parent[parent]
	component_list -= used_enchantment
	if(!length(component_list))
		used_enchantment.components_by_parent -= parent

/datum/component/enchanted/Destroy(force)
	used_enchantment = null
	return ..()

/datum/component/enchanted/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!used_enchantment.examine_description)
		return

	if(isobserver(user) || HAS_MIND_TRAIT(user, TRAIT_MAGICALLY_GIFTED))
		if(used_span)
			examine_list += "[used_span][used_enchantment.examine_description]</span>"
			examine_list += "[used_span]It's blessing has a power of [level]!</span><br/>"
			return
		examine_list += "[used_enchantment.examine_description]"
		examine_list += "It's blessing has a power of [level]!<br/>"
	else
		examine_list += "It is glowing slightly!"
		var/mob/living/living_user = user
		if(istype(living_user.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses/science))
			examine_list += "It emits a readable EMF factor of [level]."

/datum/enchantment
	///Examine text
	var/examine_description
	///Maximum enchantment level
	var/max_level = 1
	///What type of items are we allowed on
	var/list/allowed_on = list(/obj/item)
	///What type of items are we NOT allowed on
	var/list/denied_from = list(/obj/item/clothing)
	///A recursive assoc list keyed as: [parent] = list(enchant_component.used_enchantment = enchant_component)
	var/static/list/list/datum/component/enchanted/components_by_parent = list()

/datum/enchantment/New()
	. = ..()
	if(!islist(allowed_on))
		allowed_on = list(allowed_on)

/datum/enchantment/proc/apply_effect(obj/item/target, level)
	register_item(target)

/datum/enchantment/proc/register_item(obj/item/target)
	return

/datum/enchantment/proc/unregister_item(obj/item/target)
	return
