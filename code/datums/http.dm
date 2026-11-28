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
	. = "BYOND/[DM_VERSION].[DM_BUILD] ss13-monkestation/[copytext(GLOB.revdata.originmastercommit, 0, 8) || "NOCOMMIT"] "

	if (istext(comment))
		. += " ([comment])"
	else if (islist(comment))
		var/list/comments = comment
		if (length(comments))
			. += " ("
			for (var/i = 1 to length(comments))
				. += "[comments[i]]"
				if (i == length(comments))
					. += ")"
					break
				. += ";"
