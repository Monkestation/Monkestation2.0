
/datum/bloodcult_ritual/altar
	name = "Prepare Altar"
	desc = "raise an altar...<br>add proper paraphernalia around...<br>then plant a ritual knife on top..."

	ritual_type = "altar"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	var/required_candles = 0
	var/required_tomes = 0
	var/required_runes = 0
	var/required_pylons = 0
	var/required_animal = 0
	var/required_humanoid = 0
	var/required_cultblade = 0

	keys = list("altar_plant")

/datum/bloodcult_ritual/altar/key_found(var/obj/structure/cult/altar/altar)
	var/mob/user = owner.owner.current

	var/valid = TRUE
	var/found_candles = 0
	for (var/obj/item/candle/blood/CB in range(1, altar))
		if (CB.lit)
			found_candles++
	if (found_candles < required_candles)
		to_chat(user, span_cult("Need more lit blood candles...") )
		valid = FALSE

	var/found_tomes = 0
	for (var/obj/item/tome/T in range(1, altar))
		found_tomes++
	if (found_tomes < required_tomes)
		to_chat(user, span_cult("Need more arcane tomes...") )
		valid = FALSE

	var/found_runes = 0
	for (var/obj/effect/new_rune/R in range(1, altar))
		found_runes++
	if (found_runes < required_runes)
		to_chat(user, span_cult("Need more runes...") )
		valid = FALSE

	var/found_pylons = 0
	for (var/obj/structure/cult/pylon/P in range(1, altar))
		found_pylons++
	if (found_pylons < required_pylons)
		to_chat(user, span_cult("You must construct additional pylons...") )
		valid = FALSE

	var/found_animal = FALSE
	var/found_humanoid = FALSE
	if(altar.has_buckled_mobs())
		var/mob/M = altar.buckled_mobs[1]
		if (ishuman(M))
			found_humanoid = TRUE
		if (ismonkey(M) || isanimal(M))
			found_animal = TRUE
	if (required_animal && !found_animal)
		to_chat(user, span_cult("You must impale an animal on top...") )
		valid = FALSE
	if (required_humanoid && !found_humanoid)
		to_chat(user, span_cult("You must impale an humanoid on top...") )
		valid = FALSE

	var/obj/item/melee/B = altar.blade
	if (required_cultblade && !istype(B))
		to_chat(user, span_cult("Lastly, a mere ritual knife won't do here. Forge a better implement...") )

	return valid
