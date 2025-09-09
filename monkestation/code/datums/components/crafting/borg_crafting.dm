/datum/component/personal_crafting/borg/create_mob_button(mob/user, client/CL)
	var/datum/hud/H = user.hud_used
	var/atom/movable/screen/craft/C = new()
	C.screen_loc = "CENTER+4:19,SOUTH+1.5:6"
	H.static_inventory += C
	CL.screen += C
	RegisterSignal(C, COMSIG_SCREEN_ELEMENT_CLICK, PROC_REF(component_ui_interact))
