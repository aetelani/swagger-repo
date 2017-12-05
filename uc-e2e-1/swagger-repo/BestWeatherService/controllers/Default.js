'use strict';

var utils = require('../utils/writer.js');
var Default = require('../service/DefaultService');

module.exports.tre = function tre (req, res, next) {
  var location = req.swagger.params['location'].value;
  Default.tre(location)
    .then(function (response) {
      utils.writeJson(res, response);
    })
    .catch(function (response) {
      utils.writeJson(res, response);
    });
};
