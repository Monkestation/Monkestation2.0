/obj/item/gun/ballistic/automatic/fsssmg
	name = "\improper FSS-9"
	desc = "Used by Syndicate agents and rebels in more than 50 galaxies."
	icon_state = "saber" //NEED TO CHANGE!
	burst_size = 1
	actions_types = list()
	mag_display = TRUE
	empty_indicator = TRUE
	accepted_magazine_type = /obj/item/ammo_box/magazine/smgm9mm
	pin = /obj/item/firing_pin
	bolt_type = BOLT_TYPE_LOCKING
	show_bolt_icon = FALSE
	spread = 8

/obj/item/gun/ballistic/automatic/fsssmg/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/ballistic/automatic/fssrifle
	name = "\improper FSS-5"
	desc = "Used by Syndicate agents and rebels in more than 50 galaxies."
	icon_state = "saber" //NEED TO CHANGE!
	burst_size = 1
	actions_types = list()
	mag_display = TRUE
	empty_indicator = TRUE
	accepted_magazine_type = /obj/item/ammo_box/magazine/m556
	pin = /obj/item/firing_pin
	bolt_type = BOLT_TYPE_LOCKING
	show_bolt_icon = FALSE
	fire_delay = 2
	spread = 6
