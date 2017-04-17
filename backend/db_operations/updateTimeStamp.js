'use strict';

// update timeStamp in chatroom table,
// this function takes argument event.chatRoomId as key, then update event.timeStamp
module.exports.handler = getChatroomByIdAndUpdateTimeStamp;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function getChatroomByIdAndUpdateTimeStamp (event, context, callback) {

  var params = {
    Key: {
      "chatRoomId": {
          S: event.chatRoomId
      }
    },
    ExpressionAttributeNames: {
      "#timeStamp": "timeStamp"
    },
    ExpressionAttributeValues: {
      ":timeStamp": {
        S: event.timeStamp
      }
    },
    //ReturnValues: "NONE",
    TableName: "chatroom",
    UpdateExpression: "SET #timeStamp = :timeStamp" 
  };

  dynamoDB.updateItem(params, function(err, data) {
          if (err) console.log(err, err.stack); // an error occurred
          else     console.log("success"); 
  });

}

