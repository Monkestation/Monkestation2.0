//	This is where all of the MonkeStation Admin Plushies SHOULD be stored

// Plushies
/obj/item/toy/plush/admin
	name = "admin plushie"
	desc = "if you're seeing this there's an issue."
	icon = 'icons/obj/admin_plushies.dmi'
	icon_state = ""
	/// A string of text that is optionaly added to the objects desc, it SHOULD be the admin's CKEY.
	var/adminCKey = null
	// Whether or not to append (A member of our beloved admin team) to the end of the description
	var/append_note = TRUE

/obj/item/toy/plush/admin/Initialize(mapload)
	. = ..()
	if(append_note)
		if(adminCKey)
			desc = "[desc]" + " " + "(A member of our beloved admin team- ''[adminCKey]'')"
		else
			desc = "[desc]" + " " + "(A member of our beloved admin team)"

/obj/item/toy/plush/admin/ben_mothman
	name = "ben mothman"
	desc = "HAH this guy is short! Laugh at him.. this is an order!"
	icon_state = "ben"
	gender = MALE
/datum/loadout_item/plushies/ben_mothman
	name = "Ben Mothman plush"
	item_path = /obj/item/toy/plush/admin/ben_mothman
/datum/store_item/plushies/ben_mothman
	name = "Ben Mothman Plush"
	item_path = /obj/item/toy/plush/admin/ben_mothman
	item_cost = 7500

/obj/item/toy/plush/admin/abraxis
	name = "abraxis"
	desc = "This feller is always up to something.. he's even got that huge company I forgot the name of..."
	icon_state = "abraxis"
	gender = MALE
/datum/loadout_item/plushies/abraxis
	name = "Abraxis Plush"
	item_path = /obj/item/toy/plush/admin/abraxis
/datum/store_item/plushies/abraxis
	name = "Abraxis Plush"
	item_path = /obj/item/toy/plush/admin/abraxis
	item_cost = 7500

/obj/item/toy/plush/admin/brad
	name = "brad"
	desc = "Woah.. they're BLUE, and they've also got a cane! How fancy dancy."
	icon_state = "brad"
	gender = NEUTER
/datum/loadout_item/plushies/brad
	name = "Brad Plush"
	item_path = /obj/item/toy/plush/admin/brad
/datum/store_item/plushies/brad
	name = "Brad Plush"
	item_path = /obj/item/toy/plush/admin/brad
	item_cost = 7500

/obj/item/toy/plush/admin/andrea
	name = "andrea"
	desc = "Best combat medic around.. if your legs are blown off and you see this fellah comming around- you're lucky."
	icon_state = "andrea"
	gender = FEMALE
/datum/loadout_item/plushies/andrea
	name = "Andrea Plush"
	item_path = /obj/item/toy/plush/admin/andrea
/datum/store_item/plushies/andrea
	name = "Andrea Plush"
	item_path = /obj/item/toy/plush/admin/andrea
	item_cost = 7500

/obj/item/toy/plush/admin/antlers
	name = "Nikki"
	desc = "She seems dangerous. There's a tag wrapped around one of the ears... \"property of Antlers\". You ponder how a pair of antlers could own such an object."
	icon_state = "antlers"
	gender = FEMALE
/datum/loadout_item/plushies/antlers
	name = "Nikki Plush"
	item_path = /obj/item/toy/plush/admin/antlers
/datum/store_item/plushies/antlers
	name = "Nikki Plush"
	item_path = /obj/item/toy/plush/admin/antlers
	item_cost = 7500

/obj/item/toy/plush/admin/pippi
	name = "pippi"
	desc = "..."
	icon_state = "pippi"
	gender = FEMALE
/datum/loadout_item/plushies/pippi
	name = "Pippi Plush"
	item_path = /obj/item/toy/plush/admin/pippi
/datum/store_item/plushies/pippi
	name = "Pippi Plush"
	item_path = /obj/item/toy/plush/admin/pippi
	item_cost = 7500

/obj/item/toy/plush/admin/syndi_kate
	name = "syndi-kate"
	desc = "''GLORY TO THE SYNDICATE!''"
	icon_state = "syndi_kate"
	gender = FEMALE
/datum/loadout_item/plushies/syndi_kate
	name = "Syndi-Kate Plush"
	item_path = /obj/item/toy/plush/admin/syndi_kate
/datum/store_item/plushies/syndi_kate
	name = "Syndi-Kate Plush"
	item_path = /obj/item/toy/plush/admin/syndi_kate
	item_cost = 7500

/obj/item/toy/plush/admin/jace
	name = "jace"
	desc = "It's Jace!"
	icon_state = "jace"
	gender = FEMALE
