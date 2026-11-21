GLOBAL_LIST(uplink_purchase_logs_by_key) //assoc key = /datum/uplink_purchase_log

/datum/uplink_purchase_log
	var/owner
	var/list/purchase_log //assoc path-of-item = /datum/uplink_purchase_entry
	var/total_spent = 0

/datum/uplink_purchase_log/New(_owner, datum/component/uplink/_parent)
	owner = _owner
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	if(owner)
		if(GLOB.uplink_purchase_logs_by_key[owner])
			stack_trace("WARNING: DUPLICATE PURCHASE LOGS DETECTED. [_owner] [_parent] [_parent.type]")
			MergeWithAndDel(GLOB.uplink_purchase_logs_by_key[owner])
		GLOB.uplink_purchase_logs_by_key[owner] = src
	purchase_log = list()

/datum/uplink_purchase_log/Destroy()
	purchase_log = null
	if(GLOB.uplink_purchase_logs_by_key[owner] == src)
		GLOB.uplink_purchase_logs_by_key -= owner
	return ..()

/datum/uplink_purchase_log/proc/MergeWithAndDel(datum/uplink_purchase_log/other)
	if(!istype(other))
		return
	. = owner == other.owner
	if(!.)
		return
	for(var/hash in other.purchase_log)
		if(!purchase_log[hash])
			purchase_log[hash] = other.purchase_log[hash]
		else
			var/datum/uplink_purchase_entry/UPE = purchase_log[hash]
			var/datum/uplink_purchase_entry/UPE_O = other.purchase_log[hash]
			UPE.amount_purchased += UPE_O.amount_purchased
			for(var/item_name in UPE_O.contents_list)
				UPE.add_contents(item_name, UPE_O.contents_list[item_name])
	qdel(other)

/datum/uplink_purchase_log/proc/TotalTelecrystalsSpent()
	. = total_spent

/datum/uplink_purchase_log/proc/generate_render(show_key = TRUE)
	. = ""
	for(var/hash in purchase_log)
		var/datum/uplink_purchase_entry/UPE = purchase_log[hash]
		var/purchase_html = "<span class='tooltip_container'>\[[UPE.icon_b64][show_key?"([owner])":""]<span class='tooltip_hover'><b>[UPE.name]</b><br>[UPE.spent_cost ? "[UPE.spent_cost] TC" : "[UPE.base_cost] TC<br>(Surplus)"]<br>[UPE.desc]</span>[(UPE.amount_purchased > 1) ? "x[UPE.amount_purchased]" : ""]\]</span>"
		var/contents_html = UPE.get_contents_render()
		. += contents_html ? "<div class='purchase_row'>[purchase_html][contents_html]</div>" : purchase_html

/// bought_contents is what a kit or crate held, as name = list(amount, icon html, TC cost, description)
/datum/uplink_purchase_log/proc/LogPurchase(atom/A, datum/uplink_item/uplink_item, spent_cost, list/bought_contents)
	var/datum/uplink_purchase_entry/UPE
	var/hash = hash_purchase(uplink_item, spent_cost)
	if(purchase_log[hash])
		UPE = purchase_log[hash]
	else
		UPE = new
		purchase_log[hash] = UPE
		UPE.path = A.type
		UPE.icon_b64 = "[icon2base64html(A)]"
		UPE.desc = uplink_item.desc
		UPE.name = uplink_item.name
		UPE.base_cost = initial(uplink_item.cost)
		UPE.spent_cost = spent_cost

	UPE.amount_purchased++
	for(var/item_name in bought_contents)
		UPE.add_contents(item_name, bought_contents[item_name])
	total_spent += spent_cost

/datum/uplink_purchase_log/proc/hash_purchase(datum/uplink_item/uplink_item, spent_cost)
	return "[uplink_item.type]|[uplink_item.name]|[uplink_item.cost]|[spent_cost]"

/datum/uplink_purchase_entry
	var/amount_purchased = 0
	var/path
	var/icon_b64
	var/desc
	var/base_cost
	var/spent_cost
	var/name
	/// What the kit or crate held, as name = list(amount, icon html, TC cost, description). Added up if it was bought more than once
	var/list/contents_list = list()

/datum/uplink_purchase_entry/proc/add_contents(item_name, list/contents_entry)
	var/list/existing = contents_list[item_name]
	if(existing)
		existing[1] += contents_entry[1]
	else
		contents_list[item_name] = contents_entry.Copy()

/datum/uplink_purchase_entry/proc/get_contents_render()
	if(!length(contents_list))
		return ""
	var/list/shown = list()
	for(var/item_name in contents_list)
		var/list/contents_entry = contents_list[item_name]
		var/amount = contents_entry[1]
		// Falls back to the name if there was no icon to draw
		shown += "<span class='tooltip_container'>[contents_entry[2] || item_name]<span class='tooltip_hover'><b>[item_name]</b>[contents_entry[3] ? "<br>[contents_entry[3]] TC" : ""][contents_entry[4] ? "<br>[contents_entry[4]]" : ""]</span>[(amount > 1) ? "x[amount]" : ""]</span>"
	return "<span class='purchase_contents'>contains: <span class='purchase_items'>[shown.Join("")]</span></span>"
