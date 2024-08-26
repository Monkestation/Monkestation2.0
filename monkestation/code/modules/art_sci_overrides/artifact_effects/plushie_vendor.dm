/datum/artifact_effect/plushie
	examine_hint = "Has some sort of claw mechanism."

	examine_discovered = "Its a claw machine of some kind"

	weight = ARTIFACT_UNCOMMON

	activation_message = "summons a toy of some kind!"

	type_name = "Toy Vender Effect"
	research_value = 250

	var/static/list/obj/item/toy/plush/plushies = list()
/datum/artifact_effect/plushie/effect_activate(silent)
	if(!length(plushies))
		plushies = typecacheof(/obj/item/toy/plush,ignore_root_path = TRUE) //I am not responsible for if this is a bad idea.
	var/obj/item/toy/plush/boi_path = pick(plushies)
	var/obj/item/toy/plush/boi = new boi_path
	boi.forceMove(our_artifact.holder.loc)
	if(prob(clamp(potency-50,0,100)))
		boi.AddComponent(/datum/component/spirit_holding,boi)
		var/datum/component/spirit_holding/spiritholder = our_artifact.GetComponent(/datum/component/spirit_holding)
		if(!(spiritholder.bound_spirit.client))
			var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
			"Do you want to play as [boi]",
			check_jobban = ROLE_SENTIENCE,
			poll_time = 15 SECONDS,
			ignore_category = POLL_IGNORE_SHADE,
			alert_pic = boi,
			role_name_text = "[boi]",
		)
			if(!LAZYLEN(candidates))
				return
			var/mob/dead/observer/chosen_spirit = pick(candidates)
			spiritholder.bound_spirit = new(boi)
			spiritholder.bound_spirit.ckey = chosen_spirit.ckey
			spiritholder.bound_spirit.fully_replace_character_name(null, "[boi]")
			spiritholder.bound_spirit.status_flags |= GODMODE
			spiritholder.bound_spirit.grant_all_languages(FALSE, FALSE, TRUE) //Grants omnitongue
			spiritholder.bound_spirit.update_atom_languages()
