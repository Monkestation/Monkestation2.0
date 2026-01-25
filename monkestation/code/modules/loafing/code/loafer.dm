/obj/structure/disposalpipe/loafer
	name = "loafing device"
	desc = "A prisoner feeding device that condenses matter into an Ultra Delicious(tm) nutrition bar!"
	icon = 'monkestation/code/modules/loafing/icons/obj.dmi'
	icon_state = "loafer"
	base_icon_state = "loafer"
	construct_type = /obj/structure/disposalconstruct/loafer
	var/is_loafing = FALSE
	var/static/list/loaf_blacklist

/obj/structure/disposalpipe/loafer/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()
	if(isnull(loaf_blacklist))
		loaf_blacklist = zebra_typecacheof(list(
			/obj/item/organ/internal/brain = TRUE,
			/obj/item/organ/internal/brain/primate = FALSE,
			/obj/item/bodypart/head = TRUE,
			/obj/item/bodypart/head/monkey = FALSE,
		))

/obj/structure/disposalpipe/loafer/examine(mob/user)
	. = ..()
	if((obj_flags & EMAGGED) && (isobserver(user) || Adjacent(user)))
		. += span_warning("A small mechanism on the side of the loafer seems to be fried.")

/obj/structure/disposalpipe/loafer/transfer(obj/structure/disposalholder/holder)
	if(is_loafing)
		return src
	//check if there's anything in there
	if (length(holder.contents))
		//start playing sound
		is_loafing = TRUE
		update_appearance()
		playsound(src, 'monkestation/code/modules/loafing/sound/loafer.ogg', vol = 100, vary = TRUE, mixer_channel = CHANNEL_MACHINERY)

		//create new loaf
		var/obj/item/food/prison_loaf/loaf = new /obj/item/food/prison_loaf(src)

		//add all the garbage to the loaf's contents
		for (var/atom/movable/debris in holder)
			if((debris.resistance_flags & INDESTRUCTIBLE) || HAS_TRAIT(debris, TRAIT_GODMODE) || is_type_in_typecache(debris, loaf_blacklist))
				if(length(holder.contents) > 1)
					continue
				loaf = null
				is_loafing = FALSE
				update_appearance()
				return transfer_to_dir(holder, nextdir(holder))
			debris.reagents?.trans_to(loaf, 1000)
			if(istype(debris, /obj/item/food/prison_loaf))//the object is a loaf, compress somehow
				var/obj/item/food/prison_loaf/loaf_to_grind = debris
				loaf.loaf_density += loaf_to_grind.loaf_density * 1.05
				loaf_to_grind = null
			else if(isliving(debris))
				var/mob/living/victim = debris
				//different mobs add different reagents
				if(issilicon(victim))
					loaf.reagents.add_reagent(/datum/reagent/fuel, 10)
					loaf.reagents.add_reagent(/datum/reagent/iron, 10)
				else
					loaf.reagents.add_reagent(/datum/reagent/bone_dust, 3)
					loaf.reagents.add_reagent(/datum/reagent/ammonia/urine, 2)
					loaf.reagents.add_reagent(/datum/reagent/consumable/liquidgibs, 2)
					loaf.reagents.add_reagent(/datum/reagent/consumable/nutriment/organ_tissue, 2)
				//then we give the loaf more power
				if(ishuman(victim))
					loaf.loaf_density += 25
				else
					loaf.loaf_density += 10
				if(victim.stat != DEAD)
					victim.emote("scream")
				victim.gib()
				if(victim.mind || victim.client)
					victim.ghostize(can_reenter_corpse = FALSE)
			else if (isitem(debris))//everything else
				var/obj/item/kitchen_sink = debris
				loaf.loaf_density += kitchen_sink.w_class * 3
			holder.contents -= debris
			qdel(debris)

		if(!(obj_flags & EMAGGED))
			loaf.loaf_density = min(loaf.loaf_density, 100000) // density can never surpass the criticality threshold if it not emagged

		sleep(3 SECONDS)

		//condense the loaf
		loaf.condense()
		//place the loaf
		loaf.forceMove(holder)
		holder.contents += loaf
		is_loafing = FALSE
		update_appearance()
	return transfer_to_dir(holder, nextdir(holder))

/obj/structure/disposalpipe/loafer/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	visible_message(span_warning("Sparks fly out of [src]!"))
	if(user)
		balloon_alert(user, "safety limits disabled")
		user.log_message("emagged [src].", LOG_ATTACK)
	return TRUE

/obj/structure/disposalpipe/loafer/update_icon_state()
	icon_state = "[base_icon_state][is_loafing ? "-on" : ""]"
	return ..()

/obj/structure/disposalpipe/loafer/emagged // in case an admin wants to spawn in a pre-emagged one
	obj_flags = parent_type::obj_flags | EMAGGED

/obj/structure/disposalconstruct/loafer
	name = "loafing device"
	desc = "A prisoner feeding device that condenses matter into an Ultra Delicious(tm) nutrition bar!"
	icon = 'monkestation/code/modules/loafing/icons/obj.dmi'
	icon_state = "conloafer"
	pipe_type = /obj/structure/disposalpipe/loafer


//spawning

/obj/effect/spawner/random/loafer
	name = "loafer spawner"
	spawn_scatter_radius = 5
	spawn_loot_chance = 20
	layer = DISPOSAL_PIPE_LAYER

/obj/effect/spawner/random/loafer/Initialize(mapload)
	loot = list(/obj/structure/disposalpipe/loafer)
	return ..()
