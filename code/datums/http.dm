/datum/http_request
	var/id
	var/in_progress = FALSE

	var/method
	var/body
	var/headers
	var/url
	/// If present response body will be saved to this file.
	var/output_file

	var/_raw_response

/datum/http_request/New(...)
	. = ..()
	if(length(args))
		src.prepare(arglist(args))

/datum/http_request/proc/prepare(method, url, body = "", list/headers, output_file)
	if (!length(headers))
		headers = json_encode(list("User-Agent" = get_useragent()))
	else
		if (!headers["User-Agent"])
			headers["User-Agent"] = get_useragent()
		headers = json_encode(headers)

	src.method = method
	src.url = url
	src.body = body
	src.headers = headers
	src.output_file = output_file

/datum/http_request/proc/fire_and_forget()
	var/result = rustg_http_request_fire_and_forget(method, url, body, headers, build_options())
	if(result != "ok")
		CRASH("[result]")

/datum/http_request/proc/execute_blocking()
	_raw_response = rustg_http_request_blocking(method, url, body, headers, build_options())

/datum/http_request/proc/begin_async()
	if (in_progress)
		CRASH("Attempted to re-use a request object.")

	id = rustg_http_request_async(method, url, body, headers, build_options())

	if (isnull(text2num(id)))
		stack_trace("Proc error: [id]")
		_raw_response = "Proc error: [id]"
	else
		in_progress = TRUE

/datum/http_request/proc/build_options()
	if(output_file)
		return json_encode(list("output_filename"=output_file,"body_filename"=null))
	return null

/datum/http_request/proc/is_complete()
	if (isnull(id))
		return TRUE

	if (!in_progress)
		return TRUE

	var/r = rustg_http_check_request(id)

	if (r == RUSTG_JOB_NO_RESULTS_YET)
		return FALSE
	else
		_raw_response = r
		in_progress = FALSE
		return TRUE

/datum/http_request/proc/into_response()
	var/datum/http_response/R = new()

	try
		var/list/L = json_decode(_raw_response)
		R.status_code = L["status_code"]
		R.headers = L["headers"]
		R.body = L["body"]
	catch
		R.errored = TRUE
		R.error = _raw_response

	return R

/datum/http_response
	var/status_code
	var/body
	var/list/headers

	var/errored = FALSE
	var/error

/**
 * Returns a user-agent for http(s) requests
 * * comment - {str || list} String or list, comments to be applied to the user-agent
 *
 * ```
 * // returns `BYOND 516.1666 ss13-monkestation/deadbeef (Comment-One; Comment-Two)`
 * get_useragent(list("Comment-One", "Comment-Two"))
 * // returns `BYOND 516.1666 ss13-monkestation/deadbeef (My-comment)`
 * get_useragent("My-comment")
 * ```
 */
/proc/get_useragent(comment)
	. = "BYOND/[DM_VERSION].[DM_BUILD] ss13-monkestation/[copytext(GLOB.revdata.commit, 0, 8) || "NOCOMMIT"] "

	if (istext(comment))
		. += " ([comment])"
	else if (islist(comment))
		var/list/comments = comment
		if (length(comments))
			. += " ("
			for (var/i = 1; i <= length(comments); i++)
				. += "[comments[i]]"
				if (i == length(comments))
					. += ")"
					break
				. += ";"
