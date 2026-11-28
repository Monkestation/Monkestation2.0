/* This comment bypasses grep checks */ /var/list/__aneri_http_requests = list()

/// An HTTP request. Set the vars, then call send(), send_blocking(), or send().wait().
/datum/http_request
	var/url
	var/method = "GET"
	/// Header name to value. Values must be text.
	var/list/headers
	/// Text to send as the request body.
	var/body
	/// Path of a file to upload as the request body, instead of `body`.
	var/body_file
	/// Path to write the response body to. The response's `body` is null when this is set.
	var/output_file
	/// Seconds before the request fails, or null to wait forever.
	var/timeout = 30
	/// Set while the request is in flight.
	VAR_FINAL/id
	/// The last finished response.
	VAR_FINAL/datum/http_response/response
	var/callback_target
	var/callback

/datum/http_request/New(url, method = "GET", body, list/headers)
	src.url = url
	src.method = method
	src.body = body
	src.headers = headers

/datum/http_request/Destroy()
	cancel()
	return ..()

/// Starts the request in the background and returns src.
/// When it finishes, runs call(target, callback)(response), or call(callback)(response) if target is null.
/datum/http_request/proc/send(target, callback) as /datum/http_request
	if(id)
		CRASH("http request to [url] is already in flight")
	response = null
	callback_target = target
	src.callback = callback
	id = ANERI_CALL(http_send, method, url, headers, body, body_file, output_file, timeout)
	__aneri_http_requests[id] = src
	return src

/// Starts the request in the background and never reports back: no callback, no response, can't be cancelled.
/// Cheaper than send() with no callback, since the result never crosses back into DM.
/datum/http_request/proc/send_and_forget()
	ANERI_CALL(http_send_and_forget, method, url, headers, body, body_file, output_file, timeout)

/// Sleeps until the request finishes, then returns the response.
/datum/http_request/proc/wait() as /datum/http_response
	while(id)
		sleep(world.tick_lag)
	return response

/// Runs the request and returns the response. The whole server freezes until it is done.
/datum/http_request/proc/send_blocking() as /datum/http_response
	if(id)
		CRASH("http request to [url] is already in flight")
	var/list/result = ANERI_CALL(http_send_blocking, method, url, headers, body, body_file, output_file, timeout)
	response = new /datum/http_response(result[1], result[2], result[3], result[4])
	return response

/// Stops the request. Its callback will not run. Returns FALSE if nothing was in flight.
/datum/http_request/proc/cancel()
	if(!id)
		return FALSE
	__aneri_http_requests -= id
	ANERI_CALL(http_cancel, id)
	id = null
	callback_target = null
	callback = null
	return TRUE

/// The result of an HTTP request.
/datum/http_response
	/// TRUE if the server answered with a 2xx status. FALSE for 404, 500, and for requests that got no answer at all.
	var/ok = FALSE
	/// The HTTP status code, or null if the request failed before getting one.
	var/status_code
	/// Lowercase header name to value. Repeated headers are joined with ", ".
	var/list/headers
	/// The response body as text. Text stops at the first zero byte, so use output_file for binary data.
	var/body
	/// Why no answer came back (connection, TLS, timeout, file errors), or null. A 404 or 500 is an answer, so check `ok` for those.
	var/error

/datum/http_response/New(status_code, list/headers, body, error)
	src.ok = !error && status_code >= 200 && status_code < 300
	src.status_code = status_code
	src.headers = headers
	src.body = body
	src.error = error

/proc/__aneri_http_finish(id, status_code, list/headers, body, error)
	var/datum/http_request/request = __aneri_http_requests[id]
	if(!request)
		return
	__aneri_http_requests -= id
	var/datum/http_response/response = new(status_code, headers, body, error)
	var/target = request.callback_target
	var/callback = request.callback
	request.id = null
	request.response = response
	request.callback_target = null
	request.callback = null
	if(!callback)
		return
	if(target)
		call(target, callback)(response)
	else
		call(callback)(response)
