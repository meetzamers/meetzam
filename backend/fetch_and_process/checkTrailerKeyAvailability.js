'use strict';

// Scheduled to run at 10:08am (UTC) everyday, scan movie_table and check availability of trailer_key. For those movies that doesn't have a trailer_key, mark trailer_key as "unavailable".
module.exports.handler = scanMovieTableAndCheckTrailerKeyAvailability;


const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function scanMovieTableAndCheckTrailerKeyAvailability(event, context, callback) {
	// scan options for DynamoDB table
    let params = {
        TableName: 'movie_table',
        ReturnConsumedCapacity: 'TOTAL',
        FilterExpression: 'attribute_not_exists (trailer_key)'
    };

    dynamoDB.scan(params, function(error, data) {
        if (error)
            console.error(error.stack);
        else {
            data.Items.forEach((item) => {
	        	console.log("trailer_key less movie: " + item.title.S);
	        	if (!item.trailer_key) {
	        		var params = {
						Key: {
			            	"title": {
			                	S: item.title.S
			            	}
			        	},
			        	ExpressionAttributeNames: {
			                "#trailer_key": "trailer_key"
			        	},
			        	ExpressionAttributeValues: {
			                ":trailer_key": {
			                	S: "unavailable"
			                }
			        	},
			        	ReturnValues: "ALL_NEW",
			        	TableName: "movie_table",
			      	 	UpdateExpression: "SET #trailer_key = :trailer_key" 
					};
				dynamoDB.updateItem(params, function(err, data) {
		            if (err) console.log(err, err.stack); // an error occurred
		            else   
		            	console.log("update success"); 
	    		});
	        	}
        	});
        }
    });
    
}






