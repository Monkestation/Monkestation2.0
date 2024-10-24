/turf
	// Flick animation shit
	var/obj/effect/abstract/c_animation = null

/turf/proc/turf_animation(var/anim_icon,var/anim_state,var/anim_x=0, var/anim_y=0, var/anim_layer=MOB_LAYER+1, var/anim_sound=null, var/anim_color=null,var/anim_plane = 0)
	if(!c_animation)//spamming turf animations can have unintended effects, such as the overlays never disapearing. hence this check.
		if(anim_sound)
			playsound(src, anim_sound, 50, 1)
		var/obj/effect/abstract/animation = new /obj/effect/abstract(src)
		animation.name = "turf_animation"
		animation.density = FALSE
		animation.anchored = 1
		animation.icon = anim_icon
		animation.icon_state = anim_state
		animation.layer = anim_layer
		animation.pixel_x = anim_x
		animation.pixel_y = anim_y
		animation.plane = anim_plane
		c_animation = animation
		if(anim_color)
			animation.color = anim_color
		flick("turf_animation",animation)
		spawn(10)
			qdel(animation)
			if(c_animation == animation) //Turf may have changed into another form by this time
				c_animation = null

