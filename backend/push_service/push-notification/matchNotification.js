'use strict';


module.exports.handler = publishMatchNotificationToEndpoint;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const sns = new AWS.SNS({apiVersion: '2010-03-31'});



// function takes userId as parameter (event.userId)
function publishMatchNotificationToEndpoint (event, context, callback) {
 
    var db_param = {
      Key: {
       "userId": {
         S: event.userId
        }
      }, 
      TableName: "meetzam-mobilehub-1569925313-UserProfile"
    };

    // query the user
    dynamoDB.getItem(db_param, function(err, data) {
       if (err) console.log(err, err.stack); // an error occurred
       else     console.log(data);           // successful response
       
       // get the ARN and send push notification
       var deviceARN = data.Item.device.S;
       if (deviceARN) {
            console.log("Endpoint: " + deviceARN);

            var push_param = {
                Message: "We've got a match for you!!!",
                MessageAttributes: {
                    someKey: {
                        DataType: 'String', /* required */
                        StringValue: 'STRING_VALUE'
                    },
                },
                Subject: "Match found!",
                TargetArn: deviceARN
            };

            sns.publish(push_param, function(err, data) {
                if (err) console.log(err, err.stack); // an error occurred
                else     console.log(data);           // successful response
            });
        }
    });
}


       /*
       data = {
        Item: {
         "AlbumTitle": {
           S: "Songs About Life"
          }, 
         "Artist": {
           S: "Acme Band"
          }, 
         "SongTitle": {
           S: "Happy Day"
          }
        }
       }
       */

















