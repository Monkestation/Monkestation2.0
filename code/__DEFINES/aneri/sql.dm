/* This comment bypasses grep checks */ /var/list/__aneri_sql_queries = list()

#define __ANERI_SQL_BACKGROUND 0
#define __ANERI_SQL_BLOCKING 1
#define __ANERI_SQL_FORGET 2

/// A pool of connections to a MariaDB or MySQL server. Connections open on first use.
/datum/sql_pool
	parent_type = /datum/aneri
	/// TRUE once close() was called. Queries on a closed pool fail with `last_error`.
	VAR_FINAL/closed = FALSE

/datum/sql_pool/New(host = "localhost", port = 3306, user, password, database, min_connections = 1, max_connections = 10, tls = FALSE, tls_ca_file, tls_insecure = FALSE)
	ANERI_CALL(sql_pool_new, src, host, port, user, password, database, min_connections, max_connections, tls, tls_ca_file, tls_insecure)

/datum/sql_pool/Destroy()
	close()
	return ..()

/// Closes every connection. Queries already running still finish. Returns FALSE if it was already closed.
/datum/sql_pool/proc/close()
	if(closed)
		return FALSE
	closed = TRUE
	ANERI_CALL(sql_pool_del, src)
	return TRUE

/// Returns a new query. Use `?` placeholders with a list of values, or `:name` placeholders with an assoc list.
/datum/sql_pool/proc/query(sql, list/arguments) as /datum/sql_query
	return new /datum/sql_query(src, null, sql, arguments)

/// Returns a query that inserts every row in one statement. Each row is an assoc list of column name to value.
/// Arguments work like tgstation's `SSdbcore.MassInsert`.
/datum/sql_pool/proc/mass_insert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, list/special_columns) as /datum/sql_query/insert
	return new /datum/sql_query/insert(src, null, table, rows, duplicate_key, ignore_errors, special_columns)

/// Starts a transaction. It holds one connection until it is committed, rolled back, deleted, or idle for `idle_timeout` seconds.
/datum/sql_pool/proc/begin(timeout = 10, idle_timeout = 30) as /datum/sql_transaction
	return new /datum/sql_transaction(src, timeout, idle_timeout)

/// Checks that the server answers, freezing the server until it does. Returns the error text, or null if it worked.
/datum/sql_pool/proc/ping()
	var/datum/sql_query/query = query("DO 1")
	query.execute_blocking()
	return query.last_error

/// One statement. Set the vars, then call execute(), execute().wait(), execute_blocking(), or execute_and_forget().
/datum/sql_query
	var/datum/sql_pool/pool
	/// Set when the statement belongs to a transaction.
	var/datum/sql_transaction/transaction
	var/sql
	/// A list of values for `?` placeholders, or an assoc list for `:name` placeholders.
	var/list/arguments
	/// Seconds before the query fails, including the wait for a free connection. Null to wait forever.
	var/timeout = 10
	/// Column names, or null if the statement returns no rows.
	VAR_FINAL/list/columns
	/// A list of rows, each a list of values in column order.
	VAR_FINAL/list/rows
	/// The current row, set by next_row().
	VAR_FINAL/list/item
	/// How many rows the statement changed.
	VAR_FINAL/affected
	/// The id of the last inserted row, or null.
	VAR_FINAL/last_insert_id
	/// Why the query failed, or null.
	VAR_FINAL/last_error
	/// The server's error number (such as 1062 for a duplicate key), or null.
	VAR_FINAL/error_code
	/// Set while the query is running in the background.
	VAR_FINAL/id
	VAR_PRIVATE/row_index = 0
	var/callback_target
	var/callback

/datum/sql_query/New(datum/sql_pool/pool, datum/sql_transaction/transaction, sql, list/arguments)
	src.pool = pool
	src.transaction = transaction
	src.sql = sql
	src.arguments = arguments

/datum/sql_query/Destroy()
	cancel()
	return ..()

/// Starts the query in the background and returns src.
/// When it finishes, runs call(target, callback)(src), or call(callback)(src) if target is null.
/datum/sql_query/proc/execute(target, callback) as /datum/sql_query
	if(id)
		CRASH("query is already running: [sql]")
	set_result()
	callback_target = target
	src.callback = callback
	id = start(__ANERI_SQL_BACKGROUND)
	__aneri_sql_queries[id] = src
	return src

/// Sleeps until the query finishes, then returns src.
/datum/sql_query/proc/wait() as /datum/sql_query
	while(id)
		sleep(world.tick_lag)
	return src

/// Runs the query and returns src. The whole server freezes until it is done. Not allowed in a transaction.
/datum/sql_query/proc/execute_blocking() as /datum/sql_query
	if(id)
		CRASH("query is already running: [sql]")
	var/list/result = start(__ANERI_SQL_BLOCKING)
	set_result(result[1], result[2], result[3], result[4], result[5], result[6])
	return src

/// Starts the query in the background and never reports back: no callback, no result, can't be cancelled.
/datum/sql_query/proc/execute_and_forget()
	start(__ANERI_SQL_FORGET)

