/datum/component/darkspawn_class
	dupe_type = /datum/component/darkspawn_class //prevents multiclassing
	///Class name
	var/name = "Debug class"
	///Class short description
	var/description = "This is a debug class, you shouldn't see this short description."
	///Class long description. This will be shown in TGUI to explain to players with more depth of what to expect from the class
	var/long_description = "This is a debug class, you shouldn't see this long and in-depth description that i'll probably write at some point."
	///The flag of the classtype. Used to determine which psi_web options are available to the class
	var/specialization_flag = NONE
	///The darkspawn who this class belongs to
	var/datum/mind/owner
	var/choosable = TRUE

	var/datum/antagonist/darkspawn/d
	///Abilities our class will start with. Granted to the owning darkspawn on initialization
	var/list/datum/psi_web/starting_abilities = list()
	///Abilities our class can purchase currently
	var/list/datum/psi_web/purchasable_abilities = list()
	///Abilities the darkspawn has learned from the psi_web
	var/list/datum/psi_web/learned_abilities = list()
	///The color of their aura outline
	var/class_color = COLOR_SILVER

	var/icon_file = 'icons/mob/simple/darkspawn.dmi'
	var/eye_icon = "eyes"
	var/class_icon = "classless"

/datum/component/darkspawn_class/Initialize()
	if(!istype(parent, /datum/mind))
		return COMPONENT_INCOMPATIBLE
	owner = parent
	if(!owner.has_antag_datum(/datum/antagonist/darkspawn))
		return COMPONENT_INCOMPATIBLE

/datum/component/darkspawn_class/Destroy()
	. = ..()
	owner = null

/datum/component/darkspawn_class/RegisterWithParent()
	RegisterSignal(parent, COMSIG_DARKSPAWN_PURCHASE_POWER, PROC_REF(gain_power))
	RegisterSignal(parent, COMSIG_MIND_TRANSFERRED, PROC_REF(update_overlays_target))
	if(istype(parent, /datum/mind))
		var/datum/mind/thinker = parent
		if(thinker.current && isliving(thinker.current))
			var/mob/living/thinkmob = thinker.current
			RegisterSignal(thinkmob, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
			thinkmob.update_appearance(UPDATE_OVERLAYS)

	for(var/datum/psi_web/power as anything in starting_abilities)
		gain_power(power_typepath = power)

/datum/component/darkspawn_class/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_DARKSPAWN_PURCHASE_POWER)
	UnregisterSignal(parent, COMSIG_MIND_TRANSFERRED)
	if(istype(parent, /datum/mind))
		var/datum/mind/thinker = parent
		if(thinker.current && isliving(thinker.current))
			var/mob/living/thinkmob = thinker.current
			UnregisterSignal(thinkmob, COMSIG_ATOM_UPDATE_OVERLAYS)
			thinkmob.update_appearance(UPDATE_OVERLAYS)

	for(var/datum/psi_web/power in learned_abilities)
		lose_power(power, TRUE) //if the component is removed, refund them

