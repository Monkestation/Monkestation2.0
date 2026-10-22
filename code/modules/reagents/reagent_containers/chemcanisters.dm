/obj/item/reagent_containers/chemcanister
	name = "chemical canister"
	desc = "A small chemical canister for holding small amounts of reagents."
	icon_state = "canister"
	unique_reskin = list(
		"Standard" = "canister",
		"Cyan " = "canister_cyan",
		"Green" = "canister_green",
		"Red" = "canister_red",
		"Orange" = "canister_orange",
		"Purple" = "canister_purple",
	)
	reagent_flags = OPENCONTAINER
	resistance_flags = ACID_PROOF
	possible_transfer_amounts = list(5, 10, 15, 30)
	volume = 30
	spillable = FALSE
	disease_amount = 30
	fill_icon_state = "canister"
	fill_icon = 'icons/obj/medical/reagent_fillings.dmi'
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)
	/// Name that used as the base for pen renaming, so subtypes can have different names without having to worry about messing with it
	var/base_name = "chemical canister"

/obj/item/reagent_containers/chemcanister/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/chemcanister/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/pen))
		return ..()

	add_fingerprint(user)
	if(!user.is_literate())
		to_chat(user, span_notice("You scribble illegibly on the label of [src]!"))
		return ITEM_INTERACT_BLOCKING

	var/text = tgui_input_text(user, "What would you like the label to be?", name, encode = TRUE)
	if(!text)
		return ITEM_INTERACT_BLOCKING

	if (user.get_active_held_item() != tool)
		return ITEM_INTERACT_BLOCKING

	if(!user.can_perform_action(src))
		return ITEM_INTERACT_BLOCKING

	name = "[base_name][text ? " ([text])" : ""]"
	return ITEM_INTERACT_SUCCESS

/obj/item/reagent_containers/chemcanister/brute
	name = "chemical canister (libital)"
	icon_state = "canister_red"
	unique_reskin = "canister_red"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 30)

/obj/item/reagent_containers/chemcanister/sal_acid
	name = "chemical canister (salicylic Acid)"
	icon_state = "canister_red"
	unique_reskin = "canister_red"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 30)

/obj/item/reagent_containers/chemcanister/burn
	name = "chemical canister (aiuri)"
	icon_state = "canister_orange"
	unique_reskin = "canister_orange"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 30)

/obj/item/reagent_containers/chemcanister/oxandrolone
	name = "chemical canister (oxandrolone)"
	unique_reskin = "canister_orange"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 30)

/obj/item/reagent_containers/chemcanister/tox
	name = "chemical canister (seiver)"
	icon_state = "canister_green"
	unique_reskin = "canister_green"
	list_reagents = list(/datum/reagent/medicine/c2/seiver = 30)

/obj/item/reagent_containers/chemcanister/pen_acid
	name = "chemical canister (pentetic Acid)"
	icon_state = "canister_green"
	unique_reskin = "canister_green"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 30)

/obj/item/reagent_containers/chemcanister/oxy
	name = "chemical canister (salbutamol)"
	icon_state = "canister_cyan"
	unique_reskin = "canister_cyan"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 30)

/obj/item/reagent_containers/chemcanister/epi
	name = "chemical canister (epinephrine)"
	icon_state = "canister"
	unique_reskin = "canister"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30)

/obj/item/reagent_containers/chemcanister/coagulant
	name = "chemical canister (coagulant)"
	icon_state = "canister_purple"
	unique_reskin = "canister_purple"
	list_reagents = list(/datum/reagent/medicine/coagulant = 30)

/obj/item/reagent_containers/chemcanister/omnizine
	name = "chemical canister (omnizine)"
	icon_state = "canister_purple"
	unique_reskin = "canister_purple"
	list_reagents = list(/datum/reagent/medicine/omnizine = 30)

/obj/item/reagent_containers/chemcanister/atropine
	name = "chemical canister (atropine)"
	icon_state = "canister"
	unique_reskin = "canister"
	list_reagents = list(/datum/reagent/medicine/atropine = 30)

