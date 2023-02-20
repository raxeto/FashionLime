FashionLime.Shared.typeahead = (function() {

  function setValueToHiddenInput(input, suggestion, valueField) {
    if (FashionLime.Common.utils.isUndefinedOrEmpty(suggestion) || FashionLime.Common.utils.isString(suggestion)) {
      $(input).val('');
    } else {
      $(input).val(suggestion[valueField]);
    }
  }

  function onTypeAheadInputChanged(bloodhound, input, displayField, valueInput, valueField, suggestionSetter) {
    var query = $(input).val();
    if (FashionLime.Common.utils.isNullOrEmpty(query)) {
      return;
    }
    bloodhound.search(query, function(datums) {
      if (datums.length === 0) {
        // Because this event handler is binded after the previous one this will always run after setValueToHiddenInput
        return;
      }
      var firstSuggestion = datums[0];
      $(input).typeahead('val', firstSuggestion[displayField]);
      $(valueInput).val(firstSuggestion[valueField]);
      if (!FashionLime.Common.utils.isUndefined(suggestionSetter)) {
        suggestionSetter(firstSuggestion);
      }
    });
  }
  
  var publicData = {
    // selector better to be ID selector, because if the selector is class only
    // then the typeahead plugin creates 2 inputs with this class (tt-input and tt-hint)
    // TODO: adding tt-input to the selector on appropriate places here can fix the issue
    // but till then use ID selectors!
    setup: function(selector, data, displayField, valueField, valueInput, minQueryLength, template, typeaheadClass, selectFirstSuggestionOnChange, suggestionSetter) {
      if (FashionLime.Common.utils.isUndefined(minQueryLength)) {
        minQueryLength = 2;
      }
      if (FashionLime.Common.utils.isUndefined(template)) {
        template = function(context) {
          return '<div>' + context[displayField] +'</div>';
        };
      }
      if (FashionLime.Common.utils.isUndefined(selectFirstSuggestionOnChange)) {
        selectFirstSuggestionOnChange = true;
      }

      var bloodhound;
      if (data instanceof Bloodhound) {
        bloodhound = data;
      } else {
        bloodhound = publicData.createLocalSource(displayField, valueField, data);  
      }

      $(selector).typeahead({
        highlight: true,
        minLength: minQueryLength
      },
      {
        display: displayField,
        limit: 15,
        source: bloodhound,
        templates: {
          empty: '<div class="empty-message">Няма съвпадения.</div>',
          suggestion: template
        }
      });

      if (!FashionLime.Common.utils.isUndefined(typeaheadClass) && !FashionLime.Common.utils.isNull(typeaheadClass)) {
        $(selector).parent('.twitter-typeahead').addClass(typeaheadClass);
      }

      if (!FashionLime.Common.utils.isUndefined(valueField)) {
        publicData.change(selector, function(event, suggestion) {
          setValueToHiddenInput(valueInput, suggestion, valueField);
        });
      }

      if (!FashionLime.Common.utils.isUndefined(suggestionSetter)) {
         publicData.change(selector, function(event, suggestion) {
          suggestionSetter(suggestion);
        });
      }

      if (selectFirstSuggestionOnChange) {
        $(selector).change(onTypeAheadInputChanged.bind(this, bloodhound, selector, displayField, valueInput, valueField, suggestionSetter));
      }
    },

    createLocalSource: function(displayField, valueField, data) {
      return new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace(displayField),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        // in the documentation is said that it is highly recommended to override this option
        // it has to return a string always, there were problems with returning a number
        identify: function(obj) { 
          return obj[valueField].toString(); 
        },
        matchAnyQueryToken: false,
        local: data
      })
    },

    // onTypeAheadChanged - args[0] - event, args[1] - suggestion
    change: function(selector, onTypeAheadChanged) {
      // Occurs when element is selected from the drop down suggestions list, suggestion is object from the binded collection
      $(selector).bind('typeahead:select', onTypeAheadChanged);
      // Occurs when input is changed manually by filling text and lost focus afterwards
      // This is a jQuery event and it differs from typeahead:change. typeahead:change  is 
      // fired when input loses focus and the value has changed since it originally received focus.
      // Which means that if user select suggestion when the focus is lost the typeahead:change will be called
      // and 'change' event will not
      $(selector).change(function(event){
        onTypeAheadChanged(event, $(selector).val());
      });
      // Occurs when 'Tab' is pressed, suggestion is object from the binded collection
      $(selector).bind('typeahead:autocomplete', onTypeAheadChanged);
    }
  };

  return publicData;
}());
