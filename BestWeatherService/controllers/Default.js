'use strict';

var utils = require('../utils/writer.js');
var Default = require('../service/DefaultService');

module.exports.withLocation = function withLocation (req, res, next) {
  var location = req.swagger.params['location'].value;
  Default.withLocation(location)
    .then(function (response) {
      utils.writeJson(res, response);
    })
    .catch(function (response) {
      utils.writeJson(res, response);
    });
};
