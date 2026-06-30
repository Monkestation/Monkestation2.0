#define GENERATE_ROBOT_MODEL(SUFFIX) \
/mob/living/silicon/robot/model/##SUFFIX{ \
	set_model = /datum/robot_model/##SUFFIX; \
} \

/datum/robot_model
	/// The display name that appears when examining cyborgs.
	var/name = "Unknown"
	/// The icon state that [/atom/movable/screen/robot/module] will use.
	var/hud_icon_state = "nomod"
	/// The default skin to use.
	var/datum/robot_skin/default_skin = /datum/robot_skin/standard/default
	/// The list of all skins. Optional.
	var/list/datum/robot_skin/available_skins
	/// The cyborg that is using this robot model.
	var/mob/living/silicon/robot/cyborg_owner = null
	/// The list of modules that can be used by the owner.
	var/list/obj/item/usable_modules = list()
	/// The list of modules that are given.
	var/list/obj/item/basic_modules = list()
	/// The list of modules that are given only if the cyborg is emagged.
	var/list/obj/item/emagged_modules = list()
	/// The list of modules that are given only if the cyborg is part of the clockwork cult.
	var/list/obj/item/clockwork_modules = list()
	/// The list of modules that are given only if the cyborg is upgraded through external means.
	var/list/obj/item/external_modules = list()
	/// The list of energy storages to keep track of.
	var/list/datum/robot_energy_storage/energy_storages = list()
	/// The radio channels that are given.
	var/list/radio_channels = list()
	/// The traits that are given
	var/list/traits = list()
	/// The weakref to the ability that toggles their sight vision, if any.
	var/datum/weakref/sight_vision_ref

/datum/robot_model/New()
	LAZYOR(available_skins, default_skin)

/// Gets all modules that should be accessible to the owner.
/datum/robot_model/proc/get_usable_modules()
	return usable_modules.Copy()

/// Initializes any typepaths in all module lists.
/datum/robot_model/proc/initialize_modules()
	if(!cyborg_owner)
		return

	usable_modules.Cut()
	for(var/possible_typepath in basic_modules)
		if(!ispath(possible_typepath))
			usable_modules += possible_typepath
			continue
		var/obj/item/itemized_module = new possible_typepath(cyborg_owner)
		usable_modules += itemized_module
		basic_modules += itemized_module
		basic_modules -= possible_typepath
	for(var/possible_typepath in emagged_modules)
		if(!ispath(possible_typepath))
			usable_modules += possible_typepath
			continue
		var/obj/item/itemized_module = new possible_typepath(cyborg_owner)
		usable_modules += itemized_module
		emagged_modules += itemized_module
		emagged_modules -= possible_typepath
	for(var/possible_typepath in clockwork_modules)
		if(!ispath(possible_typepath))
			usable_modules += possible_typepath
			continue
		var/obj/item/itemized_module = new possible_typepath(cyborg_owner)
		usable_modules += itemized_module
		clockwork_modules += itemized_module
		clockwork_modules -= possible_typepath
	for(var/possible_typepath  in external_modules)
		if(!ispath(possible_typepath))
			usable_modules += possible_typepath
			continue
		var/obj/item/itemized_module = new possible_typepath(cyborg_owner)
		usable_modules += itemized_module
		external_modules += itemized_module
		external_modules -= possible_typepath

/// Gets an energy storage with a specific type. If it cannot, creates it.
/datum/robot_model/proc/get_or_create_estorage(estorage_type)
	return (locate(estorage_type) in energy_storages) || new estorage_type(src)

/// Recharges renewable energy storages and various modules.
/datum/robot_model/proc/on_cyborg_charge(coeff = 1)
	SHOULD_CALL_PARENT(TRUE)
	if(!cyborg_owner)
		return FALSE
	for(var/datum/robot_energy_storage/energy_storage as anything in energy_storages)
		if(energy_storage.renewable == FALSE)
			continue
		energy_storage.energy = min(energy_storage.max_energy, energy_storage.energy + (coeff * energy_storage.recharge_rate))
	for(var/obj/item/usable_module in get_usable_modules())
		if(istype(usable_module, /obj/item/assembly/flash))
			var/obj/item/assembly/flash/flash = usable_module
			flash.times_used = 0
			flash.burnt_out = FALSE
			flash.update_appearance()
			continue
		if(istype(usable_module, /obj/item/reagent_containers/condiment/enzyme))
			var//obj/item/reagent_containers/condiment/enzyme/enzyme_container = usable_module
			enzyme_container.reagents.add_reagent(/datum/reagent/consumable/enzyme, 2 * coeff)
			continue
		if(istype(usable_module, /obj/item/soap/nanotrasen/cyborg))
			var/obj/item/soap/nanotrasen/cyborg/cyborg_soap = usable_module
			if(cyborg_soap.uses < initial(cyborg_soap.uses))
				soap.uses = min(initial(soap.uses), soap.uses + (ROUND_UP(initial(soap.uses) / 100) * coeff))
			continue
		if(istype(usable_module, /obj/item/hand_labeler/cyborg))
			var/obj/item/hand_labeler/cyborg/labeler = usable_module
			labeler.labels_left = 30
			continue
		if(istype(usable_module, /obj/item/lightreplacer))
			var/obj/item/lightreplacer/light_replacer = usable_module
			light_replacer.Charge(cyborg_owner, max(1, coeff))
			continue
		if(istype(usable_module, /obj/item/melee/baton/security))
			var/obj/item/melee/baton/security/security_baton = usable_module
			security_baton.cell?.charge = baton.cell.maxcharge
			continue
		if(istype(usable_module, /obj/item/gun/energy))
			var/obj/item/gun/energy/energy_gun = usable_module
			if(!energy_gun.chambered)
				energy_gun.recharge_newshot() // Try to reload a new shot.
			continue

	cyborg_owner.toner = cyborg_owner.tonermax
	return TRUE

/// Restocks non-renewable energy storages that the owner may have.
/datum/robot_model/proc/on_cyborg_restock()
	if(!cyborg_owner)
		return
	var/obj/machinery/recharge_station/charger = cyborg_owner.loc
	if(!istype(charger))
		return
	var/datum/component/material_container/mat_container = charger.materials.mat_container
	if(!mat_container || charger.materials.on_hold())
		charger.sendmats = FALSE
		return
	for(var/datum/robot_energy_storage/energy_storage as anything in energy_storages)
		if(energy_storage.renewable == TRUE) // Skipping renewables. Already handled in [/datum/robot_model/proc/on_cyborg_charge].
			continue
		if(energy_storage.max_energy == energy_storage.energy) // Skipping full.
			continue
		var/to_stock = min(energy_storage.max_energy / 8, energy_storage.max_energy - energy_storage.energy, mat_container.get_material_amount(energy_storage.mat_type))
		if(!to_stock) // Silo doesn't have what we want.
			continue
		energy_storage.energy += charger.materials.use_materials(list(GET_MATERIAL_REF(energy_storage.mat_type) = to_stock), action = "resupplied", name = "units")
		charger.balloon_alert(cyborg_owner, "+ [to_stock]u [initial(energy_storage.mat_type.name)]")
		playsound(charger, 'sound/weapons/gun/general/mag_bullet_insert.ogg', 50, vary = FALSE)
		return
	charger.balloon_alert(cyborg_owner, "restock process complete")
	charger.sendmats = FALSE


///Whether the borg loses tool slots with damage.
//var/breakable_modules = TRUE
///Whether swapping to this configuration should lockcharge the borg
//var/locked_transform = TRUE
///Can we be ridden
// var/allow_riding = TRUE // TODO: this should be a cyborg variable instead
