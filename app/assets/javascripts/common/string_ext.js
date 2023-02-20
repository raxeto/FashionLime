(function() {
  'use strict';
  
  String.prototype.startsWith = String.prototype.startsWith || function (prefix) {
    return this.indexOf(prefix) === 0;
  };

})();
