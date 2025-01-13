///A simple element that lets shoes have togglable custom sounds
/datum/element/shoesteps
	var/list/custom_sounds

	var/parent
	var/sounds = TRUE
/datum/element/shoesteps/Attach(atom/movable/target)
	. = ..()
	parent = target
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_CLICK_CTRL, PROC_REF(on_ctrl_click))
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/datum/element/shoesteps/Detach(atom/source)
	. = ..()
	parent = null
	UnregisterSignal(source, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(source, COMSIG_CLICK_CTRL)
	UnregisterSignal(source, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)

/datum/element/shoesteps/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_notice("There seems to be some slots for Really Heavy Soles in the bottoms of these shoes. You could remove or add them by using Ctrl-Click.")

/datum/element/shoesteps/proc/on_ctrl_click(/mob/clicker)
	SIGNAL_HANDLER

	if(sounds)
		sounds = FALSE
	else
		sounds = TRUE

	to_chat(clicker, span_warning("[(sounds) ? "You put the heavy sole on." : "You take the heavy sole off."]"))

/datum/element/shoesteps/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(ishuman(equipper) && slot & ITEM_SLOT_FEET)
		RegisterSignal(equipper, COMSIG_MOB_PREPARE_STEP_SOUND, PROC_REF(prepare_steps))

/datum/element/shoesteps/proc/on_drop(mob/living/carbon/user, datum/source, slot)
	SIGNAL_HANDLER
	if(user.get_item_by_slot(ITEM_SLOT_FEET) == parent)
		UnregisterSignal(usr, COMSIG_MOB_PREPARE_STEP_SOUND)

/datum/element/shoesteps/proc/prepare_steps(obj/item/source, list/steps)
	SIGNAL_HANDLER

	if(sounds)
		to_chat(world, "[steps] just stepping around")
/*
GLOBAL_LIST_INIT(footstep, list(
	FOOTSTEP_WOOD = list(list(
		'sound/effects/footstep/wood1.ogg',
		'sound/effects/footstep/wood2.ogg',
		'sound/effects/footstep/wood3.ogg',
		'sound/effects/footstep/wood4.ogg',
		'sound/effects/footstep/wood5.ogg'), 100, 0),
	FOOTSTEP_FLOOR = list(list(
		'sound/effects/footstep/floor1.ogg',
		'sound/effects/footstep/floor2.ogg',
		'sound/effects/footstep/floor3.ogg',
		'sound/effects/footstep/floor4.ogg',
		'sound/effects/footstep/floor5.ogg'), 75, -1),
	FOOTSTEP_PLATING = list(list(
		'sound/effects/footstep/plating1.ogg',
		'sound/effects/footstep/plating2.ogg',
		'sound/effects/footstep/plating3.ogg',
		'sound/effects/footstep/plating4.ogg',
		'sound/effects/footstep/plating5.ogg'), 100, 1),
	FOOTSTEP_CARPET = list(list(
		'sound/effects/footstep/carpet1.ogg',
		'sound/effects/footstep/carpet2.ogg',
		'sound/effects/footstep/carpet3.ogg',
		'sound/effects/footstep/carpet4.ogg',
		'sound/effects/footstep/carpet5.ogg'), 75, -1),
	FOOTSTEP_SAND = list(list(
		'sound/effects/footstep/asteroid1.ogg',
		'sound/effects/footstep/asteroid2.ogg',
		'sound/effects/footstep/asteroid3.ogg',
		'sound/effects/footstep/asteroid4.ogg',
		'sound/effects/footstep/asteroid5.ogg'), 75, 0),
	FOOTSTEP_GRASS = list(list(
		'sound/effects/footstep/grass1.ogg',
		'sound/effects/footstep/grass2.ogg',
		'sound/effects/footstep/grass3.ogg',
		'sound/effects/footstep/grass4.ogg'), 75, 0),
	FOOTSTEP_WATER = list(list(
		'sound/effects/footstep/water1.ogg',
		'sound/effects/footstep/water2.ogg',
		'sound/effects/footstep/water3.ogg',
		'sound/effects/footstep/water4.ogg'), 100, 1),
	FOOTSTEP_LAVA = list(list(
		'sound/effects/footstep/lava1.ogg',
		'sound/effects/footstep/lava2.ogg',
		'sound/effects/footstep/lava3.ogg'), 100, 0),
	FOOTSTEP_MEAT = list(list(
		'sound/effects/meatslap.ogg'), 100, 0),
	FOOTSTEP_CATWALK = list(list(
		'sound/effects/footstep/catwalk1.ogg',
		'sound/effects/footstep/catwalk2.ogg',
		'sound/effects/footstep/catwalk3.ogg',
		'sound/effects/footstep/catwalk4.ogg',
		'sound/effects/footstep/catwalk5.ogg'), 100, 1),
	FOOTSTEP_BALL = list(list(
		'monkestation/sound/effects/ballpit.ogg'), 100, 0),
))
*/
