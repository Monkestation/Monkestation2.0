GLOBAL_LIST(debug_logfile_names)
GLOBAL_PROTECT(debug_logfile_names)

ADMIN_VERB(getserverlogs_debug, R_DEBUG,  FALSE, "Get Server Logs (Debug)", "View/retrieve debug-related logfiles.", ADMIN_CATEGORY_DEBUG)
	get_debug_logfiles()
	if(!GLOB.debug_logfile_names)
		return
	user.browseserverlogs(whitelist = GLOB.debug_logfile_names, allow_folder = FALSE)


ADMIN_VERB(getcurrentlogs_debug, R_DEBUG, FALSE, "Get Current Logs (Debug)", "View/retrieve debug-related logfiles for the current round.", ADMIN_CATEGORY_DEBUG)
	get_debug_logfiles()
	if(!GLOB.debug_logfile_names)
		return
	user.browseserverlogs(current = TRUE, whitelist = GLOB.debug_logfile_names, allow_folder = FALSE)

/client/proc/browseserverlogs(current = FALSE, list/whitelist = null, allow_folder = TRUE)
	var/path = browse_files(current ? BROWSE_ROOT_CURRENT_LOGS : BROWSE_ROOT_ALL_LOGS, whitelist = whitelist, allow_folder = allow_folder)
	if(!path || !fexists(path))
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	var/choice = tgui_alert(usr, "View (in game), Open (in your system's text editor), or Download?", path, list("View", "Open", "Download"))
	if(!length(choice))
		return

	to_chat(src, span_boldnotice("Attempting to send [path], this may take a fair few minutes if the file is very large."), confidential = TRUE)

	switch(choice)
		if("View")
			if(endswith(path, ".json"))
				json_log_viewer_page(path)
			else
				src << browse(HTML_SKELETON("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>"), list2params(list("window" = "viewfile.[path]")))
		if("Open")
			src << run(file(path))
		if("Download")
			src << ftp(file(path))
		else
			return
	return

/client/proc/json_log_viewer_page(path)
	DIRECT_OUTPUT(mob, browse_rsc(file(path), "log.json"))
	var/datum/browser/browser = new(mob, "log_viewer", null, 1100, 650)
	browser.set_content("<pre>Loading log please wait...</pre>")
	browser.add_head_content({"
	<style>
		* {
			background-color: #222;
		}
	</style>
	<script>
		const LOG_FILE = "log.json";
		document.addEventListener("DOMContentLoaded", (ev) => {
			(async () => {
				const start = Date.now();
				const timeoutMs = 10_000;
				const pollIntervalMs = 250;
				while (Date.now() - start < timeoutMs) {
					try {
						const head = await fetch(LOG_FILE, { method: "HEAD" });
						if (head.ok) {
							const res = await fetch(LOG_FILE);
							const logtext = await res.text();

							const params = new URLSearchParams()
							params.set("log_text", logtext);
							params.set("log_name", '[path]');
							const options = \[
								//"organized",
								"enable_back_button",
								"disable_upload",
							];
							for (const option of options)
								params.set(option, true);
							window.location.href = `https://monkestation.github.io/ss13-log-viewer/#${params.toString()}`;
							return;
						}
					} catch (_) {	}
					await new Promise(r => setTimeout(r, pollIntervalMs));
				}
				console.error("Timed out waiting for log.json");
			})();
		});
	</script>
	"})
	browser.open()
/proc/get_debug_logfiles()
	if(!logger.initialized || GLOB.debug_logfile_names)
		return
	for(var/datum/log_category/category as anything in logger.log_categories)
		category = logger.log_categories[category]
		if(is_category_debug_visible(category))
			LAZYOR(GLOB.debug_logfile_names, get_category_logfile(category))
