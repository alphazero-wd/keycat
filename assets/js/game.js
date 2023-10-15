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
    this.typing = new Typing(this.channel, this.is_game_finished);
    this.presence = new Presence(this.channel);
  }

  join() {
    if (!this.gameId) return;
    const players = new Players(this.presence);

    this.presence.onSync(() => {
      players.renderPlayers();
      const playerEls = document.querySelectorAll('[id^="player-"]');
      if (
        playerEls.length === 1 &&
        this.status.getAttribute("data-status") === "lobby"
      ) {
        this.status.textContent = "Waiting for opponents...";
      }
    });
    this.socket.connect();
    this.countdown();

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

  countdown() {
    this.channel.on("countdown", ({ countdown }) => {
      this.status.setAttribute("data-status", "lobby");
      this.status.textContent = `Game started in ${countdown} seconds...`;
    });
  }

  startTimer() {
    this.channel.on("game_timer", ({ time_limit }) => {
      this.typing.load();
      let tempTimeLimit = time_limit;
      this.typing.typingBox.disabled = false;
      this.status.setAttribute("data-status", "play");
      const countdown = setInterval(() => {
        if (time_limit < 0) {
          this.finishTimer(tempTimeLimit);
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

  finishTimer(timeLimit) {
    this.status.setAttribute("data-status", "played");
    this.status.textContent = "Game has finished. Showing game history...";
    // if the player has finished typing before
    if (!this.typing.is_game_finished) {
      this.typing.onEnd();
      this.typing.saveResult(timeLimit * 1000);
      this.typing.is_game_finished = true;
    }
    setTimeout(() => {
      window.location.replace(`${window.origin}/game/${this.gameId}/history`);
    }, 3000);
  }
}
