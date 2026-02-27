// Survival Medipens ; Take default 10 seconds toe inject outside of low pressure enviornments like lavaland, be sure this is something that you want.
// Time to inject can be changed by changing the high_pressure_inject_time var
// the ability to inject outside low pressure can be disabled by setting usable_in_high_pressure to FALSE

/obj/item/reagent_containers/medipen/survival
	name = "survival emergency medipen"
	desc = "A medipen for surviving in the harsh environments, heals most common damage sources. WARNING: May cause organ damage."
	icon_state = "stimpen"
	inhand_icon_state = "stimpen"
	base_icon_state = "stimpen"
	volume = 35
	amount_per_transfer_from_this = 35
	list_reagents = list( /datum/reagent/medicine/epinephrine = 8, /datum/reagent/medicine/c2/aiuri = 8, /datum/reagent/medicine/c2/libital = 8, /datum/reagent/medicine/leporazine = 6)
	/// How long it takes to inject this pen in a high-pressure environment, or otherwise outside of lavaland
	var/high_pressure_inject_time = 10 SECONDS
	/// Wether or not this pen can be injected at all in high-pressure environments, or otherwise ouotside of lavaland
	var/usable_in_high_pressure = TRUE

/obj/item/reagent_containers/medipen/survival/inject(mob/living/affected_mob, mob/user)
	if(lavaland_equipment_pressure_check(get_turf(user)))
		amount_per_transfer_from_this = initial(amount_per_transfer_from_this)
		return ..()

	if(!usable_in_high_pressure)
		to_chat(user, span_warning("The pressure is too high to use \the [src]!"))
		return

	if(DOING_INTERACTION(user, DOAFTER_SOURCE_SURVIVALPEN))
		to_chat(user,span_notice("You are too busy to use \the [src]!"))
		return

	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return

	to_chat(user,span_notice("You start manually releasing the low-pressure gauge..."))
	if(!do_after(user, high_pressure_inject_time, affected_mob, interaction_key = DOAFTER_SOURCE_SURVIVALPEN))
		return

	amount_per_transfer_from_this = initial(amount_per_transfer_from_this) * 0.5
	return ..()

/obj/item/reagent_containers/medipen/survival/luxury
	name = "luxury medipen"
	desc = "Cutting edge bluespace technology allowed Nanotrasen to compact 70u of volume into a single medipen. Contains rare and powerful chemicals used to aid in exploration of very hard enviroments. WARNING: DO NOT MIX WITH EPINEPHRINE OR ATROPINE."
	icon_state = "luxpen"
	inhand_icon_state = "atropen"
	base_icon_state = "luxpen"
	volume = 70
	amount_per_transfer_from_this = 70
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/c2/penthrite = 10, /datum/reagent/medicine/oxandrolone = 10, /datum/reagent/medicine/sal_acid = 10 ,/datum/reagent/medicine/omnizine = 10 ,/datum/reagent/medicine/leporazine = 10)

/obj/item/reagent_containers/medipen/survival/luxury/oozeling //oozeling safe version of the luxury pen!
	name = "luxury oozeling medipen"
	desc = "Even more cutting edge bluespace technology allowed Nanotrasen to compact 90u of volume into a single medipen. Contains rare and powerful chemicals that are also oozeling safe! Used to aid in exploration of very harsh enviroments. WARNING: DO NOT MIX WITH EPINEPHRINE OR ATROPINE. <b> EXTRA WARNING : UNSAFE FOR NON OOZELING LIFE </b>"
	icon_state = "luxpen"
	inhand_icon_state = "atropen"
	base_icon_state = "luxpen"
	volume = 90
	amount_per_transfer_from_this = 90
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10, /datum/reagent/medicine/c2/penthrite = 10, /datum/reagent/medicine/oxandrolone = 10, /datum/reagent/medicine/sal_acid = 10, /datum/reagent/medicine/regen_jelly/weakened = 5, /datum/reagent/toxin = 5, /datum/reagent/medicine/leporazine = 10)
/obj/item/reagent_containers/medipen/survival/penthrite
	name = "Rapid Penthrite Injector"
	desc = "An expensive single use injector containing penthrite, allowing your body to keep functioning even with wounds that would make someone collapse. Seems to only be rapid in a low pressure enviorment as well... thats misleading. <b> WARNING: DO NOT MIX WITH EPINEPHRINE OR ATROPINE. </b>"
	icon_state = "atropen"
	base_icon_state = "atropen"
	amount_per_transfer_from_this = 15
	volume = 15
	list_reagents = list(/datum/reagent/medicine/c2/penthrite = 15)

/obj/item/reagent_containers/medipen/survival/speed
	name = "Rush Injector"
	desc = "An experimental medipen containing some mysterious chemical cocktail that allows the user to move incredibly fast for a very short period of time. Takes a second to kick in. <b> SIDE EFFECTS OF USING MANY STIMS IN A SHORT PERIOD UNKNOWN </b>"
	icon_state = "gorillapen"
	base_icon_state = "gorillapen"
	amount_per_transfer_from_this = 4.5
	volume = 4.5
	list_reagents = list(/datum/reagent/consumable/monkey_energy = 1, /datum/reagent/drug/methamphetamine/borer_version = 1.5, /datum/reagent/medicine/ephedrine = 1, /datum/reagent/drug/cocaine = 1)

/obj/item/reagent_containers/medipen/survival/synthcare
	name = "Advanced Synthetic Care Pen"
	desc = "A single use applicator made to rapidly fix urgent damage to synthetic parts on the go in low pressure enviorments and provide a small speed boost. Contains chemicals that are safe but otherwise worthless for organics. <b> WARNING : DO NOT APPLY A SECOND APPLICATOR UNTIL FIRST HAS FULLY PROCESSED. FAILURE TO FOLLOW INSTRUCTIONS IS GURANTEED TO BE LETHAL TO SYNTHETICS. DOES NOT WORK ON CYBORGS. UNDER NO CIRCUMSTANCES IS THIS TO BE MIXED WITH BASIC NANITE SLURRY (FOUND IN THE SMALL SYNTHETIC CARE PEN)</b>"
	icon_state = "nanite_hypo"
	base_icon_state = "nanite_hypo"
	amount_per_transfer_from_this = 10.5
	volume = 10.5
	list_reagents = list(/datum/reagent/medicine/nanite_slurry/strong = 9, /datum/reagent/drug/methamphetamine/robo = 1.5)
