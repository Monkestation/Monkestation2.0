GLOBAL_LIST_EMPTY(cached_cobalt_urls)

/proc/get_cobalt_stream_url(url)
	if(!url)
		return
	if(url in GLOB.cached_cobalt_urls)
		return GLOB.cached_cobalt_urls[url]
	var/api_url = CONFIG_GET(string/cobalt_api_url)
	if(!api_url)
		return
	var/list/headers = list(
		"Accept" = "application/json",
		"Content-Type" = "application/json",
	)
	var/api_key = CONFIG_GET(string/cobalt_api_key)
	if(api_key)
		headers["Authorization"] = "Api-Key [api_key]"
	var/list/body = list(
		"url" = url,
		"downloadMode" = "audio",
		"youtubeDubLang" = "en",
		"audioFormat" = "mp3",
	)
	var/datum/http_request/request = new(RUSTG_HTTP_METHOD_POST, api_url, json_encode(body), headers)
	request.begin_async()
	UNTIL_OR_TIMEOUT(request.is_complete(), 10 SECONDS)
	var/datum/http_response/response = request.into_response()
	if(response.errored)
		CRASH("cobalt errored. code: [response.status_code], error: [response.error]")
	else if(!rustg_json_is_valid(response.body))
		CRASH("cobalt responded with invalid json: [response.body]")
	var/list/info = json_decode(response.body)
	switch(info["status"])
		if("error")
			CRASH("cobalt returned error status. code: [response.status_code], error: [info["error"]["code"]]")
		if("tunnel", "redirect")
			return GLOB.cached_cobalt_urls[url] = info["url"]
		if("picker")
			return GLOB.cached_cobalt_urls[url] = info["audio"]
		else
			CRASH("cobalt returned invalid status: [info["status"]]")

