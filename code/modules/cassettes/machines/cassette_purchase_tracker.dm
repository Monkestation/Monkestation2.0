/// Tracks cassette purchases for the "TOP CASSETTES" feature
/// is supposed to support both JSON and SQL achitecture

#define CASSETTE_PURCHASES_JSON_FILE "data/cassette_purchases.json"

/// record a cassette purchase to both database and JSON
/// Only records if this is the first time this buyer has purchased this cassette (for ranking purposes)
/proc/record_cassette_purchase(cassette_id, cassette_name, buyer_ckey)
	if(!cassette_id || !cassette_name)
		return FALSE

	// use SQL database first if enabled
	if(CONFIG_GET(flag/sql_enabled))
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(record_cassette_purchase_db), cassette_id, cassette_name, buyer_ckey)

	// always record to JSON as backup
	return record_cassette_purchase_json(cassette_id, cassette_name, buyer_ckey)

/// records a cassette purchase to the database
/// Only inserts if this buyer hasn't purchased this cassette before
/proc/record_cassette_purchase_db(cassette_id, cassette_name, buyer_ckey)
	if(!SSdbcore.Connect())
		return FALSE

	// the Space Board of Music is much grateful for your patronage.
	// however, you've already bought this shit before and you will NOT mess with our honest ranking system
	var/datum/db_query/query_insert = SSdbcore.NewQuery({"
		INSERT IGNORE INTO [format_table_name("cassette_purchases")]
			(cassette_id, cassette_name, buyer_ckey, server_id)
		VALUES
			(:cassette_id, :cassette_name, :buyer_ckey, :server_id)
	"}, list(
		"cassette_id" = cassette_id,
		"cassette_name" = cassette_name,
		"buyer_ckey" = buyer_ckey,
		"server_id" = CONFIG_GET(string/serversqlname)
	))

	if(!query_insert.Execute())
		qdel(query_insert)
		return FALSE

	var/inserted = query_insert.affected
	qdel(query_insert)
	if(!inserted)
		return FALSE
	SScassettes.top_cassettes_cache.Cut()
	return TRUE

/// gets every purchase in the JSON file, reading the file only the first time
/proc/get_json_purchases()
	if(!isnull(SScassettes.json_purchases))
		return SScassettes.json_purchases
	SScassettes.json_purchases = list()
	if(fexists(CASSETTE_PURCHASES_JSON_FILE))
		try
			var/list/loaded = json_decode(aneri_file_read(CASSETTE_PURCHASES_JSON_FILE))
			if(islist(loaded))
				SScassettes.json_purchases = loaded
		catch
			log_music("Failed to load cassette purchases JSON, creating new file")
	return SScassettes.json_purchases

/// records a cassette purchase to JSON file
/proc/record_cassette_purchase_json(cassette_id, cassette_name, buyer_ckey)
	var/list/purchases = get_json_purchases()

	// check if this buyer has already purchased this cassette
	if(buyer_ckey)
		for(var/list/purchase in purchases)
			if(purchase["cassette_id"] == cassette_id && purchase["buyer_ckey"] == buyer_ckey)
				return FALSE // already purchased, don't record again

	// add new purchase
	purchases += list(list(
		"cassette_id" = cassette_id,
		"cassette_name" = cassette_name,
		"buyer_ckey" = buyer_ckey,
		"timestamp" = world.timeofday,
		"server_id" = CONFIG_GET(string/serversqlname)
	))

	aneri_file_write(CASSETTE_PURCHASES_JSON_FILE, json_encode(purchases))
	return TRUE

/// gets the top cassettes by purchase count
/// returns a list of lists (lol) with format: list("cassette_id", "cassette_name", purchase_count)
/proc/get_top_cassettes(limit = 20, use_db = null)
	if(isnull(use_db))
		use_db = CONFIG_GET(flag/sql_enabled)

	if(use_db)
		return get_top_cassettes_db(limit)
	else
		return get_top_cassettes_json(limit)