/obj/item/reagent_containers/chemcanister/inaprovaline
	name = "chemical canister (inaprovaline)"
	icon_state = "canister_cyan"
	unique_reskin = "canister_cyan"
	list_reagents = list(/datum/reagent/medicine/inaprovaline = 30)

/////////// large chemical canisters ///////////

/obj/item/reagent_containers/chemcanister/large
	name = "large chemical canister"
	base_name = "large chemical canister"
	desc = "A large chemical for holding a sizable amounts of reagents. It's too large to fit in standard hyposprays."
	icon_state = "canister_large"
	base_icon_state = "canister_large"
	unique_reskin = list(
		"Standard" = "canister_large",
		"Cyan " = "canister_large_cyan",
		"Green" = "canister_large_green",
		"Red" = "canister_large_red",
		"Orange" = "canister_large_orange",
		"Purple" = "canister_large_purple",
		)
	w_class = WEIGHT_CLASS_SMALL
	possible_transfer_amounts = list(5, 10, 15, 30, 50)
	volume = 50
	disease_amount = 50

/obj/item/reagent_containers/chemcanister/large/omnizine
	name = "large chemical canister (omnizine)"
	icon_state = "canister_large_purple"
	unique_reskin = "canister_large_purple"
	list_reagents = list(/datum/reagent/medicine/omnizine = 50)

/obj/item/reagent_containers/chemcanister/large/brute
	name = "large chemical canister (libital)"
	icon_state = "canister_large_red"
	unique_reskin = "canister_large_red"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 50)

/obj/item/reagent_containers/chemcanister/large/sal_acid
	name = "large chemical canister (salicylic acid)"
	icon_state = "canister_large_red"
	unique_reskin = "canister_large_red"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 50)

/obj/item/reagent_containers/chemcanister/large/burn
	name = "large chemical canister (aiuri)"
	icon_state = "canister_large_orange"
	unique_reskin = "canister_large_orange"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 50)

/obj/item/reagent_containers/chemcanister/large/oxandrolone
	name = "large chemical canister (oxandrolone)"
	icon_state = "canister_large_orange"
	unique_reskin = "canister_large_orange"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 50)

/obj/item/reagent_containers/chemcanister/large/tox
	name = "large chemical canister (seiver)"
	icon_state = "canister_large_green"
	unique_reskin = "canister_large_green"
	list_reagents = list(/datum/reagent/medicine/c2/seiver = 50)

/obj/item/reagent_containers/chemcanister/large/pen_acid
	name = "large chemical canister (pentetic acid)"
	icon_state = "canister_large_green"
	unique_reskin = "canister_large_green"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 50)

/obj/item/reagent_containers/chemcanister/large/oxy
	name = "large chemical canister (salbutamol)"
	icon_state = "canister_large_cyan"
	unique_reskin = "canister_large_cyan"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 50)

/obj/item/reagent_containers/chemcanister/large/epi
	name = "large chemical canister (epinephrine)"
	icon_state = "canister_large"
	unique_reskin = "canister_large"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 50)

/obj/item/reagent_containers/chemcanister/large/atropine
	name = "large chemical canister (atropine)"
	icon_state = "canister_large"
	unique_reskin = "canister_large"
	list_reagents = list(/datum/reagent/medicine/atropine = 50)

/obj/item/reagent_containers/chemcanister/large/combat
	name = "large chemical canister (combat hypospray mix)"
	icon_state = "canister_large_purple"
	unique_reskin = "canister_large_purple"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 3, /datum/reagent/medicine/omnizine = 18, /datum/reagent/medicine/leporazine = 12, /datum/reagent/medicine/atropine = 12)

/obj/item/reagent_containers/chemcanister/large/stimulants
	name = "large chemical canister (stimulants)"
	icon_state = "canister_large_purple"
	unique_reskin = "canister_large_purple"
	list_reagents = list(/datum/reagent/medicine/stimulants = 50)

