'use strict';


module.exports.handler = publishNotificationToEndpoint;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const sns = new AWS.SNS({apiVersion: '2010-03-31'});

// function takes userId (event.userId) and (event.message) as parameters
function publishNotificationToEndpoint (event, context, callback) {

	// Ryan added below
    var apnsJSON = {
	aps: {
		    alert: event.message,
 		    badge: 2
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
		            default: event.message,
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
