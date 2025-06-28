/datum/ip_info
	var/is_loaded = FALSE
	var/is_whitelisted = FALSE

	var/ip
	var/ip_as
	var/ip_mobile
	var/ip_proxy
	var/ip_hosting

/client
	var/datum/ip_info/ip_info = new

ADMIN_VERB(Overwatch_ASN_panel, R_SERVER, FALSE, "Overwatch ASN Panel", "Opens the Overwatch ASN Panel.", ADMIN_CATEGORY_SERVER)
	if(!SSdbcore.Connect())
		to_chat(user, span_warning("Failed to establish database connection"))
		return

	new /datum/overwatch_asn_panel(user)

ADMIN_VERB(Overwatch_WhitelistPanel, R_BAN, FALSE, "Overwatch WL Panel", "Opens the Overwatch Whitelist Panel.", ADMIN_CATEGORY_MAIN)
	if(!SSdbcore.Connect())
		to_chat(user, span_warning("Failed to establish database connection"))
		return

	new /datum/overwatch_wl_panel(user)
