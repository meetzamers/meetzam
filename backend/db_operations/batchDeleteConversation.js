'use strict';

// delete all 
module.exports.handler = batchDeleteConversation;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const tableName = "meetzam-mobilehub-1569925313-Conversation";

function batchDeleteConversation (event, context, callback) {
    
    const scanTable = new Promise((resolve, reject) => {
        console.log("===== scanTable =====");
        const params = {
            TableName: tableName,
            //Prj
            FilterExpression: "#chatRoomId = :chatRoomId",
            ExpressionAttributeNames: {
                "#chatRoomId": "chatRoomId"
            },
            ExpressionAttributeValues: {
                 ":chatRoomId": {
                    S: event.chatRoomId
                 }
            },
            ReturnConsumedCapacity: 'TOTAL'
        };
        dynamoDB.scan(params, function(error, data) {
            if (error) {
                console.error(error.stack);
                reject(error);
            } else {
                console.log("===== scanTable ====> SUCCESS");
                resolve(data.Items);
            }
        }); 
    });

    const deleteConversation = (items) => {
        return new Promise((resolve, reject) => {
            if (items) {
                console.log("===== deleteConversation ====> BEGIN");
                
                let promises = [];
                items.forEach((item) => {
                    promises.push(deleteOne(item));
                });
                
                Promise.all(promises)
                    .then(fulfilled => {
                        console.log("===== deleteConversation ====> COMPLETE");
                        resolve("===== deleteConversation ====> RESOLVED");
                    })
                    .catch(error => reject(error));
            } else reject("items is undefined");
        });
    };

    const deleteOne = (item) => {
        return new Promise((resolve, reject) => {
            if (item) {
                var params_d = {
                        Key: {
                            "userId": {
                                S: item.userId.S
                            },
                            "conversationId": {
                                S: item.conversationId.S
                            } 
                        }, 
                        TableName: tableName
                };
                dynamoDB.deleteItem(params_d, function(error, data) {
                    if (error) {
                        console.error(error.stack);
                        reject(error);
                    } else {
                        console.log(data);
                        resolve(true);
                    }
                });
            } else reject("item is undefined");
        });
    };

    const run = () => {
        scanTable
            .then(deleteConversation)
            .then(fulfilled => callback(null, fulfilled))
            .catch(error => callback(error.message));
    };

    run();


}