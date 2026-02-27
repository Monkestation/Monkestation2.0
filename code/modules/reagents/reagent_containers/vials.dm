/obj/item/reagent_containers/cup/vial
	name = "vial"
	desc = "A small vial for holding small amounts of reagents."
	icon_state = "vial"
	possible_transfer_amounts = list(5,10,15)
	unique_reskin = list("vial" = "vial",
						"white vial" = "vial_white",
						"red vial" = "vial_red",
						"blue vial" = "vial_blue",
						"green vial" = "vial_green",
						"orange vial" = "vial_orange",
						"purple vial" = "vial_purple",
						"black vial" = "vial_black",
						)
	possible_transfer_amounts = list(5, 10, 15)
	volume = 15
	disease_amount = 15
	fill_icon_thresholds = list(0, 1, 10, 25, 50, 75, 80, 100)
	/// Name that used as the base for pen renaming, so subtypes can have different names without having to worry about messing with it
	var/base_name = "vial"
	/// List of icon_states that require the stripe overlay to look good. Not a very good way of doing it, but its the best I can come up with right now.
	var/list/striped_vial_skins = list("vial_white", "vial_red", "vial_blue", "vial_green", "vial_orange", "vial_purple", "vial_black", "viallarge_white", "viallarge_red", "viallarge_blue", "viallarge_green", "viallarge_orange", "viallarge_purple", "viallarge_black")

/obj/item/reagent_containers/cup/vial/Initialize(mapload)
	. = ..()
	if(icon_state in striped_vial_skins)
		fill_icon_state = "[icon_state]stripe"

/obj/item/reagent_containers/cup/vial/attackby(obj/P, mob/user, params)
	add_fingerprint(user)
	if(istype(P, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on the label of [src]!"))
			return
		var/t = stripped_input(user, "What would you like the label to be?", text("[]", name), null)
		if (user.get_active_held_item() != P)
			return
		if(!user.can_perform_action(src))
			return
		name = "[base_name][t ? " ([t])" : ""]"
	else
		return ..()

/obj/item/reagent_containers/cup/vial/brute
	name = "vial (Libital)"
	icon_state = "vial_red"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 15)

/obj/item/reagent_containers/cup/vial/sal_acid
	name = "vial (Salicylic Acid)"
	icon_state = "vial_red"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 15)

/obj/item/reagent_containers/cup/vial/burn
	name = "vial (Aiuri)"
	icon_state = "vial_blue"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 15)

/obj/item/reagent_containers/cup/vial/oxandrolone
	name = "vial (Oxandrolone)"
	icon_state = "vial_blue"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 15)

/obj/item/reagent_containers/cup/vial/tox
	name = "vial (Seiver)"
	icon_state = "vial_green"
	list_reagents = list(/datum/reagent/medicine/c2/seiver = 15)

/obj/item/reagent_containers/cup/vial/pen_acid
	name = "vial (Pentetic Acid)"
	icon_state = "vial_green"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 15)

/obj/item/reagent_containers/cup/vial/oxy
	name = "vial (Salbutamol)"
	icon_state = "vial_white"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 15)

/obj/item/reagent_containers/cup/vial/epi
	name = "vial (Epinephrine)"
	icon_state = "vial_white"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 12, /datum/reagent/medicine/coagulant = 3)

/obj/item/reagent_containers/cup/vial/coagulant
	name = "vial (Coagulant)"
	icon_state = "vial_red"
	list_reagents = list(/datum/reagent/medicine/coagulant = 15)

/obj/item/reagent_containers/cup/vial/omnizine
	name = "vial (Omnizine)"
	icon_state = "vial_white"
	list_reagents = list(/datum/reagent/medicine/omnizine = 15)

/obj/item/reagent_containers/cup/vial/atropine
	name = "vial (Atropine)"
	icon_state = "vial_white"
	list_reagents = list(/datum/reagent/medicine/atropine = 15)

/obj/item/reagent_containers/cup/vial/inaprovaline
	name = "vial (Inaprovaline)"
	icon_state = "vial_red"
	list_reagents = list(/datum/reagent/medicine/inaprovaline = 15)

/////////// Large Vials ///////////

/obj/item/reagent_containers/cup/vial/large
	name = "large vial"
	base_name = "large vial"
	desc = "A large vial for holding a sizable amounts of reagents."
	icon_state = "viallarge"
	base_icon_state = "viallarge"
	unique_reskin = list("large vial" = "viallarge",
						"white large vial" = "viallarge_white",
						"red large vial" = "viallarge_red",
						"blue large vial" = "viallarge_blue",
						"green large vial" = "viallarge_green",
						"orange large vial" = "viallarge_orange",
						"purple large vial" = "viallarge_purple",
						"black large vial" = "viallarge_black"
						)
	w_class = WEIGHT_CLASS_SMALL
	possible_transfer_amounts = list(5, 10, 15, 30)
	volume = 30
	disease_amount = 30

/obj/item/reagent_containers/cup/vial/large/omnizine
	name = "large vial (Omnizine)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/omnizine = 30)

/obj/item/reagent_containers/cup/vial/large/brute
	name = "large vial (Libital)"
	icon_state = "viallarge_red"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 30)

/obj/item/reagent_containers/cup/vial/large/sal_acid
	name = "large vial (Salicylic Acid)"
	icon_state = "viallarge_red"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 30)

/obj/item/reagent_containers/cup/vial/large/burn
	name = "large vial (Aiuri)"
	icon_state = "viallarge_blue"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 30)

/obj/item/reagent_containers/cup/vial/large/oxandrolone
	name = "large vial (Oxandrolone)"
	icon_state = "viallarge_blue"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 30)

