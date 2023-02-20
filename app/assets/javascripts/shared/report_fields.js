FashionLime.Shared.reportFields = (function() {
  
  var fieldsHolder = '#reportFieldsExpander';

  function onFieldCheckedChanged() {
    fieldCheckedChanged(this);
  }

  function fieldCheckedChanged(checkbox) {
    var key = checkbox.value;
    var value = $(checkbox).siblings('span').html();
    if (checkbox.checked) {
      $(fieldsHolder).find(".selected-fields-list").append(
        FashionLime.Common.utils.format('<option value={0}>{1}</option>', key, value)
      );
    } else {
      $(fieldsHolder).find(
        FashionLime.Common.utils.format(".selected-fields-list option[value='{0}']", key)
      ).remove();
    }
  }

  function onFieldMoveUp() {
    fieldMove(-1);
  }

  function onFieldMoveDown() {
    fieldMove(1);
  }

  function onCloseFields() {
    $(fieldsHolder).find('.btn-xs-expand-collapse')[0].click();
  }

  function onClearFields() {
    $(fieldsHolder).find("input[type='checkbox']").each(function() {
      if ($(this).prop("checked")) {
        $(this).prop("checked", false);
        fieldCheckedChanged($(this)[0]);
      }
    });
  }

  function onReportGenerated() {
    var selected = [];
    $('#selected_fields_list option').each(function() {
      selected.push($(this).val());
    });

    $('#selected_fields_list').val(selected);
    return true;
  }

  function fieldMove(step) {
    var selectList = $(fieldsHolder + ' .selected-fields-list');
    var options = $(selectList).find("option");
    var selected = selectList.val(); 
    var selectedIndex = $(selectList)[0].selectedIndex;
    var newIndex = selectedIndex + step;
    if (newIndex < 0 || newIndex > options.length - 1) {
      return;
    }

    var selectedOption = options[selectedIndex];
    options.splice(selectedIndex, 1);
    options.splice(newIndex, 0, selectedOption);

    selectList.empty().append(options);
    selectList.val(selected);
  }

  var publicData = {
    setup: function(formID) {
      $(fieldsHolder).find("input[type='checkbox']").change(onFieldCheckedChanged);
      $(fieldsHolder).find(".selected-fields .btn-move-up").click(onFieldMoveUp);
      $(fieldsHolder).find(".selected-fields .btn-move-down").click(onFieldMoveDown);
      $(fieldsHolder).find(".close-fields").click(onCloseFields);
      $(fieldsHolder).find(".clear-fields").click(onClearFields);
      FashionLime.Common.utils.onFormSubmit('#' + formID, onReportGenerated);
    },

    preselectFields: function(preselectedFields) {
      for (var i = 0; i < preselectedFields.length; ++i) {
        var field = preselectedFields[i];
        var checkBox = $(fieldsHolder).find(FashionLime.Common.utils.format("input[type='checkbox'][value='{0}']", field));
        $(checkBox).prop("checked", true);
        fieldCheckedChanged($(checkBox)[0]);
      }
    }
  };

  return publicData;
}());
