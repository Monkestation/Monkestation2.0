/**
 * Armament entries
 *
 * These are basic entries that are compiled into the global list of armaments.
 * It is strongly suggested that if you wish to make your own armaments station, you
 * create your own entries.
 *
 * Armament stations are capable of having a restricted list of products, which you should fill if you plan on making
 * your own station. This is the products variable. If you plan on using the premade list, you can leave this empty.
 *
 * Create your own file with all of the entries if you do wish to make your own custom armaments vendor.
 *
 * @author Gandalf2k15
 */

SUBSYSTEM_DEF(armaments)
	name = "Armaments"
	flags = SS_NO_FIRE
	dependencies = list(
		/datum/controller/subsystem/atoms,
	)

	var/list/entries

/datum/controller/subsystem/armaments/Initialize()
	var/list/armament_dataset = list()
	for(var/datum/armament_entry/armament_entry as anything in subtypesof(/datum/armament_entry))
		// Set up our categories so we can add items to them
		if(initial(armament_entry.category))
			var/category = initial(armament_entry.category)
			if(!(category in armament_dataset))
				// We instansiate the category list so we can add items to it later
				armament_dataset[category] = list(CATEGORY_ENTRY, CATEGORY_LIMIT)
				armament_dataset[category][CATEGORY_ENTRY] = list()
		// These can be considered abstract types, thus do not need to be added.
		if(isnull(initial(armament_entry.item_type)))
			continue
		var/datum/armament_entry/spawned_armament_entry = new armament_entry()
		// Datums without a name will assume the items name
		spawned_armament_entry.name ||= initial(spawned_armament_entry.item_type.name)
		// ditto for the description
		spawned_armament_entry.description ||= initial(spawned_armament_entry.item_type.desc)
		// Make our icon cache for the UI.
		spawned_armament_entry.setup()
		// Now that we've set up our datum, we can add it to the correct category
		if(spawned_armament_entry.category)
			if(spawned_armament_entry.subcategory)
				// Check to see if we've already made the subcategory.
				if(!(spawned_armament_entry.subcategory in armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY]))
					armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY][spawned_armament_entry.subcategory] = list()
				// Finally, we add the entry into the list.
				armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY][spawned_armament_entry.subcategory] += spawned_armament_entry
			else
				// Unset subcategories default to the NONE category.
				if(!(ARMAMENT_SUBCATEGORY_NONE in armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY]))
					armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY][ARMAMENT_SUBCATEGORY_NONE] = list()
				armament_dataset[spawned_armament_entry.category][CATEGORY_ENTRY][ARMAMENT_SUBCATEGORY_NONE] += spawned_armament_entry
			// Set the category item limit.
			armament_dataset[spawned_armament_entry.category][CATEGORY_LIMIT] = spawned_armament_entry.category_item_limit
		else
			// Because of how the UI system works, categories cannot exist with nothing in them, so we
			// only set the OTHER category if something can go inside it! This seems like a copy paste job, but it needs to be here.
			if(!(ARMAMENT_CATEGORY_STANDARD in armament_dataset))
				armament_dataset[ARMAMENT_CATEGORY_STANDARD] = list(CATEGORY_ENTRY, CATEGORY_LIMIT)
				armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_LIMIT] = ARMAMENT_CATEGORY_STANDARD_LIMIT
			// We don't have home :( add us to the other category.
			if(spawned_armament_entry.subcategory)
				// Check to see if we've already made the subcategory.
				if(!(spawned_armament_entry.subcategory in armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY]))
					armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY][spawned_armament_entry.subcategory] = list()
				// Finally, we add the entry into the list.
				armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY][spawned_armament_entry.subcategory] += spawned_armament_entry
			else
				// Unset subcategories default to the NONE category.
				if(!(ARMAMENT_SUBCATEGORY_NONE in armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY]))
					armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY][ARMAMENT_SUBCATEGORY_NONE] = list()
				armament_dataset[ARMAMENT_CATEGORY_STANDARD][CATEGORY_ENTRY][ARMAMENT_SUBCATEGORY_NONE] += spawned_armament_entry

	entries = armament_dataset
	return SS_INIT_SUCCESS
