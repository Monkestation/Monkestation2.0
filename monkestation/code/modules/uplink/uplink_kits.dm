#define KIT_AMATEUR_ASSASSIN "amateur_assassin"
#define KIT_INTERN_INFILTRATOR "intern_infiltrator"
#define KIT_BEGINNER_BOMBER "beginner_bomber"
#define KIT_STARTER_SABOTEUR "starter_saboteur"
#define KIT_ROOKIE_RAIDER "rookie_raider"

/obj/item/storage/box/syndie_kit/mini_kit
	name = "Syndicate Mini-Kit"
	desc = "A compact, unassuming box. Contains a starter set of basic tools."
	icon_state = "mini_syndiebox"
	illustration = null

/obj/item/paper/mini_kit_guide
	name = "Syndicate Field Note (Mini-Kit)"
	desc = "A hastily written note. Seems important though, that's why it's red."
	color = "#b94030"
	can_be_folded = FALSE
	var/has_been_read = FALSE
	default_raw_text ={"
<br><B>Syndicate Operative Field Note</B>
<br>
<br><B>NOTICE:</B> This message will self-incinerate in <I>20 seconds</I> after being opened.
<br>
<br><B>Kit Contents:</B> Each Mini-Kit contains a randomized loadout. Open the box to inspect your tools and adapt accordingly.
<br>
<br><B>Using Your Uplink:</B> Your telecrystal uplink is your lifeline. Spend wisely. This kit saves TC to give you flexibility. Keep it locked and hidden when not in use.
<br>
<br><B>Disposal:</B> Once you've taken all items from the kit, hold the empty box and press <B>Z</B> (or your 'Activate Item in Hand' key). The box will fold into an inconspicuous piece of cardboard.
<br>
<br>This note will auto-incinerate momentarily.
<br>
<br><I>Failure is not an option. Succeed or die trying.</I>
	"}

/obj/item/paper/mini_kit_guide/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/paper/mini_kit_guide/examine(mob/user)
	. = ..()

	if(!has_been_read)
		return

	. += span_warning("This feels warm to the touch.")


/obj/item/paper/mini_kit_guide/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	if(ui && !has_been_read)
		playsound(user, 'sound/machines/click.ogg', 25)
		to_chat(user, span_warning("You hear a faint click as you open the note. It feels strangely warm."))

		has_been_read = TRUE

		addtimer(CALLBACK(src, PROC_REF(combust_now)), 20 SECONDS, TIMER_UNIQUE)
	return

/obj/item/paper/mini_kit_guide/proc/combust_now(mob/user_who_initiated)
	if(!src || QDELETED(src))
		return

	SStgui.close_uis(src)

	var/mob/living/holder = null
	if(ismob(loc))
		holder = loc

	if(holder)
		to_chat(holder, span_warning("[src] suddenly bursts into flames in your hands!"))
	else if(get_turf(src))
		var/atom/turf_location = get_turf(src)
		turf_location.visible_message(span_warning("[src] suddenly bursts into flames on the ground!"))
	else if(loc)
		loc.visible_message(span_warning("[src] suddenly bursts into flames!"))

	fire_act(100)

/obj/item/storage/box/syndie_kit/mini_kit/PopulateContents()
	new /obj/item/paper/mini_kit_guide(src)
	switch (pick_weight(list(
		KIT_AMATEUR_ASSASSIN = 3,
		KIT_INTERN_INFILTRATOR = 3,
		KIT_BEGINNER_BOMBER = 2,
		KIT_STARTER_SABOTEUR = 3,
		KIT_ROOKIE_RAIDER = 2
		)))
		if(KIT_AMATEUR_ASSASSIN)
			new /obj/item/storage/pill_bottle/syndicate/poison(src)
			new /obj/item/pen/sleepy(src)
			new /obj/item/clothing/gloves/latex/nitrile(src)
			new /obj/item/soap/syndie(src)
			new /obj/item/pen/edagger(src)
			new /obj/item/restraints/handcuffs(src)
			new /obj/item/stack/sticky_tape(src)
			new /obj/item/clothing/glasses/blindfold(src)

		if(KIT_INTERN_INFILTRATOR)
			new /obj/item/storage/toolbox/syndicate(src)
			new /obj/item/storage/box/syndie_kit/chameleon(src)
			new /obj/item/encryptionkey/syndicate(src)
			new /obj/item/card/id/advanced/chameleon(src)
			new /obj/item/reagent_containers/syringe/mulligan(src)

		if(KIT_BEGINNER_BOMBER)
			new /obj/item/grenade/syndieminibomb(src)
			new /obj/item/grenade/chem_grenade/teargas(src)
			new /obj/item/grenade/smokebomb(src)
			new /obj/item/grenade/frag(src)
			new /obj/item/grenade/frag(src)
			new /obj/item/traitor_machine_trapper/door_charge(src)

		if(KIT_STARTER_SABOTEUR)
			new /obj/item/card/emag(src)
			new /obj/item/jammer(src)
			new /obj/item/crowbar/power/syndicate(src)
			new /obj/item/clothing/mask/balaclava(src)
			new /obj/item/multitool/ai_detect(src)

		if(KIT_ROOKIE_RAIDER)
			new /obj/item/gun/ballistic/automatic/pistol/sol/evil(src)
			new /obj/item/storage/box/syndie_kit/weapons_auth(src)
			new /obj/item/ammo_box/magazine/c35sol_pistol(src)
			new /obj/item/switchblade(src)
			new /obj/item/reagent_containers/hypospray/medipen/stimulants(src)
			new /obj/item/clothing/shoes/chameleon/noslip(src)

	return

#undef KIT_AMATEUR_ASSASSIN
#undef KIT_INTERN_INFILTRATOR
#undef KIT_BEGINNER_BOMBER
#undef KIT_STARTER_SABOTEUR
#undef KIT_ROOKIE_RAIDER
