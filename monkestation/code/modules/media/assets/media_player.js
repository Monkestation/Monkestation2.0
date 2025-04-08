// SPDX-License-Identifier: Zlib
const { SpatialAudioPlayer } = wasm_bindgen;

function topic(type, params) {
	// Build the URL
	let url = `byond://?src=media:href;type=${encodeURIComponent(type)}`;
	if (params) {
		url += `;params=${encodeURIComponent(JSON.stringify(params))}`
	}
	location.href = url;
}

// biome-ignore lint/style/noVar: <explanation>
var player = null;

async function setup() {
	await wasm_bindgen("media_player.wasm");
	player = new SpatialAudioPlayer();
	topic("ready");
}

window.onerror = function(message, source, line, col, error) {
	topic("error", {
		"message": message,
		"source": source,
		"line": line,
		"col": col,
		"error": error,
	})
	return true;
};

window.onunhandledrejection = function(error) {
	let msg = 'UnhandledRejection';
	if (error.reason) {
		msg += ': ' + (error.reason.message || error.reason.description || error.reason);
		if (error.reason.stack) {
			error.reason.stack = 'UnhandledRejection: ' + e.reason.stack;
		}
	}
	window.onerror(msg, null, null, null, error.reason);
};

document.onreadystatechange = function() {
	if (document.readyState === 'complete') {
		setup();
	}
};

window.set_url = function(url) {
	player.set_url(url);
}

window.set_position = function (x, y) {
	player.set_position(x, y);
}

window.set_ref_distance = function (distance) {
	player.set_ref_distance(distance);
}

window.set_max_distance = function (distance) {
	player.set_max_distance(distance);
}

window.set_time = function(time) {
	player.set_time(time);
}

window.set_volume = function(volume) {
	player.set_volume(volume);
}

window.play = function(url) {
	if (url) {
		player.set_url(url);
	}
	player.play();
}

window.pause = function() {
	player.pause();
}

window.stop = function() {
	player.stop();
}
