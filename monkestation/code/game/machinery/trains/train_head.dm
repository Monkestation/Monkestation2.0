/obj/vehicle/ridden/cargo_train
	name = "cargo train"
	desc = "A good way to transport items"
	icon = 'goon/icons/vehicles.dmi'
	icon_state = "tractor"
	var/datum/train_network/listed_network

/obj/vehicle/ridden/cargo_train/Initialize(mapload)
	. = ..()
	make_ridable()

/obj/vehicle/ridden/cargo_train/proc/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/scooter)


/obj/vehicle/ridden/cargo_train/click_alt(mob/living/user)
	if(!listed_network)
		return CLICK_ACTION_BLOCKING
	visible_message("[user] attempts to disconnect the [src.name] from the network.")
	if(!do_after(user, 2 SECONDS, src))
		return CLICK_ACTION_BLOCKING
	listed_network.train_head = null
	listed_network = null
	return CLICK_ACTION_SUCCESS

/obj/vehicle/ridden/cargo_train/Destroy(force)
	. = ..()
	if(listed_network)
		listed_network.train_head = null
		listed_network = null

/obj/vehicle/ridden/cargo_train/Move(atom/newloc, direct, glide_size_override = 0, update_dir = TRUE)
	var/turf/old_loc = src.loc
	. = ..()
	if(old_loc == src.loc)
		return
	if(listed_network)
		listed_network.relay_move(old_loc)

/obj/vehicle/ridden/cargo_train/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	. = ..()
	if(!Adjacent(over) || !usr.Adjacent(over))
		return
	if(!istype(over, /obj/machinery/cart))
		return

	if(!listed_network)
		listed_network = new
		listed_network.train_head = src

	visible_message("[usr] attempts to connect the [name] and [over.name] together")
	if(!do_after(usr, 2 SECONDS, over))
		return
	listed_network.connect_train(over)
