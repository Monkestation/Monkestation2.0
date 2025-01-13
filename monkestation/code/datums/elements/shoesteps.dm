///A simple element that lets shoes have togglable custom sounds
/datum/element/shoesteps
	var/list/custom_sounds = list()
	var/sounds = TRUE

/datum/element/shoesteps/Attach(atom/movable/target)
	. = ..()
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_CLICK_CTRL, PROC_REF(on_ctrl_click))
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/datum/element/shoesteps/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(source, COMSIG_CLICK_CTRL)
	UnregisterSignal(source, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)

/datum/element/shoesteps/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_notice("There seems to be some slots for Really Heavy Soles in the bottoms of these shoes. You could remove or add them by using Ctrl-Click.")
	examine_text += span_notice("The heavy soles are [(sounds) ? "on!" : "off!"]")

/datum/element/shoesteps/proc/on_ctrl_click(datum/source, mob/living/carbon/clicker)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(toggle_soles), clicker)

/datum/element/shoesteps/proc/toggle_soles(mob/living/carbon/clicker)
	if(do_after(clicker, 1.5 SECONDS))
		sounds ^= 1
		to_chat(clicker, span_warning("[(sounds) ? "You put the heavy soles on." : "You take the heavy soles off."]"))

/datum/element/shoesteps/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(ishuman(equipper) && slot & ITEM_SLOT_FEET)
		RegisterSignal(equipper, COMSIG_MOB_PREPARE_STEP_SOUND, PROC_REF(prepare_steps))

/datum/element/shoesteps/proc/on_drop(datum/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER

	if(user.get_item_by_slot(ITEM_SLOT_FEET) == source)
		UnregisterSignal(user, COMSIG_MOB_PREPARE_STEP_SOUND)

/datum/element/shoesteps/proc/prepare_steps(mob/living/carbon/source, list/steps)
	SIGNAL_HANDLER
	if(sounds)
		steps[STEP_SOUND_SHOE_OVERRIDE] = custom_sounds

///
//This area is for custom shoe sound lists. Your lists must match the format of the global lists seen in code\__DEFINES\footsteps.dm
//If replacing shoes match the footstep lists. Other footstep overrides can be added later. Their override lists will also have to match their specific formats.
///
/*

id = list(
list(sounds),
base volume,
extra range addition
)

*/
