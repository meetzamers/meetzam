'use strict';

// this module calls TMS api movie playing in local theatra, pass zipcode and current date as parameters and fetch general data about movie that currentlly playing in local theaters, including showtime information.
module.exports.handler = httpGetRequestTmsApi;



// required modules
const http = require('http');
// requred constants
const Gracenote_API_key = process.env.Gracenote_API_key;
// implementation
function httpGetRequestTmsApi (event, context, callback) {
  var d = new Date();
  var today = d.getFullYear() + '-' + (d.getMonth()+1) + '-' + d.getDate();
  let tms_params = {
    hostname : "data.tmsapi.com",
    path : "/v1.1/movies/showings?startDate=" + today + "&zip=47904&api_key=" + Gracenote_API_key
  };
  // http request
  let request = http.get(tms_params, (response) => {
    response.setEncoding('utf8');
    // process incomng JSON
    let rawData = '';
    response.on('data', function(chunk) {
        rawData += chunk;
    });
    response.on('end', function() {
      let parsedData = JSON.parse(rawData);
      // return parsedData
      callback(null, parsedData);
    });
  });

  request.on('error', (error) => {
    console.error('HTTP error' + error.message);
    //return error
    callback(error, null);
  });
}