/datum/loadout_item/plushies/jace
	name = "Jace Plush"
	item_path = /obj/item/toy/plush/admin/jace
/datum/store_item/plushies/jace
	name = "Jace Plush"
	item_path = /obj/item/toy/plush/admin/jace
	item_cost = 7500

/obj/item/toy/plush/admin/lavender
	name = "lavender"
	desc = "It's Lavender!"
	icon_state = "lavender"
	gender = FEMALE
/datum/loadout_item/plushies/lavender
	name = "Lavender Plush"
	item_path = /obj/item/toy/plush/admin/lavender
/datum/store_item/plushies/lavender
	name = "Lavender Plush"
	item_path = /obj/item/toy/plush/admin/lavender
	item_cost = 7500

/obj/item/toy/plush/admin/waffles
	name = "waffles"
	desc = "It's Waffles! What a wierdo!"
	icon_state = "waffles"
	gender = MALE
/datum/loadout_item/plushies/waffles
	name = "Waffles Plush"
	item_path = /obj/item/toy/plush/admin/waffles
/datum/store_item/plushies/waffles
	name = "Waffles Plush"
	item_path = /obj/item/toy/plush/admin/waffles
	item_cost = 7500

/obj/item/toy/plush/admin/vicky
	name = "vicky"
	desc = "It's Vicky!"
	icon_state = "vicky"
	gender = FEMALE
/datum/loadout_item/plushies/vicky
	name = "Vicky Plush"
	item_path = /obj/item/toy/plush/admin/vicky
/datum/store_item/plushies/vicky
	name = "Vicky Plush"
	item_path = /obj/item/toy/plush/admin/vicky
	item_cost = 7500

/obj/item/toy/plush/admin/richard_deckard
	name = "richard deckard"
	desc = "It's Richard Deckard!"
	icon_state = "richard_deckard"
	gender = MALE
/datum/loadout_item/plushies/richard_deckard
	name = "Richard Deckard Plush"
	item_path = /obj/item/toy/plush/admin/richard_deckard
/datum/store_item/plushies/richard_deckard
	name = "Richard Deckard Plush"
	item_path = /obj/item/toy/plush/admin/richard_deckard
	item_cost = 7500

/obj/item/toy/plush/admin/marisa
	name = "marisa"
	desc = "It's Marisa! THE GOOBER- LOOK AT HER!"
	icon_state = "marisa"
	gender = FEMALE
/datum/loadout_item/plushies/marisa
	name = "Marisa Plush"
	item_path = /obj/item/toy/plush/admin/marisa
/datum/store_item/plushies/marisa
	name = "Marisa Plush"
	item_path = /obj/item/toy/plush/admin/marisa
	item_cost = 7500

/obj/item/toy/plush/admin/raziel
	name = "raziel"
	desc = "It's Raziel! He smells of bubblegum, and looks like he'll commit arson if you dont watch em."
	icon_state = "raziel"
	gender = MALE

/datum/loadout_item/plushies/raziel
	name = "Raziel Plush"
	item_path = /obj/item/toy/plush/admin/raziel
/datum/store_item/plushies/raziel
	name = "Raziel Plush"
	item_path = /obj/item/toy/plush/admin/raziel
	item_cost = 7500

//Gabbie plush thingoes
/obj/item/toy/plush/admin/gabbie
	name = "gabbie"
	desc = "She looks a bit angry."
	icon_state = "gabbie"
	squeak_override = list('monkestation/sound/items/gabnoise.ogg'=1)
	gender = FEMALE
	append_note = FALSE
/datum/loadout_item/plushies/gabbie
	name = "Gabbie Plush"
	item_path = /obj/item/toy/plush/admin/gabbie
/datum/store_item/plushies/gabbie
	name = "Gabbie Plush"
	item_path = /obj/item/toy/plush/admin/gabbie
	item_cost = 7500

/obj/item/toy/plush/admin/gabbie/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/food/deadmouse))
		playsound(src.loc, 'sound/items/eatfood.ogg', 50)
		to_chat(user, span_warning("Gabbie chomps up the rat!"))
		src.desc = "She still looks angry, but less hungry."
		qdel(attacking_item)
	else if(istype(attacking_item, /obj/item/reagent_containers/cocaine))
		playsound(src.loc, 'monkestation/sound/items/sniff.ogg', 50)
		to_chat(user, span_warning("Gabbie inhales the powder!"))
		src.desc = "She still looks angry, but more high."
		qdel(attacking_item)

//End Gabbie plush thingoes

