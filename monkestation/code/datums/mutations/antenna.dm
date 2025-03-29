/datum/mutation/human/antenna
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/antenna/modify()
	. = ..()
	if(owner && GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.update_mutations_overlay()

	if(GET_MUTATION_POWER(src) == 1 || isnull(radio_weakref))
		return

	var/obj/item/implant/radio/antenna/linked_radio = radio_weakref.resolve()
	if(!linked_radio)
		return

	var/list/random_keys = list(
		/obj/item/encryptionkey/headset_eng,
		/obj/item/encryptionkey/headset_med,
		/obj/item/encryptionkey/headset_sci,
		/obj/item/encryptionkey/headset_cargo,
		/obj/item/encryptionkey/headset_service,
	)
	var/obj/item/encryptionkey/lucky_winner = pick(random_keys) // Let's go gambling!
	if(linked_radio.radio.keyslot)
		qdel(linked_radio.radio.keyslot)

	linked_radio.radio.keyslot = new lucky_winner
	linked_radio.radio.recalculateChannels()

/datum/mutation/human/antenna/get_visual_indicator()
	if(GET_MUTATION_SYNCHRONIZER(src) < 1) // Stealth
		return FALSE
	return visual_indicators[type][1]

/datum/mutation/human/mindreader
	energy_coeff = 1
