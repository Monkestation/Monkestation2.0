const { SpatialAudioPlayer } = wasm_bindgen;

function topic(params) {
	// Build the URL
	let url = "byond://?src=media:href";
	if (params) {
		for (const key in params) {
			if (Object.hasOwn(params, key)) {
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
	topic({"ready": 1, "meow": 1});
}

window.onerror = function(message, source, line, col, error) {
	window.location.href = `byond://?src=media:href;media_error=1;message=${encodeURIComponent(message)};source=${encodeURIComponent(source)};line=${encodeURIComponent(line)};col=${encodeURIComponent(col)};error=${encodeURIComponent(error)}`;
	return true;
};

document.onreadystatechange = function () {
	if (document.readyState !== 'complete') return;
	setup();
};

window.set_url = (url) => {
	console.log("js set_url 1");
	player.set_url(url);
	console.log("js set_url 2");
}

window.set_position = (x, y) => {
	player.set_position(x, y);
}

window.set_time = (time) => {
	player.set_time(time);
}

window.play = (url) => {
	if (url) {
		player.set_url(url);
	}
	player.play();
}

window.pause = () => {
	player.pause();
}

window.stop = () => {
	player.stop();
}
