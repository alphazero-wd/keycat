import { Presence } from "phoenix";
import { convertSecondsToMinutesSeconds } from "./utils";
import Players from "./players";

export default class Game {
  constructor(gameId, socket) {
    this.socket = socket;
    this.gameId = gameId;
    this.channel = this.socket.channel("game:" + this.gameId, {});
    this.status = document.getElementById("game-status");
  }

  join() {
    if (!this.gameId) return;
    const presence = new Presence(this.channel);
    const players = new Players(presence);

    presence.onSync(() => players.renderOnlineUsers(presence));
    this.socket.connect();
    this.countdown();
    this.start();
    this.channel
      .join()
      .receive("ok", (resp) => {
        console.info("Joined successfully", resp);
      })
      .receive("error", (resp) => {
        console.error("Unable to join", resp);
      });
  }

  countdown() {
    this.channel.on("countdown", ({ countdown }) => {
      this.status.setAttribute("data-status", "lobby");
      this.status.textContent = `Game started in ${countdown} seconds...`;
    });
  }

  start() {
    this.channel.on("game_timer", ({ time_limit }) => {
      this.status.setAttribute("data-status", "playing");
      this.status.textContent = `Time limit: ${convertSecondsToMinutesSeconds(
        time_limit
      )}`;
    });
  }
}