/obj/item/reagent_containers/chemcanister/large/morphine
	name = "large chemical canister (morphine)"
	icon_state = "canister_large_cyan"
	unique_reskin = "canister_large_cyan"
	list_reagents = list(/datum/reagent/medicine/painkiller/morphine = 50)

/////////// bluespace chemical canisters ///////////

/obj/item/reagent_containers/chemcanister/bluespace
	name = "bluespace chemical canister"
	base_name = "bluespace chemical canister"
	desc = "A bluespace chemical canister powered by experimental bluespace technology capable of holding a large amount of reagents."
	icon_state = "canister_bluespace"
	base_icon_state = "canister_bluespace"
	unique_reskin = list(
		"Standard" = "canister_bluespace",
		"Cyan " = "canister_bluespace_cyan",
		"Green" = "canister_bluespace_green",
		"Red" = "canister_bluespace_red",
		"Orange" = "canister_bluespace_orange",
		"Purple" = "canister_bluespace_purple",
		)
	possible_transfer_amounts = list(5, 10, 15, 30, 50, 100)
	volume = 100
	disease_amount = 100

/obj/item/reagent_containers/chemcanister/bluespace/combat
	name = "bluespace chemical canister (combat hypospray mix)"
	icon_state = "canister_bluespace_purple"
	unique_reskin = "canister_bluespace_purple"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 6, /datum/reagent/medicine/omnizine = 36, /datum/reagent/medicine/leporazine = 24, /datum/reagent/medicine/atropine = 24)

/obj/item/reagent_containers/chemcanister/bluespace/omnizine
	name = "bluespace chemical canister (omnizine)"
	icon_state = "canister_bluespace_purple"
	unique_reskin = "canister_bluespace_purple"
	list_reagents = list(/datum/reagent/medicine/omnizine = 100)

/obj/item/reagent_containers/chemcanister/bluespace/sal_acid
	name = "bluespace chemical canister (salicylic Acid)"
	icon_state = "canister_bluespace_red"
	unique_reskin = "canister_bluespace_red"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 100)

/obj/item/reagent_containers/chemcanister/bluespace/oxandrolone
	name = "bluespace chemical canister (oxandrolone)"
	icon_state = "canister_bluespace_orange"
	unique_reskin = "canister_bluespace_orange"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 100)

/obj/item/reagent_containers/chemcanister/bluespace/pen_acid
	name = "bluespace chemical canister (pentetic Acid)"
	icon_state = "canister_bluespace_green"
	unique_reskin = "canister_bluespace_green"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 100)

/obj/item/reagent_containers/chemcanister/bluespace/oxy
	name = "bluespace chemical canister (salbutamol)"
	icon_state = "canister_bluespace_cyan"
	unique_reskin = "canister_bluespace_cyan"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 100)

/obj/item/reagent_containers/chemcanister/bluespace/atropine
	name = "bluespace chemical canister (atropine)"
	icon_state = "canister_bluespace_purple"
	unique_reskin = "canister_bluespace_purple"
	list_reagents = list(/datum/reagent/medicine/atropine = 100)

/////////// Special Vials ///////////

//These vials are intended only for hypos that cannot have their vials removed, and so are inaccessable to players
/obj/item/reagent_containers/chemcanister/bluespace/ert
	name = "omega bluespace chemical canister (nanite mix)"
	desc = "You're not supposed to be able to see this."
	icon_state = "canister_bluespace"
	unique_reskin = "canister_bluespace"
	volume = 1000
	disease_amount = 1000
	list_reagents = list(/datum/reagent/medicine/adminordrazine/quantum_heal = 80, /datum/reagent/medicine/synaptizine = 20)

/obj/item/reagent_containers/chemcanister/bluespace/ert/holy
	name = "omega bluespace chemical canister (holy mix)"
	list_reagents = list(/datum/reagent/water/holywater = 150, /datum/reagent/peaceborg/tire = 50, /datum/reagent/peaceborg/confuse = 50)
