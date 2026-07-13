
//Apprenticeship contract - moved to antag_spawner.dm

///////////////////////////Veil Render//////////////////////

/obj/item/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "bone_blade"
	inhand_icon_state = "bone_blade"
	worn_icon_state = "bone_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/charges = 1
	var/spawn_type = /obj/tear_in_reality
	var/spawn_amt = 1
	var/activate_descriptor = "reality"
	var/rend_desc = "You should run now."
	var/spawn_fast = FALSE //if TRUE, ignores checking for mobs on loc before spawning

/obj/item/veilrender/attack_self(mob/user)
	if(charges > 0)
		new /obj/effect/rend(get_turf(user), spawn_type, spawn_amt, rend_desc, spawn_fast)
		charges--
		user.visible_message(span_boldannounce("[src] hums with power as [user] deals a blow to [activate_descriptor] itself!"))
	else
		to_chat(user, span_danger("The unearthly energies that powered the blade are now dormant."))

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/effects/effects.dmi'
	icon_state = "rift"
	density = TRUE
	anchored = TRUE
	var/spawn_path = /mob/living/basic/cow //defaulty cows to prevent unintentional narsies
	var/spawn_amt_left = 20
	var/spawn_fast = FALSE

/obj/effect/rend/Initialize(mapload, spawn_type, spawn_amt, desc, spawn_fast)
	. = ..()
	src.spawn_path = spawn_type
	src.spawn_amt_left = spawn_amt
	src.desc = desc
	src.spawn_fast = spawn_fast
	START_PROCESSING(SSobj, src)

/obj/effect/rend/process()
	if(!spawn_fast)
		if(locate(/mob) in loc)
			return
	new spawn_path(loc)
	spawn_amt_left--
	if(spawn_amt_left <= 0)
		qdel(src)

/obj/effect/rend/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/nullrod))
		user.visible_message(span_danger("[user] seals \the [src] with \the [attacking_item]."))
		qdel(src)
		return
	else
		return ..()

/obj/effect/rend/singularity_act()
	return

/obj/effect/rend/singularity_pull()
	return

/obj/item/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	spawn_type = /mob/living/basic/cow
	spawn_amt = 20
	activate_descriptor = "hunger"
	rend_desc = "Reverberates with the sound of ten thousand moos."

/obj/item/veilrender/honkrender
	name = "honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus."
	spawn_type = /mob/living/basic/clown
	spawn_amt = 10
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of endless laughter."
	icon_state = "banana_blade"
	inhand_icon_state = "banana_blade"
	worn_icon_state = "render"

/obj/item/veilrender/honkrender/honkhulkrender
	name = "superior honk render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast circus. This one gleams with a special light."
	spawn_type = /mob/living/basic/clown/clownhulk
	spawn_amt = 5
	activate_descriptor = "depression"
	rend_desc = "Gently wafting with the sounds of mirthful grunting."

#define TEAR_IN_REALITY_CONSUME_RANGE 3
#define TEAR_IN_REALITY_SINGULARITY_SIZE STAGE_FOUR

/// Tear in reality, spawned by the veil render
/obj/tear_in_reality
	name = "tear in the fabric of reality"
	desc = "This isn't right."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	pixel_x = -96
	pixel_y = -96
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	plane = MASSIVE_OBJ_PLANE
	plane = ABOVE_LIGHTING_PLANE
	light_outer_range = 6
	appearance_flags = LONG_GLIDE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION

/obj/tear_in_reality/Initialize(mapload)
	. = ..()

	AddComponent(
		/datum/component/singularity, \
		consume_range = TEAR_IN_REALITY_CONSUME_RANGE, \
		notify_admins = !mapload, \
		roaming = FALSE, \
		singularity_size = TEAR_IN_REALITY_SINGULARITY_SIZE, \
	)

/obj/tear_in_reality/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	var/mob/living/carbon/jedi = user
	if(jedi.mob_mood.sanity < 15)
		return //they've already seen it and are about to die, or are just too insane to care
	to_chat(jedi, span_userdanger("OH GOD! NONE OF IT IS REAL! NONE OF IT IS REEEEEEEEEEEEEEEEEEEEEEEEAL!"))
	jedi.mob_mood.sanity = 0
	for(var/lore in typesof(/datum/brain_trauma/severe))
		jedi.gain_trauma(lore)
	addtimer(CALLBACK(src, PROC_REF(deranged), jedi), 10 SECONDS)

/obj/tear_in_reality/proc/deranged(mob/living/carbon/C)
	if(!C || C.stat == DEAD)
		return
	C.vomit(0, TRUE, TRUE, 3, TRUE)
	C.spew_organ(3, 2)
	C.investigate_log("has died from using telekinesis on a tear in reality.", INVESTIGATE_DEATHS)
	C.death()

#undef TEAR_IN_REALITY_CONSUME_RANGE
#undef TEAR_IN_REALITY_SINGULARITY_SIZE