/// gets top cassettes from database
/proc/get_top_cassettes_db(limit = 20)
	var/list/results = SScassettes.top_cassettes_cache["[limit]"]
	if(isnull(results))
		if(!SSdbcore.Connect())
			return get_top_cassettes_json(limit) // Fallback to JSON

		var/datum/db_query/query_top = SSdbcore.NewQuery({"
			SELECT cassette_id, cassette_name, COUNT(DISTINCT buyer_ckey) as purchase_count
			FROM [format_table_name("cassette_purchases")]
			WHERE buyer_ckey IS NOT NULL
			GROUP BY cassette_id, cassette_name
			ORDER BY purchase_count DESC
			LIMIT :limit
		"}, list("limit" = limit))

		if(!query_top.Execute())
			qdel(query_top)
			return get_top_cassettes_json(limit) // fallback to JSON if no SQL

		results = list()
		while(query_top.NextRow())
			var/cassette_id = query_top.item[1]
			var/cassette_name = query_top.item[2]
			var/purchase_count = text2num(query_top.item[3])

			results += list(list(
				"cassette_id" = cassette_id,
				"cassette_name" = html_decode(cassette_name),
				"purchase_count" = purchase_count
			))

		qdel(query_top)
		SScassettes.top_cassettes_cache["[limit]"] = results

	var/list/enriched = list()
	for(var/list/row as anything in results)
		var/list/entry = row.Copy()
		enrich_cassette_entry(entry)
		enriched += list(entry)

	return enriched

/// gets top cassettes from JSON file
/proc/get_top_cassettes_json(limit = 20)
	var/list/purchases = get_json_purchases()

	// count unique buyers per cassette_id
	var/list/cassette_counts = list()
	var/list/cassette_names = list()

	for(var/list/purchase in purchases)
		var/cassette_id = purchase["cassette_id"]
		var/cassette_name = purchase["cassette_name"]
		var/buyer_ckey = purchase["buyer_ckey"]
		if(!cassette_id || !cassette_name)
			continue

		if(!cassette_counts[cassette_id])
			cassette_counts[cassette_id] = list()
			cassette_names[cassette_id] = cassette_name
		// only count unique buyers (or count old purchases without buyer_ckey as "unknown")
		if(!buyer_ckey)
			buyer_ckey = "unknown_[purchase["timestamp"]]"
		if(!(buyer_ckey in cassette_counts[cassette_id]))
			cassette_counts[cassette_id] += buyer_ckey

	// convert to sorted list
	var/list/results = list()
	for(var/cassette_id in cassette_counts)
		results += list(list(
			"cassette_id" = cassette_id,
			"cassette_name" = html_decode(cassette_names[cassette_id]),
			"purchase_count" = length(cassette_counts[cassette_id])
		))

	// ranks them by purchase count (descending)
	results = sortTim(results, GLOBAL_PROC_REF(cmp_cassette_purchase_count_dsc))

	// limit results
	if(results.len > limit)
		results.len = limit

	for(var/entry in results)
		enrich_cassette_entry(entry)

	return results

/proc/enrich_cassette_entry(list/entry)
	if(!islist(entry))
		return
	var/cassette_id = entry["cassette_id"]
	var/datum/cassette/cassette = SScassettes.load_cassette(cassette_id)
	if(cassette)
		var/icon_state = cassette.front?.design || "cassette_flip"
		entry["cassette_author"] = cassette.author.name
		entry["cassette_author_ckey"] = cassette.author.ckey
		entry["cassette_desc"] = cassette.desc
		entry["cassette_icon"] = 'icons/obj/cassettes/walkman.dmi'
		entry["cassette_icon_state"] = icon_state
		entry["cassette_ref"] = REF(cassette)
	else
		// once a cassette is removed by an admin, mark it as removed by the Space Board of Music
		entry["cassette_removed"] = TRUE

/// sorting proc for cassette purchases (descending by purchase_count) (methinks)
/proc/cmp_cassette_purchase_count_dsc(list/a, list/b)
	return b["purchase_count"] - a["purchase_count"]

#undef CASSETTE_PURCHASES_JSON_FILE
