/**
 * Bitrunning tech disks which let you load items or programs into the vdom on first avatar generation.
 * For the record: Balance shouldn't be a primary concern.
 * You can make the custom cheese spells you've always wanted.
 * Just make it fun and engaging, it's PvE content.
 */
/obj/item/bitrunning_disk
	name = "generic bitrunning program"
	desc = "A disk containing source code."
	icon = 'icons/obj/assemblies/module.dmi'
	base_icon_state = "datadisk"
	icon_state = "datadisk0"
	w_class = WEIGHT_CLASS_TINY

	/// Name of the choice made
	var/choice_made
	var/uses_random_icons = FALSE

/obj/item/bitrunning_disk/Initialize(mapload)
	. = ..()
	if(uses_random_icons)
		icon_state = "[base_icon_state][rand(0, 7)]"
	RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))

/obj/item/bitrunning_disk/proc/on_examined(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_infoplain("This disk must be carried on your person into a netpod to be used.")

	if(isnull(choice_made))
		examine_text += span_notice("To make a selection, toggle the disk in hand.")
		return

	examine_text += span_info("It has been used to select: <b>[choice_made]</b>.")
	examine_text += span_notice("It cannot make another selection.")

/obj/item/bitrunning_disk/ability
	desc = "A disk containing source code. It can be used to preload abilities into the virtual domain."
	/// The selected ability that this grants
	var/datum/action/granted_action
	/// The list of actions that this can grant
	var/list/datum/action/selectable_actions = list()

/obj/item/bitrunning_disk/ability/attack_self(mob/user, modifiers)
	. = ..()

	if(choice_made)
		return

	var/names = list()
	for(var/datum/action/thing as anything in selectable_actions)
		names += initial(thing.name)

	var/choice = tgui_input_list(user, message = "Select an ability",  title = "Bitrunning Program", items = names)
	if(isnull(choice))
		return

	for(var/datum/action/thing as anything in selectable_actions)
		if(initial(thing.name) == choice)
			granted_action = thing

	if(isnull(granted_action))
		return

	balloon_alert(user, "selected")
	playsound(user, 'sound/machines/click.ogg', 50, TRUE)
	choice_made = choice

/// Tier 1 programs. Simple, funny, or helpful.
/obj/item/bitrunning_disk/ability/tier1
	name = "bitrunning program: basic"
	selectable_actions = list(
		/datum/action/cooldown/spell/conjure/cheese,
		/datum/action/cooldown/spell/basic_heal,
	)

/// Tier 2 programs. More complex, powerful, or useful.
/obj/item/bitrunning_disk/ability/tier2
	name = "bitrunning program: complex"
	selectable_actions = list(
		/datum/action/cooldown/spell/pointed/projectile/fireball,
		/datum/action/cooldown/spell/pointed/projectile/lightningbolt,
		/datum/action/cooldown/spell/forcewall,
	)

/// Tier 3 abilities. Very powerful, game breaking.
/obj/item/bitrunning_disk/ability/tier3
	name = "bitrunning program: elite"
	selectable_actions = list(
		/datum/action/cooldown/spell/shapeshift/dragon,
		/datum/action/cooldown/spell/shapeshift/polar_bear,
	)

/obj/item/bitrunning_disk/ability/single
	name = "bitrunning program: someone forgot to give me a name, please help"
	icon = 'icons/obj/items/bitrunning/ability_disks.dmi'
	icon_state = "i_am_error"
	uses_random_icons = FALSE

/obj/item/bitrunning_disk/ability/single/Initialize(mapload)
	choice_made = granted_action::name
	return ..()

/**
 * Tier 1 abilities
 */
/obj/item/bitrunning_disk/ability/single/conjure_cheese
	name = "bitrunning program: conjure cheese"
	icon_state = "cheese"
	granted_action = /datum/action/cooldown/spell/conjure/cheese

/obj/item/bitrunning_disk/ability/single/basic_heal
	name = "bitrunning program: basic heal"
	icon_state = "heal"
	granted_action = /datum/action/cooldown/spell/basic_heal

/**
 * Tier 2 abilities
 */
/obj/item/bitrunning_disk/ability/single/fireball
	name = "bitrunning program: fireball"
	icon_state = "fireball"
	granted_action = /datum/action/cooldown/spell/pointed/projectile/fireball

/obj/item/bitrunning_disk/ability/single/lightningbolt
	name = "bitrunning program: lightning bolt"
	icon_state = "lightning"
	granted_action = /datum/action/cooldown/spell/pointed/projectile/lightningbolt

/obj/item/bitrunning_disk/ability/single/forcewall
	name = "bitrunning program: forcewall"
	icon_state = "forcewall"
	granted_action = /datum/action/cooldown/spell/forcewall

/**
 * Tier 3 abilities
 */
/obj/item/bitrunning_disk/ability/single/dragon
	name = "bitrunning program: shapeshift, dragon"
	icon_state = "dragon"
	granted_action = /datum/action/cooldown/spell/shapeshift/dragon

/obj/item/bitrunning_disk/ability/single/polar_bear
	name = "bitrunning program: shapeshift, polar bear"
	icon_state = "bear"
	granted_action = /datum/action/cooldown/spell/shapeshift/polar_bear

/obj/item/bitrunning_disk/item
	desc = "A disk containing source code. It can be used to preload items into the virtual domain."
	/// The selected item that this grants
	var/obj/granted_item
	/// The list of actions that this can grant
	var/list/obj/selectable_items = list()

/obj/item/bitrunning_disk/item/attack_self(mob/user, modifiers)
	. = ..()

	if(granted_item)
		return

	if(choice_made)
		return

	var/names = list()
	for(var/obj/thing as anything in selectable_items)
		names += initial(thing.name)

	var/choice = tgui_input_list(user, message = "Select an ability",  title = "Bitrunning Program", items = names)
	if(isnull(choice))
		return

	for(var/obj/thing as anything in selectable_items)
		if(initial(thing.name) == choice)
			granted_item = thing

	balloon_alert(user, "selected")
	playsound(user, 'sound/machines/click.ogg', 50, TRUE)
	choice_made = choice

/// Tier 1 items. Simple, funny, or helpful.
/obj/item/bitrunning_disk/item/tier1
	name = "bitrunning gear: simple"
	selectable_items = list(
		/obj/item/pizzabox/infinite,
		/obj/item/gun/medbeam,
		/obj/item/grenade/c4,
	)

/// Tier 2 items. More complex, powerful, or useful.
/obj/item/bitrunning_disk/item/tier2
	name = "bitrunning gear: complex"
	selectable_items = list(
		/obj/item/chainsaw,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/melee/energy/blade/hardlight,
	)

/// Tier 3 items. Very powerful, game breaking.
/obj/item/bitrunning_disk/item/tier3
	name = "bitrunning gear: advanced"
	selectable_items = list(
		/obj/item/gun/energy/tesla_cannon,
		/obj/item/dualsaber/green,
		/obj/item/melee/beesword,
	)

/obj/item/bitrunning_disk/item/single
	name = "bitrunning gear: someone forgot to give me a name, please help"
	icon = 'icons/obj/items/bitrunning/item_disks.dmi'
	icon_state = "i_am_error"
	uses_random_icons = TRUE

/obj/item/bitrunning_disk/item/single/Initialize(mapload)
	choice_made = granted_item::name
	return ..()

/**
 * Tier 1 combat gear
 */
/obj/item/bitrunning_disk/item/single/pizza
	name = "bitrunning gear: infinite pizzabox"
	icon_state = "pizza"
	granted_item = /obj/item/pizzabox/infinite

/obj/item/bitrunning_disk/item/single/medbeam
	name = "bitrunning gear: Medical Beamgun"
	icon_state = "beamgun"
	granted_item = /obj/item/gun/medbeam

/obj/item/bitrunning_disk/item/single/c4
	name = "bitrunning gear: C4 explosive charge"
	icon_state = "c4"
	granted_item = /obj/item/grenade/c4

/**
 * Tier 2 combat gear
 */
/obj/item/bitrunning_disk/item/single/chainsaw
	name = "bitrunning gear: chainsaw"
	icon_state = "chainsaw"
	granted_item = /obj/item/chainsaw

/obj/item/bitrunning_disk/item/single/pistol
	name = "bitrunning gear: makarov pistol"
	icon_state = "pistol"
	granted_item = /obj/item/gun/ballistic/automatic/pistol

/obj/item/bitrunning_disk/item/single/hardlight_blade
	name = "bitrunning gear: hardlight blade"
	icon_state = "hardlight_blade"
	granted_item = /obj/item/melee/energy/blade/hardlight

/**
 * Tier 3 combat gear
 */
/obj/item/bitrunning_disk/item/single/tesla_cannon
	name = "bitrunning gear: tesla cannon"
	icon_state = "tesla"
	granted_item = /obj/item/gun/energy/tesla_cannon

/obj/item/bitrunning_disk/item/single/dualsaber
	name = "bitrunning gear: double-bladed energy sword"
	icon_state = "energy_blade"
	granted_item = /obj/item/dualsaber/green

/obj/item/bitrunning_disk/item/single/beesword
	name = "bitrunning gear: the stinger blade"
	icon_state = "bee"
	granted_item = /obj/item/melee/beesword

///proto-kinetic accelerator mods, to be applied to pka's given inside domains
/obj/item/bitrunning_disk/item/single/pka_mods
	name = "bitrunning gear: proto-kinetic accelerator mods"
	icon_state = "pka"
	granted_item = list(
		/obj/item/borg/upgrade/modkit/range,
		/obj/item/borg/upgrade/modkit/damage,
		/obj/item/borg/upgrade/modkit/cooldown,
		/obj/item/borg/upgrade/modkit/aoe/mobs,
	)

/obj/item/bitrunning_disk/item/single/pka_mods/premium
	name = "bitrunning gear: premium proto-kinetic accelerator mods"
	icon_state = "pka+"
	granted_item = list(
		/obj/item/borg/upgrade/modkit/cooldown/repeater,
		/obj/item/borg/upgrade/modkit/lifesteal,
		/obj/item/borg/upgrade/modkit/resonator_blasts,
		/obj/item/borg/upgrade/modkit/bounty,
		/obj/item/borg/upgrade/modkit/indoors,
	)

///proto-kinetic crusher trophies, to be applied to pkc's given inside domains
/obj/item/bitrunning_disk/item/single/pkc_mods
	name = "bitrunning gear: proto-kinetic crusher mods"
	icon_state = "crusher"
	granted_item = list(
		/obj/item/crusher_trophy/watcher_wing,
		/obj/item/crusher_trophy/blaster_tubes/magma_wing,
		/obj/item/crusher_trophy/legion_skull,
		/obj/item/crusher_trophy/wolf_ear,
	)

/obj/item/bitrunning_disk/item/single/pkc_mods/premium
	name = "bitrunning gear: premium proto-kinetic crusher mods"
	icon_state = "crusher+"
	granted_item = list(
		/obj/item/crusher_trophy/watcher_wing/ice_wing,
		/obj/item/crusher_trophy/blaster_tubes,
		/obj/item/crusher_trophy/miner_eye,
		/obj/item/crusher_trophy/tail_spike,
		/obj/item/crusher_trophy/demon_claws,
		/obj/item/crusher_trophy/vortex_talisman,
		/obj/item/crusher_trophy/ice_demon_cube,
	)

