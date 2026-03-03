/obj/item/reagent_containers/medipen
	name = "epinephrine medipen"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge. Contains a powerful preservative that can delay decomposition when applied to a dead body, and stop the production of histamine during an allergic reaction."
	icon = 'icons/obj/medical/syringe.dmi'
	icon_state = "medipen"
	inhand_icon_state = "medipen"
	worn_icon_state = "medipen"
	base_icon_state = "medipen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount_per_transfer_from_this = 15
	volume = 15
	var/ignore_flags = 1 //so you can medipen through spacesuits
	reagent_flags = DRAWABLE
	flags_1 = null
	list_reagents = list(/datum/reagent/medicine/epinephrine = 10, /datum/reagent/toxin/formaldehyde = 3, /datum/reagent/medicine/coagulant = 2)
	custom_price = PAYCHECK_CREW
	custom_premium_price = PAYCHECK_COMMAND
	var/label_examine = TRUE
	var/label_text
	var/infinite = FALSE
	/// If TRUE, won't play a noise when injecting.
	var/stealthy = FALSE
	/// How long it takes to inject others with
	var/inject_others_time = 0 SECONDS

/obj/item/reagent_containers/medipen/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/item/reagent_containers/medipen/attack(mob/living/affected_mob, mob/user)
	inject(affected_mob, user)

/obj/item/reagent_containers/medipen/attack_self(mob/user)
	if(user.can_perform_action(src, FORBID_TELEKINESIS_REACH|ALLOW_RESTING))
		inject(user, user)

///Handles all injection checks, injection and logging.
/obj/item/reagent_containers/medipen/proc/inject(mob/living/affected_mob, mob/user)
	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return FALSE
	if(!iscarbon(affected_mob))
		return FALSE

	//Always log attemped injects for admins
	var/list/injected = list()
	for(var/datum/reagent/injected_reagent in reagents.reagent_list)
		injected += injected_reagent.name
	var/contained = english_list(injected)
	log_combat(user, affected_mob, "attempted to inject", src, "([contained])")

	if((affected_mob != user) && inject_others_time)
		affected_mob.visible_message(span_danger("[user] is trying to inject [affected_mob]!"), \
				span_userdanger("[user] is trying to inject something into you!"))
		if(!do_after(user, CHEM_INTERACT_DELAY(inject_others_time, user), affected_mob))
			return FALSE

	if(reagents.total_volume && (ignore_flags || affected_mob.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))) // Ignore flag should be checked first or there will be an error message.
		to_chat(affected_mob, span_warning("You feel a tiny prick!"))
		to_chat(user, span_notice("You inject [affected_mob] with [src]."))
		if(!stealthy)
			playsound(affected_mob, 'sound/items/autoinjector.ogg', 50, TRUE)
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)


		if(affected_mob.reagents)
			var/trans = 0
			if(!infinite)
				trans = reagents.trans_to(affected_mob, amount_per_transfer_from_this, transfered_by = user, methods = INJECT)
			else
				reagents.expose(affected_mob, INJECT, fraction)
				trans = reagents.copy_to(affected_mob, amount_per_transfer_from_this)
			to_chat(user, span_notice("[trans] unit\s injected. [reagents.total_volume] unit\s remaining in [src]."))
			log_combat(user, affected_mob, "injected", src, "([contained])")

		if(!reagents.total_volume) // no chems left,
			reagents.maximum_volume = 0 //Makes them useless afterwards
			reagents.flags = NONE
		update_appearance()
		return TRUE
	return FALSE

/obj/item/reagent_containers/medipen/update_icon_state()
	icon_state = "[base_icon_state][(reagents.total_volume > 0) ? null : 0]"
	return ..()

/obj/item/reagent_containers/medipen/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to choke on \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS//ironic. he could save others from oxyloss, but not himself.

/obj/item/reagent_containers/medipen/stimpack //goliath kiting
	name = "stimpack medipen"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor."
	icon_state = "stimpen"
	inhand_icon_state = "stimpen"
	base_icon_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list(/datum/reagent/medicine/ephedrine = 10, /datum/reagent/consumable/coffee = 10)

