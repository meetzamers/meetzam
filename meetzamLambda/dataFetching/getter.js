'use strict';
const http = require('http');
const TMDB_API_key = process.env.TMDB_API_key;
const Gracenote_API_key = process.env.Gracenote_API_key;

// this function get data from tms and return.
module.exports.getDataTMS = (event, context, callback) => {
  var d = new Date();
  var today = d.getFullYear() + '-' + (d.getMonth()+1) + '-' + d.getDate();
  let tms_params = {
    hostname : "data.tmsapi.com",
    path : "/v1.1/movies/showings?startDate=" + today + "&zip=47904&api_key=" + Gracenote_API_key
  };
  // http request
  let request = http.get(tms_params, function(response) {
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
      console.log(JSON.stringify(parsedData));
    });
  });

  request.on('error', function(error) {
    console.error('HTTP error' + error.message);
    //return error
    callback(error, null);
  });
};

// this function get data from tmdb and return
module.exports.getDataTMDB = (event, context, callback) => {
  var date = new Date();
  let tmdb_param = {
    hostname : "api.themoviedb.org",
    path : "/3/search/movie?api_key=" + TMDB_API_key + "&language=en-US&page=1&query=" + event.title + "&year=" + event.year 
  };
  // http request
  let request = http.get(tmdb_param, function(response) {
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
      console.log(JSON.stringify(parsedData));
    });
  });

  request.on('error', function(error) {
    console.error('HTTP error' + error.message);
    callback(error, null);
  });
};
