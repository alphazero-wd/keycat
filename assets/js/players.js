export default class Players {
  constructor(presence) {
    this.presence = presence;
  }

  renderOnlineUsers() {
    let response = "";

    this.presence.list((id, { metas: [first] }) => {
      response += `
        <div id="player-${id}" class="flex justify-between items-center">
          <span class="font-medium text-lg">${first.username}</span>
          <span id="progress-player-${id}">${first.progress}%</span>
        </div>
      `;
    });

    document.getElementById("players").innerHTML = response;
  }
}