/obj/item/reagent_containers/medipen/stimpack/traitor
	desc = "A modified stimulants autoinjector for use in combat situations. Has a mild healing effect."
	list_reagents = list(/datum/reagent/medicine/stimulants = 10, /datum/reagent/medicine/omnizine = 10)

/obj/item/reagent_containers/medipen/stimulants
	name = "stimulant medipen"
	desc = "Contains a very large amount of an incredibly powerful stimulant, vastly increasing your movement speed and reducing stuns by a very large amount for around five minutes. Do not take if pregnant."
	icon_state = "syndipen"
	inhand_icon_state = "tbpen"
	base_icon_state = "syndipen"
	volume = 50
	amount_per_transfer_from_this = 50
	list_reagents = list(/datum/reagent/medicine/stimulants = 50)

/obj/item/reagent_containers/medipen/morphine
	name = "morphine medipen"
	desc = "A rapid way to get you out of a tight situation and fast! You'll feel rather drowsy, though."
	icon_state = "morphen"
	inhand_icon_state = "morphen"
	base_icon_state = "morphen"
	list_reagents = list(/datum/reagent/medicine/painkiller/morphine = 10)

/obj/item/reagent_containers/medipen/oxandrolone
	name = "oxandrolone medipen"
	desc = "An autoinjector containing oxandrolone, used to treat severe burns."
	icon_state = "oxapen"
	inhand_icon_state = "oxapen"
	base_icon_state = "oxapen"
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 10)

/obj/item/reagent_containers/medipen/penacid
	name = "pentetic acid medipen"
	desc = "An autoinjector containing pentetic acid, used to reduce high levels of radiations and moderate toxins."
	icon_state = "penacid"
	inhand_icon_state = "penacid"
	base_icon_state = "penacid"
	list_reagents = list(/datum/reagent/medicine/pen_acid = 10)

/obj/item/reagent_containers/medipen/salacid
	name = "salicylic acid medipen"
	desc = "An autoinjector containing salicylic acid, used to treat severe brute damage."
	icon_state = "salacid"
	inhand_icon_state = "salacid"
	base_icon_state = "salacid"
	list_reagents = list(/datum/reagent/medicine/sal_acid = 10)

/obj/item/reagent_containers/medipen/salbutamol
	name = "salbutamol medipen"
	desc = "An autoinjector containing salbutamol, used to heal oxygen damage quickly."
	icon_state = "salpen"
	inhand_icon_state = "salpen"
	base_icon_state = "salpen"
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10)

/obj/item/reagent_containers/medipen/tuberculosiscure
	name = "BVAK autoinjector"
	desc = "Bio Virus Antidote Kit autoinjector. Has a two use system for yourself, and someone else. Inject when infected."
	icon_state = "tbpen"
	inhand_icon_state = "tbpen"
	base_icon_state = "tbpen"
	volume = 20
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/vaccine/fungal_tb = 20)

/obj/item/reagent_containers/medipen/tuberculosiscure/update_icon_state()
	. = ..()
	if(reagents.total_volume >= volume)
		icon_state = base_icon_state
		return
	icon_state = "[base_icon_state][(reagents.total_volume > 0) ? 1 : 0]"

/obj/item/reagent_containers/medipen/atropine
	name = "atropine autoinjector"
	desc = "A rapid way to save a person from a critical injury state!"
	icon_state = "atropen"
	inhand_icon_state = "atropen"
	base_icon_state = "atropen"
	list_reagents = list(/datum/reagent/medicine/atropine = 10, /datum/reagent/medicine/coagulant = 2)

/obj/item/reagent_containers/medipen/snail
	name = "snail shot"
	desc = "All-purpose snail medicine! Do not use on non-snails!"
	icon_state = "snail"
	inhand_icon_state = "snail"
	base_icon_state = "snail"
	list_reagents = list(/datum/reagent/snail = 10)
	label_examine = FALSE

/obj/item/reagent_containers/medipen/magillitis
	name = "experimental autoinjector"
	desc = "A custom-frame needle injector with a small single-use reservoir, containing an experimental serum. Unlike the more common medipen frame, it cannot pierce through protective armor or space suits, nor can the chemical inside be extracted."
	icon_state = "gorillapen"
	inhand_icon_state = "gorillapen"
	base_icon_state = "gorillapen"
	volume = 5
	ignore_flags = 0
	reagent_flags = NONE
	list_reagents = list(/datum/reagent/magillitis = 5)

