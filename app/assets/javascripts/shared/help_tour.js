FashionLime.Shared.helpTour = (function() {
  'use strict';

  function formatTemplate() {
    var template = 
          ['<div class="help-tour popover" role="tooltip">',
            '<div class="arrow"></div> ',
            '<h3 class="popover-title"></h3> ',
          '<div class="popover-content"></div> ',
            '<div class="popover-navigation"> ',
                '<div class="btn-group"> ',
                  '<button class="btn btn-xs btn-template-main" data-role="prev"><i class="fa fa-arrow-left" aria-hidden="true"></i></button>',
                  '<button class="btn btn-xs btn-template-main" data-role="next"><i class="fa fa-arrow-right" aria-hidden="true"></i></button>',
                  '<button class="btn btn-xs btn-default" data-role="pause-resume" data-pause-text="Пауза" data-resume-text="Старт">Пауза</button>',
                '</div> ',
                '<button class="btn btn-xs btn-default btn-close" data-role="end"><i class="fa fa-times" aria-hidden="true"></i></button>',
            '</div>',
          '</div>'].join('');
    return template;
  }

  function createSteps(steps) {
    if (steps.length === 0) {
      return [{
        element: "#content",
        content: "Все още не са създадени инструкции за страницата, в която се намирате. Можете да се свържете с нашите консултанти, използвайки страницата за контакт.",
        placement: "top"
      }];
    } 
    var ret = [];
    var index = 0;
    for (var i = 0; i < steps.length; ++i) {
      var selector;
      if (FashionLime.Common.utils.isUndefinedOrEmpty(steps[i].class_name)) {
        selector = FashionLime.Common.utils.format(".help-tour-step-{0}", ++index); 
      } else {
        selector = "." + steps[i].class_name;
      }
      var el = $(selector);
      if (el.length > 0 && $(el).is(":visible")) {
        var s = steps[i];
        s.element = selector;
        ret.push(s);  
      }
    }
    return ret;
  }  

  var publicData = {
    setup: function(steps) {
       $('.help-tour-start').click(function(e) {
          e.preventDefault();
          publicData.start(steps);
       });
    },

    start: function(steps) {
      var tour = new Tour({
        storage: false,
        template: formatTemplate(),
        steps: createSteps(steps)
      });

      tour.init();
      tour.start();
    }
  };

  return publicData;
}());






