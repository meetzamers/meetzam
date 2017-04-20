'use strict';

module.exports.handler = getPotentialMatch;

const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const movieTable = "movie_table";
const profileTable = "meetzam-mobilehub-1569925313-UserProfile";

// Input: event.userId
// query user by event.userId -> then get currentLikedMovie 
// prepare a array to store mached users
// for each movie in currentLikedMovie 
// query movie in movie_table and read the currentLikedUser, append each item in the array.
// return array

function getPotentialMatch(event, context, callback) {

	let potentialMatch = [];
	const userId = event.userId;

	const queryUserByUserId = new Promise((resolve, reject) => {
		console.log("===== queryUserByUserId ====> BEGIN");
		const db_param = {
	      Key: {
	       "userId": { S: event.userId }
	      }, 
	      TableName: profileTable
	    };
	    dynamoDB.getItem(db_param, function(err, data) {
	       if (err) {
	       		console.log(err, err.stack);
	       		reject(err);
	       }
	       else {
	       		let currentLikedMovie = data.Item.currentLikedMovie.SS;
	       		console.log(currentLikedMovie);
	       		console.log("===== queryUserByUserId ====> COMPLETE");
	       		resolve(currentLikedMovie);
	       }            
	    });
	});

	const queryMovies = (currentLikedMovie) => {
		return new Promise((resolve, reject) => {
			if (currentLikedMovie) {
				console.log("===== queryMovies ====> BEGIN");
				const len = currentLikedMovie.length;
				let promises = [];
				for (let i = 0; i < len; i++) {
					let movieTitle = currentLikedMovie[i];
					console.log("movie: " + movieTitle);
					promises.push(queryOne(movieTitle));
				}
				Promise.all(promises)
                    .then(fulfilled => {
                        console.log("===== queryMovies ====> SUCCESS");
                        resolve("===== queryMovies ====> RESOLVED");
                    })
                    .catch(error => reject(error));
			} else reject("currentLikedMovie is undefined"); 
		});
	};

	const queryOne = (movieTitle) => {
		return new Promise((resolve, reject) => {
			if (movieTitle) {
				console.log("===== queryOne ====> BEGIN");
				const db_param = {
			      Key: {
			       "title": { S: movieTitle }
			      }, 
			      TableName: movieTable
			    };
			    dynamoDB.getItem(db_param, function(err, data) {
			       if (err) {
			       		console.log(err, err.stack);
			       		reject(err);
			       }
			       else {
			       		if (!data.Item.currentLikedUser) reject("currentLikedUser is undefined");
			       		let likeUsers = data.Item.currentLikedUser.SS;
			       		console.log(likeUsers);
			       		console.log("===== queryOne ====> COMPLETE");
			       		let len = likeUsers.length;
			       		for (let i = 0; i< len; i++) {
			       			potentialMatch.push(likeUsers[i]);
			       			console.log("potentialMatch: " + likeUsers[i] + " pushed");
			       		}
			       		resolve(true);
			       }            
			    });
			} else reject("movieTitle is undefined");
		});
	};


	const run = () => {
        queryUserByUserId
            .then(queryMovies)
            .then(fulfilled => callback(null, potentialMatch))
            .catch(error => callback(error.message));
    };

    run();














}