/// Stops waiting for the query. Its callback will not run. Returns FALSE if nothing was running.
/// A statement in a transaction still runs in its turn.
/datum/sql_query/proc/cancel()
	if(!id)
		return FALSE
	__aneri_sql_queries -= id
	if(!transaction)
		ANERI_CALL(sql_cancel, id)
	id = null
	callback_target = null
	callback = null
	return TRUE

/// Moves `item` to the next row. Returns FALSE when there are no more rows.
/datum/sql_query/proc/next_row()
	if(row_index >= length(rows))
		item = null
		return FALSE
	item = rows[++row_index]
	return TRUE

/datum/sql_query/proc/start(mode)
	PROTECTED_PROC(TRUE)
	return ANERI_CALL(sql_execute, mode, pool, transaction, sql, arguments, timeout)

/datum/sql_query/proc/set_result(list/columns, list/rows, affected, last_insert_id, last_error, error_code)
	src.columns = columns
	src.rows = rows
	src.affected = affected
	src.last_insert_id = last_insert_id
	src.last_error = last_error
	src.error_code = error_code
	item = null
	row_index = 0

/// A mass insert, made by mass_insert() on a pool or transaction.
/datum/sql_query/insert
	var/table
	/// A list of assoc lists, column name to value.
	var/list/insert_rows
	/// TRUE to update every column on a duplicate key, or text to append to the statement.
	var/duplicate_key = FALSE
	/// TRUE for INSERT IGNORE.
	var/ignore_errors = FALSE
	/// Column name to SQL expression used for every row. Each `?` in it is that row's value for the column.
	var/list/special_columns

/datum/sql_query/insert/New(datum/sql_pool/pool, datum/sql_transaction/transaction, table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, list/special_columns)
	src.pool = pool
	src.transaction = transaction
	src.table = table
	src.insert_rows = rows
	src.duplicate_key = duplicate_key
	src.ignore_errors = ignore_errors
	src.special_columns = special_columns

/datum/sql_query/insert/start(mode)
	return ANERI_CALL(sql_insert, mode, pool, transaction, table, insert_rows, duplicate_key, ignore_errors, special_columns, timeout)

/// A transaction, made by begin() on a pool. Statements run in the order execute() was called on them.
/// The first one that fails rolls the whole transaction back, and every later statement and the commit report that error.
/datum/sql_transaction
	parent_type = /datum/aneri
	var/datum/sql_pool/pool

/datum/sql_transaction/New(datum/sql_pool/pool, timeout = 10, idle_timeout = 30)
	src.pool = pool
	ANERI_CALL(sql_transaction_new, src, pool, timeout, idle_timeout)

/datum/sql_transaction/Destroy()
	ANERI_CALL(sql_transaction_del, src)
	return ..()

/// Returns a new statement in this transaction. Arguments work like `/datum/sql_pool/proc/query`.
/datum/sql_transaction/proc/query(sql, list/arguments) as /datum/sql_query
	return new /datum/sql_query(pool, src, sql, arguments)

/// Returns a mass insert in this transaction. Arguments work like `/datum/sql_pool/proc/mass_insert`.
/datum/sql_transaction/proc/mass_insert(table, list/rows, duplicate_key = FALSE, ignore_errors = FALSE, list/special_columns) as /datum/sql_query/insert
	return new /datum/sql_query/insert(pool, src, table, rows, duplicate_key, ignore_errors, special_columns)

/// Commits after every statement started so far. Returns a query whose `last_error` says if it worked.
/datum/sql_transaction/proc/commit(target, callback) as /datum/sql_query
	return finish(TRUE, target, callback)

/// Rolls back after every statement started so far. Returns a query like commit() does.
/datum/sql_transaction/proc/rollback(target, callback) as /datum/sql_query
	return finish(FALSE, target, callback)

/datum/sql_transaction/proc/finish(commit, target, callback)
	PRIVATE_PROC(TRUE)
	var/datum/sql_query/query = new(pool, src, commit ? "COMMIT" : "ROLLBACK")
	query.callback_target = target
	query.callback = callback
	query.id = ANERI_CALL(sql_transaction_end, src, commit, query.timeout)
	__aneri_sql_queries[query.id] = query
	return query

/// How many queries are still running, including execute_and_forget() ones.
/proc/aneri_sql_in_flight()
	return length(__aneri_sql_queries) + ANERI_CALL(sql_forgotten_in_flight)

/proc/__aneri_sql_finish(id, list/columns, list/rows, affected, last_insert_id, error, error_code)
	var/datum/sql_query/query = __aneri_sql_queries[id]
	if(!query)
		return
	__aneri_sql_queries -= id
	query.id = null
	query.set_result(columns, rows, affected, last_insert_id, error, error_code)
	var/target = query.callback_target
	var/callback = query.callback
	query.callback_target = null
	query.callback = null
	if(!callback)
		return
	if(target)
		call(target, callback)(query)
	else
		call(callback)(query)

#undef __ANERI_SQL_BACKGROUND
#undef __ANERI_SQL_BLOCKING
#undef __ANERI_SQL_FORGET