/obj/item/reagent_containers/medipen/pumpup
	name = "maintenance pump-up"
	desc = "A ghetto looking autoinjector filled with a cheap adrenaline shot... Great for shrugging off the effects of stunbatons."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/drug/pumpup = 15)
	icon_state = "maintenance"
	base_icon_state = "maintenance"
	label_examine = FALSE

/obj/item/reagent_containers/medipen/ekit
	name = "emergency first-aid autoinjector"
	desc = "An epinephrine medipen with extra coagulant and antibiotics to help stabilize bad cuts and burns."
	icon_state = "firstaid"
	base_icon_state = "firstaid"
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/medicine/epinephrine = 12, /datum/reagent/medicine/coagulant = 2.5, /datum/reagent/medicine/antipathogenic/spaceacillin = 0.5)

/obj/item/reagent_containers/medipen/blood_loss
	name = "hypovolemic-response autoinjector"
	desc = "A medipen designed to stabilize and rapidly reverse severe bloodloss."
	icon_state = "hypovolemic"
	base_icon_state = "hypovolemic"
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/medicine/epinephrine = 5, /datum/reagent/medicine/coagulant = 2.5, /datum/reagent/iron = 3.5, /datum/reagent/medicine/salglu_solution = 4)

/obj/item/reagent_containers/medipen/mutadone
	name = "mutadone autoinjector"
	desc = "An mutadone medipen to assist in curing genetic errors in one single injector."
	icon_state = "penacid"
	inhand_icon_state = "penacid"
	base_icon_state = "penacid"
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/medicine/mutadone = 15)

/obj/item/reagent_containers/medipen/penthrite
	name = "penthrite autoinjector"
	desc = "Experimental heart medication."
	icon_state = "atropen"
	inhand_icon_state = "atropen"
	base_icon_state = "atropen"
	list_reagents = list(/datum/reagent/medicine/c2/penthrite = 10)

/obj/item/reagent_containers/medipen/temperature //not a survival subtype, because a low pressure seal on a medipen as harmless as this is pointless
	name = "Temperature Stabilization Injector"
	desc = "A three use medipen with the only purpose being to stabilize body temperature. Handy if you plan to be lit on fire or fight a watcher."
	icon_state = "morphen"
	base_icon_state = "morphen"
	amount_per_transfer_from_this = 10
	volume = 30
	list_reagents = list(/datum/reagent/medicine/leporazine = 30)

/obj/item/reagent_containers/medipen/magnet
	name = "Magnetization Injector"
	desc = "A single use medipen that gives a long lasting magnetization effect, causing you to pull in ores laying on the ground. <b> WARNING : CONTENTS MAY BE LIGHTLY ALCOHOLIC IN NATURE </b>"
	icon_state = "invispen"
	base_icon_state = "invispen"
	amount_per_transfer_from_this = 20
	volume = 20
	list_reagents = list(/datum/reagent/consumable/ethanol/fetching_fizz = 20)

/obj/item/reagent_containers/medipen/synthcare
	name = "Small Synthetic Care Pen"
	desc = "A single use applicator made to care for synthetic parts, be it a single prosthetic or an IPC. <b> WARNING : DO NOT APPLY A SECOND APPLICATOR UNTIL FIRST HAS FULLY PROCESSED. FAILURE TO FOLLOW INSTRUCTIONS CAN PROVE HAZARDOUS TO SYNTHETICS. DOES NOT WORK ON CYBORGS. DO NOT MIX WITH ADVANCED NANITE SLURRY.</b>"
	icon_state = "syndipen"
	base_icon_state = "syndipen"
	amount_per_transfer_from_this = 9
	volume = 9
	list_reagents = list(/datum/reagent/medicine/nanite_slurry = 9)

