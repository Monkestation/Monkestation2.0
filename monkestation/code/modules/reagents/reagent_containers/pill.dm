GLOBAL_VAR_INIT(maint_pills_eaten, 0)

/obj/item/reagent_containers/pill/maintenance/on_consumption(mob/M, mob/user)
	. = ..()
	if(.)
		GLOB.maint_pills_eaten++
