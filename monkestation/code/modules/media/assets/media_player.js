// SPDX-License-Identifier: Zlib
const { SpatialAudioPlayer } = wasm_bindgen;

function topic(type, params) {
	let url = `byond://?src=media:href;type=${encodeURIComponent(type)}`;
	if (params) {
		url += `;params=${encodeURIComponent(JSON.stringify(params))}`
	}
	location.href = url;
}

var player = null;

async function setup() {
	await wasm_bindgen("media_player.wasm");
	player = new SpatialAudioPlayer();
	topic("ready");
}

window.onerror = (message, source, line, col, error) => {
	topic("error", {
		"message": message,
		"source": source,
		"line": line,
		"col": col,
		"error": error,
	})
	return true;
};

window.onunhandledrejection = (error) => {
	let msg = 'UnhandledRejection';
	if (error.reason) {
		msg += `: ${error.reason.message || error.reason.description || error.reason}`;
		if (error.reason.stack) {
			error.reason.stack = `UnhandledRejection: ${error.reason.stack}`;
		}
	}
	window.onerror(msg, null, null, null, error.reason);
};

document.onreadystatechange = () => {
	if (document.readyState === 'complete') {
		setup();
	}
};

window.set_url = (url) => {
	player.set_url(url);
}

window.set_position = (x, y) => {
	player.set_position(x, y);
}

window.set_ref_distance = (distance) => {
	player.set_ref_distance(distance);
}

window.set_max_distance = (distance) => {
	player.set_max_distance(distance);
}

window.set_time = (time) => {
	player.set_time(time);
}

window.set_volume = (volume) => {
	player.set_volume(volume);
}

window.play = (url, volume) => {
	if (url) {
		player.set_url(url);
	}
	if (volume) {
		player.set_volume(volume);
	}
	//player.play();
}

window.pause = () => {
	player.pause();
}

window.stop = () => {
	player.stop();
}
