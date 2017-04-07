'use strict';

// add deviceARN into userProfile table, this function takes argument event.userId as key, then add event.arn into table.
module.exports.handler = getUserByIdAndAddDeviceARN;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function getUserByIdAndAddDeviceARN (event, context, callback) {

  var params = {
    Key: {
      "userId": {
          S: event.userId
      }
    },
    ExpressionAttributeNames: {
      "#device": "device"
    },
    ExpressionAttributeValues: {
      ":device": {
        S: event.arn
      }
    },
    ReturnValues: "ALL_NEW",
    TableName: "meetzam-mobilehub-1569925313-UserProfile",
    UpdateExpression: "SET #device = :device" 
  };

  dynamoDB.updateItem(params, function(err, data) {
          if (err) console.log(err, err.stack); // an error occurred
          else     console.log("success"); 
  });

}

