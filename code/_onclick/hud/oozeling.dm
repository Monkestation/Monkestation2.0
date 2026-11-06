#define ui_slimedisplay "WEST,CENTER+1:15"

/atom/movable/screen/slime_stacks
	name = "slime wetness"
	icon_state = "slime_wetness"
	screen_loc = ui_slimedisplay

/atom/movable/screen/slime_stacks/Click()
	. = ..()
	var/list/msg = list()

	msg += span_nicegreen("This shows your slime wetness stacks.")
	msg += span_nicegreen("As long as you have slime wetness, you can't be set on fire.")
	msg += span_nicegreen("The amount of stacks will decrease based on severity of the fire.")
	msg += span_nicegreen("Slime wetness also acts as protection from water, as long as amount of stacks is above [HYDROPHOBIA_WETNESS_STACKS].")
	msg += span_nicegreen("Water will also decrease the amount of stacks.")

	to_chat(usr, boxed_message(msg.Join("\n")))
