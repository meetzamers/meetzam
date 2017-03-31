'use strict';

// // scan entire movie_table. For each item, query 'tmdb_id' and invoke getTrailer function to get 'trailer_key', then update the item to include 'trailer_key'.
module.exports.handler = scan_invoke_and_update_trailer_key;

const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function scan_invoke_and_update_trailer_key (event, context, callback) {
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
        		// invoking getTiailer
        		var title = item.title.S;
        		var id = item.tmdb_id.S;
				let payload = {
					"id": id
				};
				let tmdb_params = {
					FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getTrailer-dev",
					InvocationType: "RequestResponse",
					Payload: JSON.stringify(payload)
				};
				//invoke function to get tmdb data
				lambda.invoke(tmdb_params, (err, data) => {
					if (err) 
						console.error(err, null);
					else {
						console.log(data.Payload);
						//update function call
						updateOneTrailer(title, JSON.parse(data.Payload));
					}     
				});				
        	});
        }

    });
}


function updateOneTrailer(title, Payload) {

	var results = Payload.results;
	var len = results.length;

	for (var i = 0; i < len; i++) {
		if (results[i].type == "Trailer" && results[i].site == "YouTube") {
			var trailer_key = results[i].key;

			var params = {
				Key: {
	            	"title": {
	                	S: title
	            	}
	        	},
	        	ExpressionAttributeNames: {
	                "#trailer_key": "trailer_key"
	        	},
	        	ExpressionAttributeValues: {
	                ":trailer_key": {
	                	S: trailer_key
	                }
	        	},
	        	ReturnValues: "ALL_NEW",
	        	TableName: "movie_table",
	      	 	UpdateExpression: "SET #trailer_key = :trailer_key" 
			};
			dynamoDB.updateItem(params, function(err, data) {
	            if (err) console.log(err, err.stack); // an error occurred
	            else   
	            	console.log("updateOneTrailer success"); 
    		});
    		break;
		}
	}
}