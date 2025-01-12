///A simple element that replaces normal shoe sounds with custom sounds
/datum/element/shoesteps
	var/list/old_shoestep_sounds
	var/list/custom_shoestep_sounds

/datum/element/shoesteps/Attach(atom/movable/target)
	. = ..()
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(target, COMSIG_CLICK_CTRL, PROC_REF(on_ctrl_click))

/datum/element/shoesteps/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(source, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)
	UnregisterSignal(source, COMSIG_CLICK_CTRL)

/datum/element/shoesteps/proc/on_equip(mob/equipper, slot)
	SIGNAL_HANDLER

/datum/element/shoesteps/proc/on_drop(mob/user)
	SIGNAL_HANDLER

/datum/element/shoesteps/proc/on_ctrl_click(/mob/clicker)
	SIGNAL_HANDLER

/datum/element/shoesteps/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_notice("There seems to be some slots for Really Heavy Soles in the bottoms of these shoes. You could remove or add them by using Ctrl-Click.")
