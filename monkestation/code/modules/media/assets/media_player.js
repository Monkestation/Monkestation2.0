window.onerror = function(message, source, line, col, error) {
	window.location.href = `byond://?src=media:href;media_error=1;message=${encodeURIComponent(message)};source=${encodeURIComponent(source)};line=${encodeURIComponent(line)};col=${encodeURIComponent(col)};error=${encodeURIComponent(error)}`;
	return true;
};

const { SpatialAudioPlayer } = wasm_bindgen;

function topic(params) {
	// Build the URL
	let url = "byond://?src=media:href";
	if (params) {
		for (const key in params) {
			if (hasOwn.call(params, key)) {
				let value = params[key];
				if (value === null || value === undefined) {
					value = "";
				} else if (typeof value === "boolean") {
					value = + value;
				}
				url += `;${encodeURIComponent(key)}=${encodeURIComponent(value)}`;
			}
		}
	}
	location.href = url;
}

// biome-ignore lint/style/noVar: <explanation>
var player = null;

async function setup() {
	await wasm_bindgen("media_player.wasm");
	player = new SpatialAudioPlayer();
	window.location.href = "byond://?src=media:href;ready=1";
	topic({"ready": 2});
}

setup();

function set_url(url) {
	player.set_url(url);
}

function set_position(x, y) {
	player.set_position(x, y);
}

function set_time(time) {
	player.set_time(time);
}

function play(url) {
	if (url) {
		player.set_url(url);
	}
	player.play();
}

function pause() {
	player.pause();
}

function stop() {
	player.stop();
}
