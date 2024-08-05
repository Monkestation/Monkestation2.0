/obj/item/melee/baseball_bat/spiked
	name = "spiked baseball bat"
	desc = "A wooden bat with metal spikes crudely attached"
	icon = 'hippiestation/icons/obj/weapons.dmi'
	icon_state = "hippie_bbat_spike"
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	force = 17
	throwforce = 17
	armour_penetration = 10

/obj/item/hatchet/improvised
	name = "glass hatchet"
	desc = "A makeshift hand axe with a crude blade of broken glass."
	icon = 'hippiestation/icons/obj/weapons.dmi'
	icon_state = "glasshatchet"
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	force = 11
	throwforce = 14

/obj/item/pimpstick
	name = "pimp stick"
	desc = "A gold-rimmed cane, with a gleaming diamond set at the top. Great for bashing in kneecaps."
	icon = 'hippiestation/icons/obj/weapons.dmi'
	icon_state = "pimpstick"
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_simple = list("pimp", "smack", "discipline", "bust", "cap", "deck")
	attack_verb_continuous = list("pimps", "smacks", "disciplines", "busts", "caps", "decks")

/obj/item/pimpstick/suicide_act(mob/user)
		user.visible_message(span_suicide("[user] is hitting [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to discipline [user.p_them()]self for being a mark-ass trick"))
		return (BRUTELOSS)
