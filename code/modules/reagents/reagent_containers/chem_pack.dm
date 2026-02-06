/obj/item/reagent_containers/chem_pack
	name = "intravenous medicine bag"
	desc = "A plastic pressure bag, or 'chem pack', for IV administration of drugs. It is fitted with a thermosealing strip."
	icon = 'icons/obj/medical/bloodpack.dmi'
	icon_state = "chempack"
	volume = 100
	reagent_flags = OPENCONTAINER
	spillable = TRUE
	obj_flags = UNIQUE_RENAME
	resistance_flags = ACID_PROOF
	fill_icon_thresholds = list(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
	interaction_flags_click = NEED_DEXTERITY
	possible_transfer_amounts = list()
	/// Whether this has been sealed shut
	var/sealed = FALSE

/obj/item/reagent_containers/chem_pack/click_alt(mob/living/user)
	if(sealed)
		balloon_alert(user, "sealed!")
		return CLICK_ACTION_BLOCKING

	if(iscarbon(user) && (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50)))
		to_chat(user, span_warning("Uh... whoops! You accidentally spill the content of the bag onto yourself."))
		SplashReagents(user)
		return CLICK_ACTION_BLOCKING

	reagents.flags = NONE
	reagent_flags = DRAWABLE | INJECTABLE //To allow for sabotage or ghetto use.
	reagents.flags = reagent_flags
	spillable = FALSE
	sealed = TRUE
	to_chat(user, span_notice("You seal the bag."))
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/chem_pack/examine()
	. = ..()
	if(sealed)
		. += span_notice("The bag is sealed shut.")
	else
		. += span_notice("Alt-click to seal it.")


/obj/item/reagent_containers/chem_pack/attack_self(mob/user)
	if(sealed)
		return
	..()

/obj/item/reagent_containers/chem_pack/saline
	name = "intravenous saline bag"
	desc = "A plastic pressure bag, or 'chem pack', for IV administration of drugs. This one contains a mixture of saline-glucose, iron, and tirimol to treat bloodloss."
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 55, /datum/reagent/iron = 35, /datum/reagent/medicine/c2/tirimol = 10)
	sealed = TRUE
