FashionLime.Common.eventManager = (function() {

  var _events = {};

  function getEventData(eventName) {
    if (!_events[eventName]) {
      _events[eventName] = [];
    }
    return _events[eventName];
  }

  var publicData = {
    bind: function(event, cb) {
      console.log('Bind [' + event + ']');
      var callbacks = getEventData(event);
      for (var i = 0; i < callbacks.length; ++i) {
        if (callbacks[i] === cb) {
          console.log('Callback is already added.')
          return;
        }
      }

      callbacks.push(cb);
    },

    fire: function(event) {
      console.log('Firing [' + event + ']');
      var callbacks = getEventData(event);
      for (var i = 0; i < callbacks.length; ++i) {
        callbacks[i]();
      }
    },

    unbind: function(event, cb) {
      console.log('Unbind [' + event + ']');
      var callbacks = getEventData(event);
      for (var i = 0; i < callbacks.length; ++i) {
        if (callbacks[i] === cb) {
          callbacks.splice(i, 1);
          return;
        }
      }

      console.log('No such cb for event [' + event + ']!');
    }
  };

  return publicData;
}());

