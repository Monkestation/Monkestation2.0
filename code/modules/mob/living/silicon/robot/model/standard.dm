/datum/robot_model/standard
	name = "Standard"
	default_skin = /datum/robot_skin/standard/default
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/epi, // Buffed slightly by letting them dispense salglu. Can help humans better at the cost of a smaller welding tank so they can't just heal all the time. Feels more in line with what's expectted of borgs nowdays.
		/obj/item/healthanalyzer,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/weldingtool/mini, // Why on gods green earth did they have a full cyborg welder before?
		/obj/item/extinguisher/mini, // Likewise, why could they put out fires as good as engineering borgs? They are jacks of all trades, master of none.
		/obj/item/pickaxe,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/soap/nanotrasen,
		/obj/item/borg/cyborghug,
		/obj/item/storage/bag/tray,
		// Zipties have been removed because why god would you let them become security 2.
	)
	emagged_modules = list(
		/obj/item/melee/energy/sword/cyborg, // I don't think there was any reason to use cyborg specific esword with this? They both act functionally the same.
	)
	traits = list(TRAIT_NEGATES_GRAVITY)
