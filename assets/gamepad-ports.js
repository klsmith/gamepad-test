//
// Add control for Gamepads to Elm app
//
function addGamepadPorts(elmApp) {

  var getGamepads =
    typeof navigator.getGamepads === 'function' ? function() {
      return navigator.getGamepads();
    } :
    typeof navigator.webkitGetGamepads === 'function' ? function() {
      return navigator.webkitGetGamepads();
    } :
    function() {
      return [];
    }

  // SUB GAMEPAD CONNECT
  function onGamepadConnect(event) {
    var g = getGamepads()[event.gamepad.index];
    elmApp.ports.onGamepadConnect.send(g);
  }
  window.addEventListener("gamepadconnected", onGamepadConnect, false);

  // SUB GAMEPAD DISCONNECT
  function onGamepadDisconnect(event) {
    var g = getGamepads()[event.gamepad.index];
    elmApp.ports.onGamepadDisconnect.send(g);
  }
  window.addEventListener("gamepaddisconnected", onGamepadDisconnect, false);

  // SUB GAMEPAD UPDATES
  var registry = [];
  var timestamps = {};

  function onGamepadUpdate() {
    requestAnimationFrame(onGamepadUpdate);
    var gamepads = getGamepads();
    var updatedGamepads = [];
    for (index in registry) {
      var g = gamepads[index];
      console.log(g);
      if (!g || !g.connected || g.timestamp <= 0 ||
        g.index === null || g.index === undefined) {
        continue;
      }
      var t = timestamps[g.index];
      if (t && t >= g.timestamp) {
        continue;
      }
      timestamps[g.index] = g.timestamp;
      updatedGamepads.push(g);
    }
    if (updatedGamepads && updatedGamepads.length > 0) {
      elmApp.ports.onGamepadUpdate.send(updatedGamepads);
    }
  }
  if (elmApp.ports.onGamepadUpdate) {
    requestAnimationFrame(onGamepadUpdate);
  }
  // CMD REGISTER GAMEPAD LISTENER
  function registerGamepadListener(index) {
    if (!registry.includes(index)) {
      registry.push(index);
    }
  }
  if (elmApp.ports.registerGamepadListener) {
    elmApp.ports.registerGamepadListener.subscribe(registerGamepadListener);
  }

  // CMD UNREGISTER GAMEPAD LISTENER
  function unregisterGamepadListener(index) {
    var i = registry.indexOf(index);
    if (i != -1) {
      registry.splice(i, 1);
    }
  }
  if (elmApp.ports.unregisterGamepadListener) {
    elmApp.ports.unregisterGamepadListener.subscribe(unregisterGamepadListener);
  }
}
