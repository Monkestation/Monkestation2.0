/obj/item/weapon/bloodcult_jaunter
	name = "test jaunter"
	desc = ""
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	var/obj/structure/bloodcult_jaunt_target/target = null

/obj/item/weapon/bloodcult_jaunter/New()
	..()
	target = new(loc)

/obj/item/weapon/bloodcult_jaunter/attack_self(mob/user)
	new /obj/effect/bloodcult_jaunt(get_turf(src), user, get_turf(target))

/obj/structure/bloodcult_jaunt_target
	name = "test target"
	desc = ""
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state ="pylon"
	anchored = 1
	density = 0
