'use strict';
const http = require('http');
const TMDB_API_key = process.env.TMDB_API_key;
const Gracenote_API_key = process.env.Gracenote_API_key;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

// find the handler here
module.exports.handler = (event, context, callback) => {

  // request data need to be a variable
  // currently using fixed constant data
  // research javascript doc
  let param = {
    hostname : "data.tmsapi.com",
    path : "/v1.1/movies/showings?startDate=2017-02-21&zip=47904&api_key=" + Gracenote_API_key
  };

  // http request

  let request = http.get(param, function(response) {
    response.setEncoding('utf8');

    // process incomng JSON

    let rawData = '';

    response.on('data', function(chunk) {
        rawData += chunk;
    });


    response.on('end', function() {
      let parsedData = JSON.parse(rawData);
      console.log("Fetched JSON is: " + JSON.stringify(parsedData));
    });

  });

  request.on('error', function(error) {
    console.error('HTTP error' + error.message);
    callback(error);
  });


};
