FashionLime.Newsletter.subscribe = (function() {

  function onNewsletterFormSubmitted() {
    var email = $("#newsletter-email").val();
    if (FashionLime.Common.utils.isNullOrEmpty(email)) {
      alert("Въведете имейл.")
      return;
    }

    var params = {
        email: email
    };

    return FashionLime.Common.net.sendPostRequest('/newsletter/subscribe.json', params, 
      function (response) {
        if (!response) {
          return;
        }
        FashionLime.Common.notifications.clear();
        if (response.status) {
          FashionLime.Common.notifications.notify("Абонирахте се успешно. Благодарим Ви!");
          $("#newsletter-email").val('');
        } else {
          FashionLime.Common.notifications.alert(response.error);
        }
        FashionLime.Shared.dynamicFooter.hide();
        FashionLime.Common.utils.scrollPageToTop();
      }
    );
  }

  var publicData = {
    setup: function() {
      FashionLime.Common.utils.onFormSubmit("#newsletter-subscribe", function() {
        onNewsletterFormSubmitted();
        return false;
      });
    }
  };

  return publicData;
}());
