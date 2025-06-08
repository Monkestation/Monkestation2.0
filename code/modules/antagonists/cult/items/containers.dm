/obj/item/storage/cult
	name = "coffer"
	desc = "A gloomy-looking storage chest."
	icon = 'monkestation/code/modules/bloody_cult/icons/storage.dmi'
	icon_state = "cult"

/obj/item/reagent_containers/cup/cult
	name = "tempting goblet"
	desc = "An obsidian cup in the shape of a skull. Used by the followers of Nar-Sie to collect the blood of their sacrifices."
	icon_state = "cult"
	icon = 'monkestation/code/modules/bloody_cult/icons/reagent_containers.dmi'

	fill_icon = 'monkestation/code/modules/bloody_cult/icons/reagentfillings.dmi'
	fill_icon_state = "cult"
	amount_per_transfer_from_this = 10
	volume = 60
	force = 5
	throwforce = 7

/obj/item/reagent_containers/cup/cult/examine(mob/user)
	..()
	if (IS_CULTIST(user))
		. += "Drinking blood from this cup will always safely replenish your own vessels, regardless of blood types. The opposite is true to non-cultists. Throwing this cup at them may force them to swallow some of its content if their face isn't covered."


/obj/item/reagent_containers/cup/cult/throw_impact(atom/hit_atom)
	if(reagents.total_volume)
		if (ishuman(hit_atom))
			var/mob/living/carbon/human/H = hit_atom
			if(!(H.is_mouth_covered()))
				H.visible_message("<span class='warning'>Some of \the [src]'s content spills into \the [H]'s mouth.</span>","<span class='danger'>Some of \the [src]'s content spills into your mouth.</span>")
				reagents.trans_to(H, gulp_size, methods = INGEST)

/obj/item/reagent_containers/cup/cult/gamer
	name = "gamer goblet"
	desc = "A plastic cup in the shape of a skull. Typically full of Geometer-Fuel."

/obj/item/reagent_containers/cup/cult/narsie_act()
	return

/obj/item/reagent_containers/cup/cult/bloodfilled

/obj/item/reagent_containers/cup/cult/bloodfilled/New()
	..()
	reagents.add_reagent(/datum/reagent/blood, 50)
