'use strict';

// delete chatroom in chatroom table,
// this function takes argument event.chatRoomId as key
module.exports.handler = deleteChatRoom;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function deleteChatRoom (event, context, callback) {

    dynamoDB.deleteItem({
        TableName: "chatroom", 
        Key : {
            "chatRoomId": event.chatRoomId
        }
        //"ReturnValues": "ALL_OLD"
    }, function (err, data) {
        if (err) {
            context.fail('FAIL:  Error deleting item from dynamodb - ' + err);
        }
        else {
            console.log("DEBUG:  deleteItem worked. ");
            context.succeed(data);
        }
    });
}