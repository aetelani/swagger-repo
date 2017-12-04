'use strict';

var utils = require('../utils/writer.js');
var Default = require('../service/DefaultService');

module.exports.weatherGET = function weatherGET (req, res, next) {
  Default.weatherGET()
    .then(function (response) {
      utils.writeJson(res, response);
    })
    .catch(function (response) {
      utils.writeJson(res, response);
    });
};