//Provides a decent heal, need to pump every 6 seconds
/obj/item/organ/internal/heart/cursed/wizard
	pump_delay = 60
	heal_brute = 25
	heal_burn = 25
	heal_oxy = 25

//wizard shield charges
#define ADDED_MAX_CHARGE 50
#define MAX_CHARGES_ABSORBED 3

//Increase the amount of damage wizard MODsuit shields can absorb
/obj/item/wizard_armour_charge
	name = "battlemage shield charges"
	desc = "A powerful rune that will increase the number of hits a suit of battlemage armour can take before failing.."
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "flux"

/obj/item/wizard_armour_charge/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/charge_adjuster, type_to_charge_to = /obj/item/spellbook, charges_given = 1, called_proc_name = TYPE_PROC_REF(/obj/item/spellbook, adjust_charge))

/obj/item/wizard_armour_charge/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return

	var/obj/item/mod/module/energy_shield/wizard/shield = istype(interacting_with, /obj/item/mod/module/energy_shield/wizard) || locate(/obj/item/mod/module/energy_shield/wizard) in interacting_with.contents
	if(shield)
		if(isnum(shield))
			shield = interacting_with
		if(shield.max_charges >= (initial(shield.max_charges) + (ADDED_MAX_CHARGE * MAX_CHARGES_ABSORBED)))
			balloon_alert(user, "\The [shield] cannot take more charges, you can put this back into your spellbook to refund it.")
			return ITEM_INTERACT_BLOCKING

		shield.max_charges += ADDED_MAX_CHARGE
		var/datum/component/shielded/shield_comp = shield.mod?.GetComponent(/datum/component/shielded)
		if(shield_comp)
			shield_comp.max_charges += ADDED_MAX_CHARGE
			shield_comp.current_charges += (ADDED_MAX_CHARGE - initial(shield_comp.charge_recovery))
		qdel(src) //should still be able to finish the attack chain
		return ITEM_INTERACT_SUCCESS
	return NONE

//magical chem sprayer
/obj/item/reagent_containers/spray/chemsprayer/magical
	name = "Magical Chem Sprayer"
	desc = "Simply hit the button on the side and this will instantly be filled with a new reagent! Warning: User not immune to effects."
	icon_state = "chemsprayer_janitor"
	inhand_icon_state = "chemsprayer_janitor"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	reagent_flags = NONE
	volume = 1200
	possible_transfer_amounts = list() //we dont want this to change transfer amounts

/obj/item/reagent_containers/spray/chemsprayer/magical/attack_self(mob/user)
	cycle_chems() //does this even need to be a proc
	. = ..()
	balloon_alert(user, "you change the reagent to [english_list(reagents.reagent_list)].")

/obj/item/reagent_containers/spray/chemsprayer/magical/examine()
	. = ..()
	. += "It currently holds [english_list(reagents.reagent_list)]."

/obj/item/reagent_containers/spray/chemsprayer/magical/proc/cycle_chems()
	reagents.clear_reagents()
	var/selected_reagent = get_random_reagent_id_unrestricted()
	while(ispath(selected_reagent, /datum/reagent/consumable) && prob(70)) //makes food reagents clog up the list less
		selected_reagent = get_random_reagent_id_unrestricted()
	list_reagents = list(get_random_reagent_id_unrestricted() = volume)
	reagents.add_reagent_list(list_reagents)

//wizard bio suit
/obj/item/clothing/head/wizard/bio_suit
	name = "gem encrusted bio hood"
	desc = "A hood that protects the head and face from biological contaminants. It's covered in small gemstones."
	icon = 'icons/obj/clothing/head/bio.dmi'
	icon_state = "bio_wizard"
	worn_icon = 'icons/mob/clothing/head/bio.dmi'
	worn_icon_state = "bio_wizard"
	inhand_icon_state = "bio_hood"
	clothing_flags = THICKMATERIAL | BLOCK_GAS_SMOKE_EFFECT | SNUG_FIT | PLASMAMAN_HELMET_EXEMPT | HEADINTERNALS | CASTING_CLOTHES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF

/obj/item/clothing/suit/wizrobe/bio_suit
	name = "gem encrusted bio suit"
	desc = "A suit that protects against biological contamination. It's covered in small gemstones."
	icon = 'icons/obj/clothing/suits/bio.dmi'
	icon_state = "bio_wizard"
	worn_icon = 'icons/mob/clothing/suits/bio.dmi'
	worn_icon_state = "bio_wizard"
	inhand_icon_state = "bio_suit"
	clothing_flags = THICKMATERIAL | CASTING_CLOTHES
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDEJUMPSUIT
	strip_delay = 7 SECONDS
	equip_delay_other = 7 SECONDS

#define REACTION_COOLDOWN_DURATION 10 SECONDS

