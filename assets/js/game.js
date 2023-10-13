import { Presence } from "phoenix";
import { convertSecondsToMinutesSeconds } from "./utils";
import { Typing } from "./typing";
import Players from "./players";

export default class Game {
  constructor(gameId, socket) {
    this.socket = socket;
    this.gameId = gameId;
    this.channel = this.socket.channel("game:" + this.gameId, {});
    this.status = document.getElementById("game-status");
    this.typing = new Typing(this.channel);
  }

  join() {
    if (!this.gameId) return;
    const presence = new Presence(this.channel);
    const players = new Players(presence);

    presence.onSync(() => players.renderOnlineUsers(presence));
    this.socket.connect();
    this.typing.load();
    this.countdown();
    // this.updatePlayerProgress();

    this.startTimer();
    this.channel
      .join()
      .receive("ok", (resp) => {
        console.info("Joined successfully", resp);
      })
      .receive("error", (resp) => {
        console.error("Unable to join", resp);
      });
  }

  // updatePlayerProgress() {
  //   this.channel.on("progress", ({ player_id, progress }) => {
  //     const progressPlayerEl = document.getElementById(
  //       `progress-player-${player_id}`
  //     );
  //     progressPlayerEl.textContent = `${progress}%`;
  //   });
  // }

  countdown() {
    this.channel.on("countdown", ({ countdown }) => {
      this.status.setAttribute("data-status", "lobby");
      this.status.textContent = `Game started in ${countdown} seconds...`;
    });
  }

  startTimer() {
    this.channel.on("game_timer", ({ time_limit }) => {
      this.typing.typingBox.disabled = false;
      this.status.setAttribute("data-status", "playing");
      const countdown = setInterval(() => {
        if (time_limit < 0) {
          this.finishTimer();
          clearInterval(countdown);
        } else {
          this.status.textContent = `Time remaining: ${convertSecondsToMinutesSeconds(
            time_limit
          )}`;
          time_limit--;
        }
      }, 1000);
    });
  }

  finishTimer() {
    this.status.setAttribute("data-status", "played");
    this.status.textContent = "Game has finished.";
  }
}
