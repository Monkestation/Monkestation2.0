GLOBAL_LIST_EMPTY(enchantment_datums_by_type)

/datum/component/enchanted
	dupe_mode = COMPONENT_DUPE_ALLOWED
	///Current enchantment level
	var/level
	///The span we warp our examine text in
	var/used_span
	///A ref to the enchantment datum we are using
	var/datum/enchantment/used_enchantment
	//need to add a source ID var

/datum/component/enchanted/Initialize(list/select_enchants_from = subtypesof(/datum/enchantment), used_span = "<span class='purple'>", level_override)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(!length(select_enchants_from))
		stack_trace("[src.type] calling Initialize with unset select_enchants_from.")
		return COMPONENT_INCOMPATIBLE

	for(var/entry in select_enchants_from)
		if(ispath(entry))
			select_enchants_from -= entry
			select_enchants_from += GLOB.enchantment_datums_by_type[entry]

	used_enchantment = pick(select_enchants_from)
	src.used_span = used_span
	level = level_override || rand(1, used_enchantment.max_level)

/datum/component/enchanted/RegisterWithParent()
	var/list/component_list = used_enchantment.components_by_parent[parent]
	if(!component_list)
		used_enchantment.components_by_parent[parent] = list(used_enchantment = src) //used_enchantment is not being taken as a ref?
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

///Increase the level of this enchantment
/datum/component/enchanted/proc/increase_level(increase_by, forced)
	if(!forced && level >= used_enchantment.max_level)
		return FALSE

	increase_by = min(used_enchantment.max_level - level, increase_by)
	level += increase_by
	used_enchantment.apply_effect(parent, increase_by, TRUE)

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
	///Typecache of items we are allowed on, generation handled in get_allowed_on
	var/list/allowed_on
	///A recursive assoc list keyed as: [obj/item/parent] = list(enchant_component.used_enchantment = enchant_component)
	var/static/list/list/datum/component/enchanted/components_by_parent = list()

/datum/enchantment/New()
	. = ..()
	allowed_on = get_allowed_on()

/**
 * Because of dumb BYOND reasons in order to get fine manual control we need to handle generation of allowed_on this way(via setting the default passed values)
 *
 * allowed_on_base - Typecache of items we are allowed on
 *
 * denied_from - Anything in this list will be set to FALSE in allowed_on
 *
 * overriden_types - Any values in this list will override allowed_on, this is handled last
 */
/datum/enchantment/proc/get_allowed_on(list/allowed_on_base = typecacheof(/obj/item), list/denied_from = typesof(/obj/item/clothing), list/overriden_types = list()) //AHHHHH
	if(denied_from)
		for(var/denied_entry in denied_from)
			allowed_on_base[denied_entry] = 0
	if(overriden_types)
		for(var/entry in overriden_types)
			allowed_on_base[entry] = overriden_types[entry]
	return allowed_on_base

/datum/enchantment/proc/get_component_from_parent(obj/item/parent) as /datum/component/enchanted
	RETURN_TYPE(/datum/component/enchanted)
	var/list/parent_list = components_by_parent[parent]
	if(!parent_list)
		return null
	return parent_list[src]

/datum/enchantment/proc/can_apply_to(obj/item/checked)
	return allowed_on[checked.type] && examine_description

/datum/enchantment/proc/apply_effect(obj/item/target, level, upgrading = FALSE)
	if(!upgrading)
		register_item(target)

///Handle comsig reg here
/datum/enchantment/proc/register_item(obj/item/target)
	return

///Handle comsig unreg here
/datum/enchantment/proc/unregister_item(obj/item/target)
	return

/datum/enchantment/clothing

/datum/enchantment/clothing/get_allowed_on(list/allowed_on_base = typecacheof(/obj/item/clothing), list/denied_from = list(), list/overriden_types)
	return ..()
