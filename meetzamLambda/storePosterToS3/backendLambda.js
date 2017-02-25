'use strict';
const fs = require('fs');
const request = require('request');
const AWS = require('aws-sdk');
//const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const s3 = new AWS.S3();

module.exports.handler = (event, context, callback) => {
  let options = {
    uri: "https://image.tmdb.org/t/p/w500/" + event.poster_url,
    //encoding: "binary"
    encoding: null
  };
  request(options,(error, response, body) => {
    if (error || response.statusCode != 200) {
      console.error('failed to get image');
    }
    else {
      //body = new Buffer(body, 'binary');
      s3.putObject({
        Body: body,
        Key: "posters" + event.poster_url,
        Bucket:"meetzam-contentdelivery-mobilehub-1569925313"
      }, function(error, data) {
          if (error) {
            console.error("error uploading image to s3");
          }
          else {
            console.log("success uploading to s3");
          }
      });
    }
  });

};