/obj/item/toy/plush/admin/amunsethep
	name = "amun set hep"
	desc = "CURSE OF THE SANDS BE UPON YOU!!!"
	icon_state = "amunsethep"
	gender = MALE
/datum/loadout_item/plushies/amunsethep
	name = "Amun Set Hep Plush"
	item_path = /obj/item/toy/plush/admin/amunsethep
/datum/store_item/plushies/amunsethep
	name = "Amun Set Hep Plush"
	item_path = /obj/item/toy/plush/admin/amunsethep
	item_cost = 7500

/obj/item/toy/plush/admin/tendsthefire
	name = "tends-the-fire"
	desc = "It's Tends-The-Fire!, what a lovable little lizard!"
	icon_state = "tendsthefire"
	gender = MALE
/datum/loadout_item/plushies/tendsthefire
	name = "Tends-The-Fire Plush"
	item_path = /obj/item/toy/plush/admin/tendsthefire
/datum/store_item/plushies/tendsthefire
	name = "Tends-The-Fire Plush"
	item_path = /obj/item/toy/plush/admin/tendsthefire
	item_cost = 7500

/obj/item/toy/plush/admin/haileyspire
	name = "hailey spire"
	desc = "It's Hailey Spire! They've got a BIG WRENCH- WATCH OUT!!!"
	icon_state = "haileyspire"
	gender = FEMALE
/datum/loadout_item/plushies/haileyspire
	name = "Hailey Spire Plush"
	item_path = /obj/item/toy/plush/admin/haileyspire
/datum/store_item/plushies/haileyspire
	name = "Hailey Spire Plush"
	item_path = /obj/item/toy/plush/admin/haileyspire
	item_cost = 7500

/obj/item/toy/plush/admin/sydneysahrin
	name = "sydney sahrin"
	desc = "It's Sydney Sahrin! Shortest plantmin!"
	icon_state = "sydneysahrin"
/datum/loadout_item/plushies/sydneysahrin
	name = "Sydney Sahrin Plush"
	item_path = /obj/item/toy/plush/admin/sydneysahrin
/datum/store_item/plushies/sydneysahrin
	name = "Sydney Sahrin Plush"
	item_path = /obj/item/toy/plush/admin/sydneysahrin
	item_cost = 7500

/obj/item/toy/plush/admin/veth
	name = "veth"
	desc = "It's Veth! Suprisingly not upside down!"
	icon_state = "veth"
/datum/loadout_item/plushies/veth
	name = "Veth Plush"
	item_path = /obj/item/toy/plush/admin/veth
/datum/store_item/plushies/veth
	name = "Veth Plush"
	item_path = /obj/item/toy/plush/admin/veth
	item_cost = 7500

/obj/item/toy/plush/admin/cassielpip
	name = "cassiel pip"
	desc = "Smelly Rat."
	icon_state = "cassielpip"
/datum/loadout_item/plushies/cassielpip
	name = "Cassiel Pip Plush"
	item_path = /obj/item/toy/plush/admin/cassielpip
/datum/store_item/plushies/cassielpip
	name = "Cassiel Pip Plush"
	item_path = /obj/item/toy/plush/admin/cassielpip
	item_cost = 7500

/obj/item/toy/plush/admin/fortune
	name = "fortune"
	desc = "It's Fortune- the Felinid!"
	icon_state = "fortune"
	gender = FEMALE

/datum/loadout_item/plushies/fortune
	name = "Fortune Plush"
	item_path = /obj/item/toy/plush/admin/fortune

/datum/store_item/plushies/fortune
	name = "Fortune Plush"
	item_path = /obj/item/toy/plush/admin/fortune
	item_cost = 7500

/obj/item/toy/plush/admin/weegee
	name = "weegee"
	desc = "He's staring into your soul..."
	icon_state = "weegee"
	squeak_override = list('monkestation/sound/items/weegee.ogg'=1)
	gender = MALE
/datum/loadout_item/plushies/weegee
	name = "Weegee Plush"
	item_path = /obj/item/toy/plush/admin/weegee
/datum/store_item/plushies/weegee
	name = "Weegee Plush"
	item_path = /obj/item/toy/plush/admin/weegee
	item_cost = 7500

/obj/item/toy/plush/admin/ropes
	name = "learns-the-ropes"
	desc = "A plushie depicting the most marketable weh."
	icon_state = "ropes"
	gender = MALE
/datum/loadout_item/plushies/ropes
	name = "Learns-The-Ropes Plush"
	item_path = /obj/item/toy/plush/admin/ropes
/datum/store_item/plushies/ropes
	name = "Learns-The-Ropes Plush"
	item_path = /obj/item/toy/plush/admin/ropes
	item_cost = 7500

