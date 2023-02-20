FashionLime.Common.notifications = (function() {
  'use strict';

  var holderId = 'flash-notifications';

  function alertField() {
    return $('#flash-notifications div.flash-alert');
  }

  function noticeField() {
    return $('#flash-notifications div.flash-notice');
  }

  var publicData = {
    clear: function() {
      $('#flash-notifications').empty();
    },

    alert: function(v) {
      publicData.showFlash('alert', v);
    },

    notify: function(text) {
      publicData.showFlash('notice', text);
    },

    showFlash: function(type, v) {
      var el = $(publicData.renderFlash(type, v));
      $('#flash-notifications').append(el);
    },

    renderFlash: function(type, v) {
      var text = '';
      if (FashionLime.Common.utils.isString(v)) {
        text = v;
      } else if (FashionLime.Common.utils.isArray(v)) {
        for (var i = 0; i < v.length; ++i) {
          text += v[i] + '</br>';
        }
      } else if (FashionLime.Common.utils.isObject(v)) {
        if (v.error) {
          return publicData.renderFlash(type, v.error);
        } else if (v.errors) {
          return publicData.renderFlash(type, v.errors);
        }
      }
      if (text) {
        var alertType = '';
        var alertClass = '';
        if (type === 'notice') {
          alertType = 'success';
          alertClass = 'flash-notice';
        } else if (type === 'alert') {
          alertType = 'danger';
          alertClass = 'flash-alert';
        } else if (type === 'warning') {
          alertType = 'warning';
          alertClass = 'flash-warning'
        }
        if (alertType !== '') {
          return FashionLime.Common.utils.format("<div class='{0} alert alert-{1} fade in'><a href='#' class='close' data-dismiss='alert' aria-label='close'>&times;</a>{2}</div>",
                  alertClass, alertType, text);
        }
      }
    },

    renderAlert: function(v) {
      return publicData.renderFlash('alert', v);
    },

    renderNotice: function(v) {
      return publicData.renderFlash('notice', v);
    },

    renderWarning: function(v) {
      return publicData.renderFlash('warning', v);
    },

    clearAlerts: function() {
      alertField().remove();
    },

    clearNotices: function() {
      noticeField().remove();
    }
  };

  return publicData;
}());