//////////////////////////////////////////////////////////////////////////
//---------------------------Overlay handlers---------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/component/darkspawn_class/proc/update_overlays_target(datum/mind/source, mob/old_current)
	SIGNAL_HANDLER

	UnregisterSignal(old_current, COMSIG_ATOM_UPDATE_OVERLAYS)
	old_current.update_appearance(UPDATE_OVERLAYS)

	if(source.current)
		RegisterSignal(source.current, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
		source.current.update_appearance(UPDATE_OVERLAYS)


/datum/component/darkspawn_class/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(!isshadowperson(source))
		return //so they only get the overlay when divulged

	var/mob/living/carbon/human/human_source = source

	//draw both the overlay itself and the emissive overlay
	var/mutable_appearance/eyes = mutable_appearance(icon_file, eye_icon, -HANDCUFF_LAYER)
	eyes.color = class_color
	human_source.apply_height_filters(eyes)
	overlays += eyes

	var/mutable_appearance/eyes_e = emissive_appearance(icon_file, eye_icon, source) //the emissive overlay for the eyes
	human_source.apply_height_filters(eyes_e)
	overlays += eyes_e

	var/mutable_appearance/class_sigil = mutable_appearance(icon_file, class_icon, -HANDCUFF_LAYER)
	class_sigil.color = class_color
	human_source.apply_height_filters(class_sigil)
	overlays += class_sigil

	var/mutable_appearance/class_sigil_e = emissive_appearance(icon_file, class_icon, source) //the emissive overlay for the sigil
	human_source.apply_height_filters(class_sigil_e)
	overlays += class_sigil_e

//////////////////////////////////////////////////////////////////////////
//---------------------------Abilities procs----------------------------//
//////////////////////////////////////////////////////////////////////////
///Populates the list of purchaseable abilities
/datum/component/darkspawn_class/proc/populate_ability_list()
	purchasable_abilities.RemoveAll()
	for(var/datum/psi_web/ability as anything in subtypesof(/datum/psi_web))
		if(!(initial(ability.willpower_cost))) //if it's free for some reason, don't show it, it's probably a bug
			continue
		if(!(initial(ability.shadow_flags) & specialization_flag) || (!initial(ability.purchases_left)))
			continue
		var/located_ability = (locate(ability) in learned_abilities)
		if(located_ability)
			continue
		purchasable_abilities += new ability

///Prunes and returns a list of abilities that should be purchaseable
/datum/component/darkspawn_class/proc/get_purchasable_abilities()
	for(var/datum/psi_web/ability in purchasable_abilities)
		if(!(initial(ability.willpower_cost))) //if it's free for some reason, don't show it, it's probably a bug
			purchasable_abilities.Remove(ability)
			continue
		if(!(initial(ability.shadow_flags) & specialization_flag))//if you somehow have an ability for the wrong class remove it
			purchasable_abilities.Remove(ability)
			continue
		if(ability.purchases_left < 1)// if you have bought them all up
			purchasable_abilities.Remove(ability)
			continue

	return purchasable_abilities

/datum/component/darkspawn_class/proc/gain_power(atom/source, datum/psi_web/power_typepath, willpower, silent = FALSE)
	var/datum/psi_web/new_ability
	if(!ispath(power_typepath))
		CRASH("[owner] tried to gain [power_typepath] which is not a valid darkspawn ability")
	if(!(initial(power_typepath.shadow_flags) & specialization_flag))
		CRASH("[owner] tried to gain [power_typepath] which is not allowed by their specialization")

	if(locate(power_typepath) in starting_abilities)
		new_ability = new power_typepath()
		if(new_ability.on_purchase(owner, silent))
			learned_abilities += new_ability
			return
		else
			qdel(new_ability)
			return
	for(var/datum/psi_web/ability in purchasable_abilities)
		if(ability.type == power_typepath.type)
			if(willpower < ability.willpower_cost)
				return
			if(ability.purchases_left <= 0)
				purchasable_abilities.Remove(ability)
				return

			new_ability = new power_typepath()
			if(new_ability.on_purchase(owner, silent))
				learned_abilities += new_ability
				ability.purchases_left--
				if(ability.purchases_left <= 0)
					purchasable_abilities.Remove(ability)
				return
			else
				qdel(new_ability)
				return

/datum/component/darkspawn_class/proc/lose_power(datum/psi_web/power, refund = FALSE)
	if(!locate(power) in learned_abilities)
		CRASH("[owner] tried to lose [power] which they haven't learned")

	if(!initial(power.purchases_left))
		power.purchases_left++
	purchasable_abilities += new power
	learned_abilities -= power
	power.remove(refund)

/datum/component/darkspawn_class/proc/refresh_powers()
	for(var/datum/psi_web/power in learned_abilities)
		var/power_type = power.type
		lose_power(power, TRUE) //full refund
		gain_power(power_typepath = power_type, silent = TRUE) //then just rebuy it

////////////////////////////////////////////////////////////////////////////////////
//--------------------------The Classes in Question-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/component/darkspawn_class/classless
	name = "Deprived"
	description = "You've yet to peep the horror."
	long_description = "You can probably do this with just a club and loincloth anyway."
	specialization_flag = NONE
	class_color = COLOR_SILVER
	starting_abilities = list(/datum/psi_web/innate_darkspawn)
	choosable = FALSE

/datum/component/darkspawn_class/fighter
	name = "Fighter"
	description = "An unstoppable wall of darkness."
	long_description = "Act as a physical threat to crewmembers. Simple and messy."
	specialization_flag = DARKSPAWN_FIGHTER
	class_color = COLOR_RED
	starting_abilities = list(/datum/psi_web/innate_darkspawn, /datum/psi_web/fighter)
	class_icon = "fighter_sigils"

/datum/component/darkspawn_class/scout
	name = "Scout"
	description = "Stir the shadows in unnatural ways."
	long_description = "Deter crewmembers from venturing into the darkness by being everywhere at once. Good at running away."
	specialization_flag = DARKSPAWN_SCOUT
	class_color = COLOR_YELLOW
	starting_abilities = list(/datum/psi_web/innate_darkspawn, /datum/psi_web/scout)
	class_icon = "scout_sigils"

/datum/component/darkspawn_class/warlock
	name = "Warlock"
	description = "Psionic dominance."
	long_description = "Cast spells, thrall minds, and support allies from across the station. Rather complex."
	specialization_flag = DARKSPAWN_WARLOCK
	class_color = COLOR_STRONG_VIOLET
	starting_abilities = list(/datum/psi_web/innate_darkspawn, /datum/psi_web/warlock)
	class_icon = "warlock_sigils"

/datum/component/darkspawn_class/admin
	name = "Admeme"
	description = "Can do everything."
	long_description = "Yeah, you're fucked buddy."
	specialization_flag = ALL_DARKSPAWN_CLASSES
	class_color = LIGHT_COLOR_ELECTRIC_GREEN
	choosable = FALSE
	starting_abilities = list(/datum/psi_web/innate_darkspawn, /datum/psi_web/fighter, /datum/psi_web/scout, /datum/psi_web/warlock)
	eye_icon = "admeme_eyes"
	class_icon = "admeme_sigils"
	var/last_colour = 0

/datum/component/darkspawn_class/admin/update_owner_overlay(atom/source, list/overlays)
	var/list/rgb_colors = RotateHue(rgb(255, 0, 0), (world.time - last_colour) * 15)
	last_colour = world.time
	class_color = rgb_colors //rainbow
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/atom, update_appearance), UPDATE_OVERLAYS), 1 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE) //regularly refresh the overlays
	return ..()
