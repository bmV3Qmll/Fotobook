import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    const toastLiveExample = document.getElementById('liveToast');
    const toastBody = document.getElementsByClassName('toast-body')[0];
    toastBody.textContent = `${data["user_name"]} likes your "${data["post_title"]}" post`
    bootstrap.Toast.getOrCreateInstance(toastLiveExample).show();
  }
});
