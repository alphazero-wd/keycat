import { Presence } from "phoenix";
import Players from "./players";

export default class Game {
  constructor(gameId, socket) {
    this.socket = socket;
    this.gameId = gameId;
  }

  join() {
    if (!this.gameId) return;
    const channel = this.socket.channel("game:" + this.gameId, {});
    const presence = new Presence(channel);
    const players = new Players(presence);

    presence.onSync(() => players.renderOnlineUsers(presence));
    this.socket.connect();
    channel
      .join()
      .receive("ok", (resp) => {
        console.info("Joined successfully", resp);
      })
      .receive("error", (resp) => {
        console.error("Unable to join", resp);
      });
  }
}