/obj/item/reagent_containers/medipen/synthpainkill
	name = "positronic neural dampener autoinjector"
	desc = "An autoinjector that can be used to dampen the stimulus response capabilties and pain senses of robots and positronics. One dose for analgesia, two for anesthesia. May cause slight decrease in motor function after injection."
	icon_state = "invispen"
	base_icon_state = "invispen"
	amount_per_transfer_from_this = 10
	volume = 10
	list_reagents = list(/datum/reagent/medicine/painkiller/robopiates = 7.5, /datum/reagent/dinitrogen_plasmide = 2.5)

/obj/item/reagent_containers/medipen/morphine
	name = "morphine medipen"
	desc = "A medipen that contains a dosage of painkilling morphine. \
		WARNING: Do not use in combination with alcohol. Can cause drowsiness and addiction."
	icon_state = "morphen"
	inhand_icon_state = "morphen"
	base_icon_state = "morphen"
	list_reagents = list(/datum/reagent/medicine/painkiller/morphine = 10)

/////////////////////////
/// Advanced Medipens ///
/////////////////////////

/obj/item/reagent_containers/medipen/advanced
	name = "advanced stimulant autoinjector"
	desc = "Contains a very large amount of an incredibly powerful stimulant, vastly increasing your movement speed and reducing stuns by a very large amount for around five minutes. Do not take if pregnant. Has a two use system."
	icon_state = "syndipendouble"
	inhand_icon_state = "tbpen"
	base_icon_state = "syndipendouble"
	volume = 100
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(50)
	list_reagents = list(/datum/reagent/medicine/stimulants = 100)
	var/stripe_style = null

/obj/item/reagent_containers/medipen/advanced/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/reagent_containers/medipen/advanced/update_overlays()
	. = ..()
	if(stripe_style)
		. += "[stripe_style]"

/obj/item/reagent_containers/medipen/advanced/update_icon_state()
	. = ..()
	if(reagents.total_volume >= volume)
		icon_state = base_icon_state
		return
	icon_state = "[base_icon_state][(reagents.total_volume > 0) ? 1 : 0]"

/obj/item/reagent_containers/medipen/advanced/oxandrolone
	name = "advanced oxandrolone autoinjector"
	desc = "An autoinjector containing oxandrolone, used to treat severe burns. Has a two use system."
	volume = 20
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 20)
	stripe_style = "oxa"
	inhand_icon_state = "oxapen"

/obj/item/reagent_containers/medipen/advanced/salacid
	name = "advanced salicylic acid autoinjector"
	desc = "An autoinjector containing salicylic acid, used to treat severe brute damage. Has a two use system."
	volume = 20
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	list_reagents = list(/datum/reagent/medicine/sal_acid = 20)
	stripe_style = "sala"
	inhand_icon_state = "salacid"

/obj/item/reagent_containers/medipen/advanced/morphine
	name = "advanced morphine autoinjector"
	desc = "An autoinjector containing morphine, used as a strong painkiller. Has a two use system."
	volume = 30
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = list(10)
	list_reagents = list(/datum/reagent/medicine/painkiller/morphine = 30)
	stripe_style = "morphine"
	inhand_icon_state = "morphen"


/obj/item/reagent_containers/medipen/advanced/salbutamol
	name = "advanced salbutamol autoinjector"
	desc = "An autoinjector containing salbutamol, used to heal oxygen damage quickly. Has a two use system."
	volume = 20
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	list_reagents = list(/datum/reagent/medicine/salbutamol = 20)
	stripe_style = "sal"
	inhand_icon_state = "salpen"

/obj/item/reagent_containers/medipen/advanced/penacid
	name = "advanced pentetic autoinjector"
	desc = "An autoinjector containing pentetic acid, used to reduce high levels of radiations and moderate toxins. Has a two use system."
	volume = 20
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	list_reagents = list(/datum/reagent/medicine/pen_acid = 20)
	stripe_style = "acid"
	inhand_icon_state = "penacid"

/obj/item/reagent_containers/medipen/advanced/epinephrine
	name = "advanced epinephrine autoinjector"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge. Contains a powerful preservative that can delay decomposition when applied to a dead body, and stop the production of histamine during an allergic reaction. Has a two use system."
	volume = 50
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = list(25)
	list_reagents = list(/datum/reagent/medicine/epinephrine = 20, /datum/reagent/toxin/formaldehyde = 5, /datum/reagent/medicine/atropine = 20, /datum/reagent/medicine/coagulant = 5)
	stripe_style = "epi"
	inhand_icon_state = "medipen"

