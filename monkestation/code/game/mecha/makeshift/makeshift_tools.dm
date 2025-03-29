/obj/item/mecha_parts/mecha_equipment/drill/makeshift
	name = "Makeshift exosuit drill"
	desc = "Cobbled together from likely stolen parts, this drill is nowhere near as effective as the real deal."
	equip_cooldown = 60 //Its slow as shit
	force = 10 //Its not very strong
	mech_flags = EXOSUIT_MODULE_MAKESHIFT
	drill_delay = 15

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift
	name = "makeshift clamp"
	desc = "Loose arrangement of cobbled together bits resembling a clamp."
	equip_cooldown = 25
	force = 10
	mech_flags = EXOSUIT_MODULE_MAKESHIFT

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/makeshift
	name = "mounted stretcher"
	desc = "A mangled bunched of medical equipment connecting to a strecher, It can transport and stabilize patients fine. just don't expect anything more"
	inject_amount = 0
	mech_flags = EXOSUIT_MODULE_MAKESHIFT | EXOSUIT_MODULE_MEDICAL  //TODO: test this shit works or not

/obj/item/mecha_parts/mecha_equipment/weapon/honker
	name = "harm alarm horn"
	desc = "A crude honking horn that alarms nearby bystanders that an ambulance is going through"
	mech_flags = EXOSUIT_MODULE_MAKESHIFT | EXOSUIT_MODULE_MEDICAL
	honk_range = 1
	tactile_mmesage = 1 //only directly besides, are affected
