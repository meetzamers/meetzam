'use strict';


module.exports.handler = publishMatchNotificationToEndpoint;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const sns = new AWS.SNS({apiVersion: '2010-03-31'});



// function takes userId as parameter (event.userId)
function publishMatchNotificationToEndpoint (event, context, callback) {

  // Ryan added below
    var apnsJSON = {
  aps: {
        alert: "We've got a match for you!!!",
        badge: 1
      }
    };
    var apnsString = JSON.stringify(apnsJSON);
    // Ryan added above
 
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
                MessageStructure: "json",
                Message: JSON.stringify({
                default: "We've got a match for you!!!",
                APNS: apnsString,
                APNS_SANDBOX: apnsString
              }),
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

















