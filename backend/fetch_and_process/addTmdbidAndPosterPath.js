'use strict';

// scan entire movie_table. For each item, query 'title' and 'releaseYear' and invoke getOneMovie function to get tmdb_id and poster_path, then update the item to include 'tmdb_id' and 'poster_path'. 
module.exports.handler = scan_invoke_and_update;

const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function scan_invoke_and_update (event, context, callback) {
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
        		// invoking getOneMovie
        		var title = item.title.S;
        		title = title.replace(/\ /g, "%20"); 
        		var year = item.releaseYear.S;

        		let payload = {
					"title": title,
					"year": year
				};
				let tmdb_params = {
					FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getOneMovie-dev",
					InvocationType: "RequestResponse",
					Payload: JSON.stringify(payload)
				};

				lambda.invoke(tmdb_params, (err, data) => {
					if (err) {
						console.error(err, null);
					}
					else {	
						//console.log("payload = " + data.Payload);
						updateOneMovieInMovieTable(title.replace(/\%20/g, " "), JSON.parse(data.Payload));
					}     
				});

        	});
        }
    });
    callback(null, "success");
}


function updateOneMovieInMovieTable(title, Payload) {
	var total = Payload.total_results;
	var results = Payload.results;
	if (total > 0) {
		var tmdb_id = results[0].id.toString();
		var poster_path = results[0].poster_path;
		var params = {
			Key: {
            	"title": {
                	S: title
            	}
        	},
        	ExpressionAttributeNames: {
                "#tmdb_id": "tmdb_id",
                "#poster_path": "poster_path"
        	},
        	ExpressionAttributeValues: {
                ":tmdb_id": {
                	S: tmdb_id
                },
                ":poster_path": {
                	S: poster_path
                }
        	},
        	ReturnValues: "ALL_NEW",
        	TableName: "movie_table",
      	 	UpdateExpression: "SET #tmdb_id = :tmdb_id, #poster_path = :poster_path" 
		};
		dynamoDB.updateItem(params, function(err, data) {
            if (err) console.log(err, err.stack); // an error occurred
            else   
            	console.log("updateOneMovieInMovieTable success"); 
    	});
	}
}