/obj/item/toy/plush/admin/horsey
	name = "QB"
	desc = "Centcom...the horse is here."
	icon_state = "horsey"
	squeak_override = list('monkestation/sound/items/subuluwa.ogg'=1)
	gender = FEMALE
/datum/loadout_item/plushies/horsey
	name = "QB Plush"
	item_path = /obj/item/toy/plush/admin/horsey
/datum/store_item/plushies/hornsey
	name = "QB Plush"
	item_path = /obj/item/toy/plush/admin/horsey
	item_cost = 7500

/obj/item/toy/plush/admin/barnaby
	name = "barnaby"
	desc = "Time to cause some chaos."
	icon_state = "barnaby"
/datum/loadout_item/plushies/barnaby
	name = "Barnaby Plush"
	item_path = /obj/item/toy/plush/admin/barnaby
/datum/store_item/plushies/barnaby
	name = "Barnaby Plush"
	item_path = /obj/item/toy/plush/admin/barnaby
	item_cost = 7500

/obj/item/toy/plush/admin/jay
	name = "jay kouri"
	desc = "Doesn't seem to get a break. From making sure his underlings in the war dont die, to making sure the station's crew doesn't kill each other. Has beautiful blue eyes though, too bad he doesn't take off his sunglasses."
	icon_state = "jay"
	squeak_override = list('sound/weapons/gun/rifle/shot.ogg'=1)
/datum/loadout_item/plushies/jay
	name = "Jay Kouri Plush"
	item_path = /obj/item/toy/plush/admin/jay
/datum/store_item/plushies/jay
	name = "Jay Kouri Plush"
	item_path = /obj/item/toy/plush/admin/jay
	item_cost = 7500

/obj/item/toy/plush/admin/azkare
	name = "azkare uw"
	desc = "You could swear the eyes behind the mask moved when you weren't looking."
	icon_state = "azkare"
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	light_power = 0.5
	light_color = "#B3D9FF"
	light_on = TRUE
/datum/loadout_item/plushies/azkare
	name = "Azkare UW Plush"
	item_path = /obj/item/toy/plush/admin/azkare
/datum/store_item/plushies/azkare
	name = "Azkare UW Plush"
	item_path = /obj/item/toy/plush/admin/azkare
	item_cost = 7500

/obj/item/toy/plush/admin/altjira
	name = "altjira xc"
	desc = "Tongue tied, slightly psychotic, and usually 'forgets' her medication."
	icon_state = "altjira"
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	light_power = 0.5
	light_color = "#3399ff"
	light_on = TRUE
/datum/loadout_item/plushies/altjira
	name = "Altjira Plush"
	item_path = /obj/item/toy/plush/admin/altjira
/datum/store_item/plushies/altjira
	name = "Altjira Plush"
	item_path = /obj/item/toy/plush/admin/altjira
	item_cost = 7500

/obj/item/toy/plush/admin/autumn
	name = "autumn hynes"
	desc = "This voiceless friend is here to help! Feels like someone's watching, though…"
	icon_state = "autumn"
/datum/loadout_item/plushies/autumn
	name = "Autumn Hynes Plush"
	item_path = /obj/item/toy/plush/admin/autumn
/datum/store_item/plushies/autumn
	name = "Autumn Hynes Plush"
	item_path = /obj/item/toy/plush/admin/autumn
	item_cost = 7500

/obj/item/toy/plush/admin/siro
	name = "siro yamamuchi"
	desc = "Our adorable staff coder slimegirl! We love you Siro!"
	icon_state = "siro-mask"
	append_note = FALSE
	attack_verb_continuous = list("bloops", "blurbles", "glomps")
	attack_verb_simple = list("bloop", "blurble", "glomp")
	squeak_override = list('sound/effects/footstep/slime1.ogg' = 1)
	gender = FEMALE
/datum/loadout_item/plushies/siro
	name = "Siro Yamamuchi Plush"
	item_path = /obj/item/toy/plush/admin/siro
/datum/store_item/plushies/siro
	name = "Siro Yamamuchi Plush"
	item_path = /obj/item/toy/plush/admin/siro
	item_cost = 7500
/obj/item/toy/plush/admin/siro/AltClick(mob/user)
	if(icon_state == "siro")
		icon_state = "siro-mask"
	else
		icon_state = "siro"


/** SHION PLUSH START **/
// A collective gift from @Flleeppyy/Chen, @Veth-s/Phatarsh, and Cannibal_Hunter
/obj/item/toy/plush/admin/shion
	name = "shion"
	desc = "It's Shion! She's one of our beloved maintainers and sysadmins!"
	icon_state = "shion-bald"
	gender = FEMALE
	var/mask_on = FALSE
	var/shaved = FALSE
	var/brushed = 0
	var/static/plushckey = "absolucy"

