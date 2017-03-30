'use strict';

// scan movie_table and delete movies that doesn't have tmdb_id
module.exports.handler = scanMovieTableAndDeleteIdLessMovies;


const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});

function scanMovieTableAndDeleteIdLessMovies(event, context, callback) {
	// scan options for DynamoDB table
    let params = {
        TableName: 'movie_table',
        ReturnConsumedCapacity: 'TOTAL',
        FilterExpression: 'attribute_not_exists (tmdb_id)'
    };

    dynamoDB.scan(params, function(error, data) {
        if (error)
            console.error(error.stack);
        else {
            data.Items.forEach((item) => {
	        	console.log("Idless movie: " + item.title.S);
	        	if (!item.tmdb_id) {
	        		var params_d = {
						Key: {
							"title": {
						    	S: item.title.S
						    } 
						}, 
						TableName: "movie_table"
					};
					dynamoDB.deleteItem(params_d, function(err, data) {
						if (err) console.log(err, err.stack); // an error occurred
					    else     console.log(data);           // successful response
					});
	        	}
        	});
        }
    });
    
}






