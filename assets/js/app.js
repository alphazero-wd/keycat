"use strict";
import "flowbite/dist/flowbite.phoenix.js";
// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
import "./typing";
import socket from "./user_socket.js";
import Game from "./game";
// Establish Phoenix Socket and LiveView configuration.

const joinGameEl = document.getElementById("join-game");
const game = new Game(joinGameEl.getAttribute("data-id"), socket);
game.join();