//reactive talisman
/obj/item/clothing/neck/neckless/wizard_reactive //reactive armor for wizards that casts a spell when it reacts
	name = "reactive talisman"
	desc = "A reactive talisman for the reactive mage."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "memento_mori"
	worn_icon_state = "memento"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | UNACIDABLE
	///ref to whomever the talisman is bound to
	var/mob/living/binding_owner
	///list of spells that can be cast by the talisman
	var/static/list/spell_list = list(/datum/action/cooldown/spell/rod_form, /datum/action/cooldown/spell/aoe/magic_missile,
									  /datum/action/cooldown/spell/emp/disable_tech, /datum/action/cooldown/spell/aoe/repulse/wizard,
								      /datum/action/cooldown/spell/timestop, /datum/action/cooldown/spell/forcewall, /datum/action/cooldown/spell/conjure/the_traps,
								      /datum/action/cooldown/spell/conjure/bee, /datum/action/cooldown/spell/conjure/simian,
								      /datum/action/cooldown/spell/teleport/radius_turf/blink)

	COOLDOWN_DECLARE(armor_cooldown) //unsure if I should use a world.time instead of this

/obj/item/clothing/neck/neckless/wizard_reactive/examine(mob/user)
	. = ..()
	if(binding_owner)
		. += "It is currently bound to [binding_owner.name]."
	else
		. += "It is currently unbound."

/obj/item/clothing/neck/neckless/wizard_reactive/attack_self(mob/user)
	. = ..()
	if(binding_owner)
		if(binding_owner == user)
			to_chat(user, "You start to unbind the talisman from yourself.")
			if(!do_after(user, 10 SECONDS))
				to_chat(user, "You fail to unbind the talisman from yourself.")
				return
			to_chat(user, "You unbind the talisman from yourself!")
			set_owner(null)
			return
		to_chat(user, "This talisman is already bound to someone else!.")
		return

	to_chat(user, "You start to bind the talisman to yourself.")
	if(!do_after(user, 10 SECONDS))
		to_chat(user, "You fail to bind the talisman to yourself.")
		return
	to_chat(user, "You bind the talisman to yourself!")
	set_owner(user)

//do the casting of the spell
/obj/item/clothing/neck/neckless/wizard_reactive/proc/talisman_activation()
	var/datum/action/cooldown/spell/new_spell = pick(spell_list)

	COOLDOWN_START(src, armor_cooldown, REACTION_COOLDOWN_DURATION)
	new_spell = new new_spell(binding_owner.mind || binding_owner)
	new_spell.owner_has_control = FALSE
	new_spell.spell_requirements = NONE
	new_spell.Grant(binding_owner)
	new_spell.cast(binding_owner)
	binding_owner.visible_message("The [src] glows brightly and casts [new_spell.name]!")
	qdel(new_spell)

/obj/item/clothing/neck/neckless/wizard_reactive/proc/set_owner(mob/living/new_owner)
	if(new_owner == binding_owner)
		return

	if(binding_owner)
		UnregisterSignal(binding_owner, list(COMSIG_LIVING_CHECK_BLOCK, COMSIG_QDELETING))

	binding_owner = new_owner
	if(new_owner)
		RegisterSignal(new_owner, COMSIG_QDELETING, PROC_REF(owner_qdel))
		RegisterSignal(new_owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(check_block))

/obj/item/clothing/neck/neckless/wizard_reactive/proc/check_block(mob/living/carbon/human/owner, atom/movable/hitby, damage, attack_text, attack_type, armour_penetration)
	SIGNAL_HANDLER
	if(!prob(50)) //high chanc, so no damage blocking
		return
	if(!COOLDOWN_FINISHED(src, armor_cooldown))
		owner.visible_message("The [src] glows faintly for a second and then fades.")
		return
	INVOKE_ASYNC(src, PROC_REF(talisman_activation))

/obj/item/clothing/neck/neckless/wizard_reactive/proc/owner_qdel()
	SIGNAL_HANDLER
	set_owner(null)

#undef REACTION_COOLDOWN_DURATION

//spellbook charges
//technically not used now, still useful for badminning though
/obj/item/spellbook_charge
	name = "power charge"
	desc = "An artifact that when inserted into a spellbook increases its power."
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "flux"
	var/value = 1

/obj/item/spellbook_charge/ten
	name = "greater power charge"
	desc = "An artifact that when inserted into a spellbook increases its power by a massive amount."
	value = 10

/obj/item/spellbook_charge/debug
	name = "debug power charge"
	desc = "An artifact that when inserted into a spellbook increases its power by 100."
	value = 100

/obj/item/spellbook_charge/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/charge_adjuster, type_to_charge_to = /obj/item/spellbook, charges_given = value, called_proc_name = TYPE_PROC_REF(/obj/item/spellbook, adjust_charge))

#undef ADDED_MAX_CHARGE
#undef MAX_CHARGES_ABSORBED
