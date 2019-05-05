import LiveSocket from "phoenix_live_view";

// Only connect the LV socket if this page actually contains a LiveView.
if ($("[data-phx-view]").length > 0) {
  console.log("Starting LV.");
  let liveSocket = new LiveSocket("/live");
  liveSocket.connect();
}
