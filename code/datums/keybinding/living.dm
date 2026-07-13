/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/resist
	hotkey_keys = list("B")
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffed? on fire? Resist!"
	keybind_signal = COMSIG_KB_LIVING_RESIST_DOWN

/datum/keybinding/living/resist/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.resist()
	return TRUE

/datum/keybinding/living/look_up
	hotkey_keys = list("L")
	name = "look up"
	full_name = "Look Up"
	description = "Look up at the next z-level.  Only works if directly below open space."
	keybind_signal = COMSIG_KB_LIVING_LOOKUP_DOWN

/datum/keybinding/living/look_up/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_up()
	return TRUE

/datum/keybinding/living/look_up/up(client/user)
	var/mob/living/L = user.mob
	L.end_look_up()
	return TRUE

/datum/keybinding/living/look_down
	hotkey_keys = list(";")
	name = "look down"
	full_name = "Look Down"
	description = "Look down at the previous z-level.  Only works if directly above open space."
	keybind_signal = COMSIG_KB_LIVING_LOOKDOWN_DOWN

/datum/keybinding/living/look_down/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/L = user.mob
	L.look_down()
	return TRUE

/datum/keybinding/living/look_down/up(client/user)
	var/mob/living/L = user.mob
	L.end_look_down()
	return TRUE

/datum/keybinding/living/rest
	hotkey_keys = list("U") // monke: move this, so LOOC can be U, adjacent to other communication keys.
	name = "rest"
	full_name = "Rest"
	description = "Lay down, or get up."
	keybind_signal = COMSIG_KB_LIVING_REST_DOWN

/datum/keybinding/living/rest/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/living_mob = user.mob
	living_mob.toggle_resting()
	return TRUE

/datum/keybinding/living/interaction_action1
	hotkey_keys = list("1")
	name = "interaction_mode_action_1"
	full_name = "Intent 1/Combat Off"
	description = "Does interaction mode specific action."
	keybind_signal = COMSIG_KB_LIVING_INTERACT_ACTION_1

/datum/keybinding/living/interaction_action1/down(client/user)
	. = ..()
	if(.)
		return
	user.imode.keybind_act(1)

/datum/keybinding/living/interaction_action2
	hotkey_keys = list("2")
	name = "interaction_mode_action_2"
	full_name = "Intent 2"
	description = "Does interaction mode specific action."
	keybind_signal = COMSIG_KB_LIVING_INTERACT_ACTION_2

/datum/keybinding/living/interaction_action2/down(client/user)
	. = ..()
	if(.)
		return
	user.imode.keybind_act(2)

/datum/keybinding/living/interaction_action3
	hotkey_keys = list("3")
	name = "interaction_mode_action_3"
	full_name = "Intent 3/Combat On"
	description = "Does interaction mode specific action."
	keybind_signal = COMSIG_KB_LIVING_INTERACT_ACTION_3

/datum/keybinding/living/interaction_action3/down(client/user)
	. = ..()
	if(.)
		return
	user.imode.keybind_act(3)

/datum/keybinding/living/interaction_action4
	hotkey_keys = list("4", "F")
	name = "interaction_mode_action_4"
	full_name = "Intent 4/Toggle Combat"
	description = "Does interaction mode specific action."
	keybind_signal = COMSIG_KB_LIVING_INTERACT_ACTION_4

/datum/keybinding/living/interaction_action4/down(client/user)
	. = ..()
	if(.)
		return
	user.imode.keybind_act(4)

/datum/keybinding/living/interaction_action5
	hotkey_keys = list("Unbound")
	name = "interaction_mode_action_5"
	full_name = "Intent Cycle"
	description = "Cycles through intents"
	keybind_signal = COMSIG_KB_LIVING_INTERACT_ACTION_5

/datum/keybinding/living/interaction_action5/down(client/user)
	. = ..()
	if(.)
		return
	user.imode.keybind_act(5)

/datum/keybinding/living/item_pixel_shift
	hotkey_keys = list("V")
	name = "item_pixel_shift"
	full_name = "Item Pixel Shift"
	description = "Shift a pulled item's offset"
	category = CATEGORY_MISC
	keybind_signal = COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_DOWN

/datum/keybinding/living/item_pixel_shift/down(client/user)
	. = ..()
	if(. || isnull(user.mob.pulling))
		return
	user.mob.AddComponent(/datum/component/pixel_shift)
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_DOWN)

/datum/keybinding/living/item_pixel_shift/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_ITEM_PIXEL_SHIFT_UP)

/datum/keybinding/living/pixel_shift
	hotkey_keys = list("N")
	name = "pixel_shift"
	full_name = "Pixel Shift"
	description = "Shift your characters offset."
	category = CATEGORY_MOVEMENT
	keybind_signal = COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN

/datum/keybinding/living/pixel_shift/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.AddComponent(/datum/component/pixel_shift)
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_PIXEL_SHIFT_DOWN)

/datum/keybinding/living/pixel_shift/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_PIXEL_SHIFT_UP)

/datum/keybinding/living/pixel_tilting
	hotkey_keys = list("J")
	name = "Pixel Tilting"
	full_name = "Pixel Tilt"
	description = "Shift a mob's rotational value"
	category = CATEGORY_MOVEMENT
	keybind_signal = COMSIG_KB_LIVING_PIXEL_TILT_DOWN

/datum/keybinding/living/pixel_tilting/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.AddComponent(/datum/component/pixel_shift)
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_PIXEL_TILT_DOWN)

/datum/keybinding/living/pixel_tilting/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_KB_LIVING_PIXEL_TILT_UP)

/datum/keybinding/living/interaction_toggle_wield
	hotkey_keys = list("ShiftX")
	name = "keybinding_living_toggle_wield"
	full_name = "Wield"
	description = "Wield an object in two hands, such as a gun."
	keybind_signal = COMSIG_KB_LIVING_TOGGLE_WIELD

/datum/keybinding/living/interaction_toggle_wield/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/mob = user.mob
	var/obj/item/item = mob?.get_active_held_item()
	if(item?.GetComponent(/datum/component/two_handed)) // does our active item have a two_handed component? if so let's ctrl click it!
		mob.base_click_ctrl(item)