/datum/loadout_item/plushies/shion
		name = "Shion Plush"
		item_path = /obj/item/toy/plush/admin/shion

/datum/store_item/plushies/shion
		name = "Shion Plush"
		item_path = /obj/item/toy/plush/admin/shion
		item_cost = 7500

/obj/item/toy/plush/admin/shion/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/toy/plush/admin/shion/update_overlays()
	. = ..()
	if (!shaved)
		. += "shion-hair"
	if (mask_on)
		. += "shion-mask"

/obj/item/toy/plush/admin/shion/AltClick(mob/living/user)
	if(!Adjacent(user) || user.incapacitated())
		return
	mask_on = !mask_on

	update_appearance(UPDATE_OVERLAYS)

/obj/item/toy/plush/admin/shion/examine(mob/user)
	. = ..()
	var/holder_is_lucy = user?.ckey == plushckey
	if (holder_is_lucy)
		. += span_purple("[EXAMINE_SECTION_BREAK][EXAMINE_HINT("IT'S MEE!!!!")]")
	if (shaved)
		. += span_warning("OH GOD [holder_is_lucy ? "I'M" : "SHE'S"] BALD!")
		if (brushed > 2)
			. += span_warning("[holder_is_lucy ? "MY" : "HER"] WONDERFULLY BRUSHED HAIR IS GONE! ALL THAT EFFORT FOR NOTHING!")
		. += span_notice("But what if... I [EXAMINE_HINT("stitched a wig")] to it?")
	else if (brushed)
		switch(brushed)
			if(1 to 2)
				. += span_notice("Her hair has been brushed!")
			if(2 to 5)
				. += span_notice("Her hair has been brushed! It looks very pretty!")
			if(5 to 10)
				. += span_notice("Her hair has been brushed! It looks extravegant!")
			if(10 to 30)
				. += span_notice("Her hair has been brushed! It's been brushed to the point of perfection!")
			if(30 to 50)
				. += span_notice("Her hair has been brushed! No barber in the sector can brush hair better than this. It's truly beautiful.")
			if(50 to INFINITY)
				. += span_notice("Her hair has been brushed! It sparkles with beauty! It's the most beautiful hair in the galaxy!")

/obj/item/toy/plush/admin/shion/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/razor))
		if(shaved)
			to_chat(user, span_warning("You can't shave [src], she has already been shaved!"))
			return
		user.visible_message(span_notice("[user] shaves [src] using \the [attacking_item].<br>Oh dear god she's bald!"), span_notice("You shave [src] using \the [attacking_item]."))
		shaved = TRUE
		update_appearance(UPDATE_OVERLAYS)
	if(istype(attacking_item, /obj/item/clothing/head/wig))
		user.visible_message(span_notice("[user] carefully starts to stitch \the [attacking_item] onto [src]."), span_notice("You start to carefully stitch \the [attacking_item] to \the [src]..."))
		if (do_after(user, 10 SECONDS))
			qdel(attacking_item)
			to_chat(user, span_notice("Perfect!"))
			shaved = FALSE
			brushed = 0
			update_appearance(UPDATE_OVERLAYS)
	if(istype(attacking_item, /obj/item/hairbrush))
		var/obj/item/hairbrush/hairbrush = attacking_item
		if (shaved)
			to_chat(user, span_warning("You can't brush [src], she has no hair!"))
			return
		if (do_after(user, hairbrush.brush_speed))
			user.visible_message(span_notice("[user] brushes [src]'s hair!"), span_notice("You brush [src]'s hair."))
			if (user?.ckey == plushckey)
				brushed = brushed + 4
			else
				brushed++
			if (brushed > 50 && !GetComponent(/datum/component/particle_spewer/sparkle))
				AddComponent(/datum/component/particle_spewer/sparkle)
/** SHION PLUSH END **/

/obj/item/toy/plush/admin/mcsteal
	name = "Robert McPlushie"
	desc = "Holy fuck, he McStole a plushie tank."
	icon_state = "mcsteal"
	squeak_override = list('sound/weapons/gun/general/lighttankgun.ogg'=1)
/datum/loadout_item/plushies/mcsteal
	name = "McSteal Plush"
	item_path = /obj/item/toy/plush/admin/mcsteal
/datum/store_item/plushies/mcsteal
	name = "McSteal Plush"
	item_path = /obj/item/toy/plush/admin/mcsteal
	item_cost = 7500