/obj/item/reagent_containers/medipen/advanced/blood_loss
	name = "advanced hypovolemic-response autoinjector"
	desc = "An autoinjector designed to stabilize and rapidly reverse severe bloodloss. Has a two use system."
	volume = 100
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(50)
	list_reagents = list(/datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/coagulant = 10, /datum/reagent/iron = 20, /datum/reagent/medicine/salglu_solution = 60)
	stripe_style = "blood"
	inhand_icon_state = "stimpen"

/// Psyker gear
/obj/item/reagent_containers/medipen/gore
	name = "gore autoinjector"
	desc = "A ghetto-looking autoinjector filled with gore, aka dirty kronkaine. You probably shouldn't take this while on the job, but it is a super-stimulant. Don't take two at once."
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/drug/kronkaine/gore = 15)
	icon_state = "maintenance"
	base_icon_state = "maintenance"
	label_examine = FALSE

/////////////////////////
/// Deforest Medipens ///
/////////////////////////

// Pen basetype where the icon is gotten from
/obj/item/reagent_containers/medipen/deforest
	name = "non-functional Deforest autoinjector"
	desc = "A Deforest branded autoinjector, though this one seems to be both empty and non-functional."
	icon = 'monkestation/code/modules/blueshift/icons/deforest/injectors.dmi'
	icon_state = "default"
	volume = 25
	list_reagents = list()
	custom_price = PAYCHECK_COMMAND
	inject_others_time = 1.5 SECONDS

/obj/item/reagent_containers/medipen/deforest/Initialize(mapload)
	. = ..()
	amount_per_transfer_from_this = volume

// Twitch, because having sandevistans be implants is for losers, just inject it!
/obj/item/reagent_containers/medipen/deforest/twitch
	name = "TWitch sensory stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with 'TWitch' among other reagents. This drug is known to make \
		those who take it 'see faster', whatever that means."
	base_icon_state = "twitch"
	icon_state = "twitch"
	list_reagents = list(
		/datum/reagent/drug/twitch = 10,
		/datum/reagent/drug/maint/tar = 5,
		/datum/reagent/medicine/silibinin = 5,
		/datum/reagent/toxin/leadacetate = 5,
	)
	custom_price = PAYCHECK_COMMAND * 3.5

// Demoneye, for when you feel the need to become "fucking invincible"
/obj/item/reagent_containers/medipen/deforest/demoneye
	name = "DemonEye steroid injector"
	desc = "A Deforest branded autoinjector, loaded with 'DemonEye' among other reagents. This drug is known to make \
		those who take it numb to all pains and extremely difficult to kill as a result."
	base_icon_state = "demoneye"
	icon_state = "demoneye"
	list_reagents = list(
		/datum/reagent/drug/demoneye = 10,
		/datum/reagent/drug/maint/sludge = 10,
		/datum/reagent/toxin/leadacetate = 5,
	)
	custom_price = PAYCHECK_COMMAND * 3.5

