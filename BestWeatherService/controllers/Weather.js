'use strict';

var utils = require('../utils/writer.js');
var Weather = require('../service/WeatherService');

module.exports.withLocation = function withLocation (req, res, next) {
  var location = req.swagger.params['location'].value;
  Weather.withLocation(location)
    .then(function (response) {
      utils.writeJson(res, response);
    })
    .catch(function (response) {
      utils.writeJson(res, response);
    });
};
