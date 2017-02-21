'use strict';
const http = require('http');
const TMDB_API_key = process.env.TMDB_API_key;
const Gracenote_API_key = process.env.Gracenote_API_key;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

// find the handler here
module.exports.handler = (event, context, callback) => {
  let param = {
    hostname : "api.themoviedb.org",
    path : "/3/movie/now_playing?api_key=" + TMDB_API_key + "&language=en-US&page=1"
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







  // Use this code if you don't use the http event with the LAMBDA-PROXY integration
  // callback(null, { message: 'Go Serverless v1.0! Your function executed successfully!', event });
};
