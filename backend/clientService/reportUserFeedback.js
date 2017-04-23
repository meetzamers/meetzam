'use strict';


module.exports.handler = sendDefaultReponseToReporter;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const ses = new AWS.SES({apiVersion: '2010-12-01'});

// send default response email to reporter, identified by event.useerId
function sendDefaultReponseToReporter(event, context, callback) {
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
       
       var emailAddress = data.Item.email.S;
       var displayName = data.Item.displayName.S;
       if (emailAddress) {
            console.log("target Email: " + emailAddress);

            var ses_param = {
                Destination: {
                   ToAddresses: [ 
                      emailAddress
                   ]
                }, 

                Message: {
                  Body: {
                    Html: {
                     Charset: "UTF-8", 
                     Data: "<h3>Dear " + displayName + ",</h3>" + "<p>Thank you for being open and honest about your experience. We truly appreciate your report on helping us improve our product/service even further. Our team is working hard to make sure that this doesn’t happen again. If you don’t mind I would be happy to keep you updated about our improvement.</p><p>Cheers,</p><p>Meetzam team</p>"
                    }, 
                  Text: {
                     Charset: "UTF-8", 
                     Data: "This is the message body in text format."
                    }
                  }, 
                   Subject: {
                    Charset: "UTF-8", 
                    Data: "Thank you for your feedback!"
                   }
                }, 
                Source: "meetzam@163.com", 
                SourceArn: "arn:aws:ses:us-east-1:397508666882:identity/meetzam@163.com"
            };

            ses.sendEmail(ses_param, function(err, data) {
                if (err) console.log(err, err.stack); // an error occurred
                else     console.log(data);           // successful response
                /*
               data = {
                MessageId: "EXAMPLE78603177f-7a5433e7-8edb-42ae-af10-f0181f34d6ee-000000"
               }
               */
            });
        }
    });

}

