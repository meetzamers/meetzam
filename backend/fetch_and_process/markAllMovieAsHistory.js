'use strict';

// // scan entire movie_table. Mark every movie as 'history'.
module.exports.handler = scan_and_mark_history;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function scan_and_mark_history (event, context, callback) {

	// scan options for DynamoDB table
    let params = {
        TableName: 'movie_table',
        ReturnConsumedCapacity: 'TOTAL'
    };
    dynamoDB.scan(params, function(error, data) {
    	if (error)
            console.error(error.stack);
        else {
        	data.Items.forEach((item) => {
        		var title = item.title.S;
				var db_params = {
					Key: {
		            	"title": {
		                	S: title
		            	}
		        	},
		        	ExpressionAttributeNames: {
		                "#isHistory": "isHistory"
		        	},
		        	ExpressionAttributeValues: {
		                ":isHistory": {
		                	BOOL: true
		                }
		        	},
		        	ReturnValues: "ALL_NEW",
		        	TableName: "movie_table",
		      	 	UpdateExpression: "SET #isHistory = :isHistory" 
				};
				dynamoDB.updateItem(db_params, function(err, data) {
		            if (err) console.log(err, err.stack); // an error occurred
		            else   
		            	console.log("marking history success"); 
	    		});
        	});
        }
    });	
}