/obj/item/reagent_containers/cup/vial/large/tox
	name = "large vial (Seiver)"
	icon_state = "viallarge_green"
	list_reagents = list(/datum/reagent/medicine/c2/seiver = 30)

/obj/item/reagent_containers/cup/vial/large/pen_acid
	name = "large vial (Pentetic Acid)"
	icon_state = "viallarge_green"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 30)

/obj/item/reagent_containers/cup/vial/large/oxy
	name = "large vial (Salbutamol)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 30)

/obj/item/reagent_containers/cup/vial/large/epi
	name = "large vial (Epinephrine)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 24, /datum/reagent/medicine/coagulant = 6)

/obj/item/reagent_containers/cup/vial/large/atropine
	name = "large vial (Atropine)"
	icon_state = "viallarge_white"
	list_reagents = list(/datum/reagent/medicine/atropine = 30)

/obj/item/reagent_containers/cup/vial/large/combat
	name = "large vial (Combat Hypospray Mix)"
	icon_state = "viallarge_black"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 2, /datum/reagent/medicine/omnizine = 10, /datum/reagent/medicine/leporazine = 9, /datum/reagent/medicine/atropine = 9)

/obj/item/reagent_containers/cup/vial/large/stimulants
	name = "large vial (Stimulants)"
	icon_state = "viallarge_purple"
	list_reagents = list(/datum/reagent/medicine/stimulants = 30)

/obj/item/reagent_containers/cup/vial/large/morphine
	name = "large vial (Morphine)"
	icon_state = "viallarge_blue"
	list_reagents = list(/datum/reagent/medicine/painkiller/morphine = 30)

/////////// Bluespace Vials ///////////

/obj/item/reagent_containers/cup/vial/bluespace
	name = "bluespace vial"
	base_name = "bluespace vial"
	desc = "A small vial powered by experimental bluespace technology capable of holding 60 units."
	icon_state = "vialbluespace"
	base_icon_state = "vialbluespace"
	unique_reskin = list("bluespace vial" = "vialbluespace",
						"white bluespace vial" = "vialbluespace_white",
						"red bluespace vial" = "vialbluespace_red",
						"blue bluespace vial" = "vialbluespace_blue",
						"green bluespace vial" = "vialbluespace_green",
						"orange bluespace vial" = "vialbluespace_orange",
						"purple bluespace vial" = "vialbluespace_purple",
						"black bluespace vial" = "vialbluespace_black"
						)
	possible_transfer_amounts = list(5,10,15,30,45)
	volume = 60
	disease_amount = 60
	fill_icon_thresholds = null

/obj/item/reagent_containers/cup/vial/large/bluespace
	name = "large bluespace vial"
	base_name = "large bluespace vial"
	desc = "A large bluespace vial, capable of holding up to 120 units."
	icon_state = "vial_bluespace_large"
	base_icon_state = "vial_bluespace_large"
	unique_reskin = list("large bluespace vial" = "vial_bluespace_large",
						"white large bluespace vial" = "vial_bluespace_large_white",
						"red large bluespace vial" = "vial_bluespace_large_red",
						"blue large bluespace vial" = "vial_bluespace_large_blue",
						"green large bluespace vial" = "vial_bluespace_large_green",
						"orange large bluespace vial" = "vial_bluespace_large_orange",
						"purple large bluespace vial" = "vial_bluespace_large_purple",
						"black large bluespace vial" = "vial_bluespace_large_black"
						)
	w_class = WEIGHT_CLASS_SMALL
	possible_transfer_amounts = list(5, 10, 15, 30, 45, 60)
	volume = 120
	disease_amount = 120
	fill_icon_thresholds = null

/obj/item/reagent_containers/cup/vial/large/bluespace/omnizine
	name = "large bluespace vial (Omnizine)"
	icon_state = "vial_bluespace_large_white"
	list_reagents = list(/datum/reagent/medicine/omnizine = 120)

/obj/item/reagent_containers/cup/vial/large/bluespace/sal_acid
	name = "large bluespace vial (Salicylic Acid)"
	icon_state = "vial_bluespace_large_red"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 120)

/obj/item/reagent_containers/cup/vial/large/bluespace/oxandrolone
	name = "large bluespace vial (Oxandrolone)"
	icon_state = "vial_bluespace_large_blue"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 120)

/obj/item/reagent_containers/cup/vial/large/bluespace/pen_acid
	name = "large bluespace vial (Pentetic Acid)"
	icon_state = "vial_bluespace_large_green"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 120)

/obj/item/reagent_containers/cup/vial/large/bluespace/oxy
	name = "large bluespace vial (Salbutamol)"
	icon_state = "vial_bluespace_large_white"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 120)

/obj/item/reagent_containers/cup/vial/large/bluespace/atropine
	name = "large bluespace vial (Atropine)"
	icon_state = "vial_bluespace_large_white"
	list_reagents = list(/datum/reagent/medicine/atropine = 120)

/////////// Special Vials ///////////

//These vials are intended only for hypos that cannot have their vials removed, and so are inaccessable to players
/obj/item/reagent_containers/cup/vial/large/ert
	name = "Large vial (Nanite Mix)"
	desc = "Your not supposed to be able to see this"
	volume = 1000
	disease_amount = 1000
	list_reagents = list(/datum/reagent/medicine/adminordrazine/quantum_heal = 80, /datum/reagent/medicine/synaptizine = 20)

/obj/item/reagent_containers/cup/vial/large/ert/holy
	name = "Large vial (Holy Mix)"
	list_reagents = list(/datum/reagent/water/holywater = 150, /datum/reagent/peaceborg/tire = 50, /datum/reagent/peaceborg/confuse = 50)
