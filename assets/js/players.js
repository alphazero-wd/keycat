export default class Players {
  constructor(presence) {
    this.presence = presence;
  }

  renderOnlineUsers() {
    let response = "";

    this.presence.list((username) => {
      response += `
        <div id=${username} class="flex justify-between items-center">
          <span class="font-medium text-lg">${username}</span>
          <span id="${username}-progress">0%</span>
        </div>
      `;
    });

    document.getElementById("players").innerHTML = response;
  }
}