// Mix of many of the stamina damage regenerating drugs to provide a cocktail no baton could hope to beat
/obj/item/reagent_containers/medipen/deforest/aranepaine
	name = "aranepaine combat stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a cocktail of drugs to make any who take it nearly \
		immune to exhaustion while its in their system."
	base_icon_state = "aranepaine"
	icon_state = "aranepaine"
	list_reagents = list(
		/datum/reagent/drug/aranesp = 5,
		/datum/reagent/drug/kronkaine = 5,
		/datum/reagent/drug/pumpup = 5,
		/datum/reagent/medicine/diphenhydramine = 5,
		/datum/reagent/impurity = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Nothing inherently illegal, just a potentially very dangerous mix of chems to be able to inject into people
/obj/item/reagent_containers/medipen/deforest/pentibinin
	name = "pentibinin normalizant injector"
	desc = "A Deforest branded autoinjector, loaded with a cocktail of drugs to make any who take it \
		recover from many different types of damages, with many unusual or undocumented side-effects."
	base_icon_state = "pentibinin"
	icon_state = "pentibinin"
	list_reagents = list(
		/datum/reagent/medicine/c2/penthrite = 5,
		/datum/reagent/medicine/polypyr = 5,
		/datum/reagent/medicine/silibinin = 5,
		/datum/reagent/medicine/omnizine = 5,
		/datum/reagent/inverse/healing/tirimol = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Combat stimulant that makes you immune to slowdowns for a bit
/obj/item/reagent_containers/medipen/deforest/synalvipitol
	name = "synalvipitol muscle stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a cocktail of drugs to make any who take it \
		nearly immune to the slowing effects of silly things like 'being tired' or 'facing muscle failure'."
	base_icon_state = "synalvipitol"
	icon_state = "synalvipitol"
	list_reagents = list(
		/datum/reagent/medicine/mine_salve = 5,
		/datum/reagent/medicine/synaptizine = 10,
		/datum/reagent/medicine/muscle_stimulant = 5,
		/datum/reagent/impurity = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Sensory restoration, heals eyes and ears with a bit of impurity
/obj/item/reagent_containers/medipen/deforest/occuisate
	name = "occuisate sensory restoration injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to restore your vision and hearing to operation."
	base_icon_state = "occuisate"
	icon_state = "occuisate"
	list_reagents = list(
		/datum/reagent/medicine/inacusiate = 7,
		/datum/reagent/medicine/oculine = 7,
		/datum/reagent/impurity/inacusiate = 3,
		/datum/reagent/inverse/oculine = 3,
		/datum/reagent/toxin/lipolicide = 5,
	)

// Adrenaline, fills you with determination (and also stimulants)
/obj/item/reagent_containers/medipen/deforest/adrenaline
	name = "adrenaline injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to intentionally give yourself fight or flight on demand."
	base_icon_state = "adrenaline"
	icon_state = "adrenaline"
	list_reagents = list(
		/datum/reagent/medicine/synaptizine = 5,
		/datum/reagent/medicine/inaprovaline = 5,
		/datum/reagent/determination = 10,
		/datum/reagent/toxin/histamine = 5,
	)

// Morpital, heals a small amount of damage and kills pain for a bit
/obj/item/reagent_containers/medipen/deforest/morpital
	name = "morpital regenerative stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to numb pain and repair small amounts of physical damage."
	base_icon_state = "morpital"
	icon_state = "morpital"
	list_reagents = list(
		/datum/reagent/medicine/painkiller/morphine = 5,
		/datum/reagent/medicine/omnizine/protozine = 15,
		/datum/reagent/toxin/staminatoxin = 5,
	)

// Lipital, heals more damage than morpital but doesnt work much at higher damages
/obj/item/reagent_containers/medipen/deforest/lipital
	name = "lipital regenerative stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to numb pain and repair small amounts of physical damage. \
		Works most effectively against damaged caused by brute attacks."
	base_icon_state = "lipital"
	icon_state = "lipital"
	list_reagents = list(
		/datum/reagent/medicine/lidocaine = 5,
		/datum/reagent/medicine/omnizine = 5,
		/datum/reagent/medicine/c2/probital = 10,
	)

// Anti-poisoning injector, with a little bit of radiation healing as a treat
/obj/item/reagent_containers/medipen/deforest/meridine
	name = "meridine antidote injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to serve as antidote to most galactic toxins. \
		A warning sticker notes it should not be used if the patient is physically damaged, as it may cause complications."
	base_icon_state = "meridine"
	icon_state = "meridine"
	list_reagents = list(
		/datum/reagent/medicine/c2/multiver = 10,
		/datum/reagent/medicine/potass_iodide = 10,
		/datum/reagent/nitrous_oxide = 5,
	)

// Epinephrine and helps a little bit against stuns and stamina damage
/obj/item/reagent_containers/medipen/deforest/synephrine
	name = "synephrine emergency stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of reagents to stabilize critical condition and recover from stamina deficits."
	base_icon_state = "synephrine"
	icon_state = "synephrine"
	list_reagents = list(
		/datum/reagent/medicine/epinephrine = 10,
		/datum/reagent/medicine/synaptizine = 5,
		/datum/reagent/medicine/synaphydramine = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Critical condition stabilizer
/obj/item/reagent_containers/medipen/deforest/calopine
	name = "calopine emergency stabilizant injector"
	desc = "A Deforest branded autoinjector, loaded with a stabilizing mix of reagents to repair critical conditions."
	base_icon_state = "calopine"
	icon_state = "calopine"
	list_reagents = list(
		/datum/reagent/medicine/atropine = 10,
		/datum/reagent/medicine/coagulant/fabricated = 5,
		/datum/reagent/medicine/salbutamol = 5,
		/datum/reagent/toxin/staminatoxin = 5,
	)

// Coagulant, really not a whole lot more
/obj/item/reagent_containers/medipen/deforest/coagulants
	name = "coagulant-S injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of coagulants to prevent and stop bleeding."
	base_icon_state = "coagulant"
	icon_state = "coagulant"
	list_reagents = list(
		/datum/reagent/medicine/coagulant = 5,
		/datum/reagent/medicine/salglu_solution = 15,
		/datum/reagent/impurity = 5,
	)

// Stimulant centered around ondansetron
/obj/item/reagent_containers/medipen/deforest/krotozine
	name = "krotozine manipulative stimulant injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of stimulants of weak healing agents."
	base_icon_state = "krotozine"
	icon_state = "krotozine"
	list_reagents = list(
		/datum/reagent/drug/kronkaine = 5,
		/datum/reagent/medicine/omnizine/protozine = 10,
		/datum/reagent/drug/maint/tar = 5,
	)
	custom_price = PAYCHECK_COMMAND * 2.5

// Stuff really good at healing burn stuff and stabilizing temps
/obj/item/reagent_containers/medipen/deforest/lepoturi
	name = "lepoturi burn treatment injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of medicines to rapidly treat burns."
	base_icon_state = "lepoturi"
	icon_state = "lepoturi"
	list_reagents = list(
		/datum/reagent/medicine/mine_salve = 5,
		/datum/reagent/medicine/leporazine = 5,
		/datum/reagent/medicine/c2/lenturi = 10,
		/datum/reagent/toxin/staminatoxin = 5,
	)

// Stabilizes a lot of stats like drowsiness, sanity, dizziness, so on
/obj/item/reagent_containers/medipen/deforest/psifinil
	name = "psifinil personal recovery injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of medicines to remedy many common ailments, such as drowsiness, pain, instability, the like."
	base_icon_state = "psifinil"
	icon_state = "psifinil"
	list_reagents = list(
		/datum/reagent/medicine/modafinil = 10,
		/datum/reagent/medicine/psicodine = 10,
		/datum/reagent/medicine/leporazine = 5,
	)

// Helps with liver failure and some drugs, also alcohol
/obj/item/reagent_containers/medipen/deforest/halobinin
	name = "halobinin soberant injector"
	desc = "A Deforest branded autoinjector, loaded with a mix of medicines to remedy the effects of liver failure and common drugs."
	base_icon_state = "halobinin"
	icon_state = "halobinin"
	list_reagents = list(
		/datum/reagent/medicine/haloperidol = 5,
		/datum/reagent/medicine/antihol = 5,
		/datum/reagent/medicine/higadrite = 5,
		/datum/reagent/medicine/silibinin = 5,
	)

// Medpen for robots that fixes toxin damage and purges synth chems but slows them down for a bit
/obj/item/reagent_containers/medipen/deforest/robot_system_cleaner
	name = "synthetic cleaner autoinjector"
	desc = "A Deforest branded autoinjector, loaded with system cleaner for purging synthetics of reagents."
	base_icon_state = "robor"
	icon_state = "robor"
	list_reagents = list(
		/datum/reagent/medicine/system_cleaner = 15,
		/datum/reagent/dinitrogen_plasmide = 5,
	)

// Medpen for robots that fixes brain damage but slows them down for a bit
/obj/item/reagent_containers/medipen/deforest/robot_liquid_solder
	name = "synthetic smart-solder autoinjector"
	desc = "A Deforest branded autoinjector, loaded with liquid solder to repair synthetic processor core damage."
	base_icon_state = "robor_brain"
	icon_state = "robor_brain"
	list_reagents = list(
		/datum/reagent/medicine/liquid_solder = 15,
		/datum/reagent/dinitrogen_plasmide = 5,
	)
