FashionLime.Validation.requiredField = (function() {
  'use strict';

  // Private methods.

  function onBootstrapFormInputBlur() {
    onInputBlur(this, $(this).closest('.form-group'));
  }

  function onCustomInputBlur() {
    onInputBlur(this, $(this).parent());
  }

  function onInputBlur(input, errContainer) {
    if (FashionLime.Common.utils.isNullOrEmpty($(input).val())) {
      $(errContainer).addClass('has-error');
    } else {
      $(errContainer).removeClass('has-error');
    }
  }

  // Public methods.

  var publicData = {
    setup: function() {
      // Used for bootstrap form gem which generates required class on labels base on presence validator in the model.
      $('.form-group  label.required').each(function() {
         $(this).siblings('.form-control').blur(onBootstrapFormInputBlur);
      });

      // Used for custom inputs which don't use form for example (see cart/show.html.erb).
      $('.form-control.required-field').each(function() {
         $(this).blur(onCustomInputBlur);
      });
    },

    setupControl: function(selector) {
      $(selector).blur(onCustomInputBlur);
    },

    cleanupControl: function(selector) {
      $(selector).off('blur', onCustomInputBlur);
    }
  };

  return publicData;
}());
