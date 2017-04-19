'use strict';

// invoke getLocalMovies and update movie_table
module.exports.handler = invokeGetLocalMoviesAndUpdateMovieTable;


const AWS = require('aws-sdk');
const lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
const dynamoDB = new AWS.DynamoDB({apiVersion: '2012-08-10'});
const tableName = "movie_table";

function invokeGetLocalMoviesAndUpdateMovieTable (event, context, callback) {

    const getLocalMovies = new Promise((resolve, reject) => {
        console.log("===== getLocalMovies =====");
        let tms_params = {
            FunctionName: "arn:aws:lambda:us-east-1:397508666882:function:getLocalMovies-dev",
            InvocationType: "RequestResponse"
        };
        //invoke function to get tms data
        lambda.invoke(tms_params, (err, data) => {
            if (err) {
                console.error(err, err.stack);
                reject(err);
            }
            else  {
                console.log("==== getLocalMovies =====> SUCCESS");
                resolve(JSON.parse(data.Payload));
            }           
        });
    });

    const update = (result) => {
        return new Promise((resolve, reject) => {
            if (result) {
                let title = result.title;
                title = title.replace(/ 3D/g, ""); // remove tailing " 3D" from movie title
                let shortDescription = result.shortDescription;
                let longDescription = result.longDescription;
                let releaseYear = result.releaseYear.toString();
                let genres = result.genres;
                let topCast = result.topCast;
                let directors = result.directors;

                let params = {
                    Key: {
                        "title": {
                            S: title
                        }
                    },
                    ExpressionAttributeNames: {
                        "#shortDescription": "shortDescription",
                        "#longDescription": "longDescription",
                        "#genres": "genres",
                        "#topCast": "topCast",
                        "#directors": "directors",
                        "#isHistory": "isHistory",
                        "#releaseYear": "releaseYear"
                    },
                    ExpressionAttributeValues: {
                        ":shortDescription": {
                            S: shortDescription
                        },
                        ":longDescription": {
                            S: longDescription
                        },
                        ":releaseYear": {
                            S: releaseYear
                        },
                        ":genres": {
                            SS: genres
                        },
                        ":topCast": {
                            SS: topCast
                        },
                        ":directors": {
                            SS: directors
                        },
                        ":isHistory": {
                            BOOL: false
                        }
                    },
                    ReturnValues: "ALL_NEW",
                    TableName: tableName,
                    UpdateExpression: "SET #releaseYear = :releaseYear, #shortDescription = :shortDescription, #longDescription = :longDescription, #genres = :genres, #topCast = :topCast, #directors = :directors, #isHistory = :isHistory" 
                };
                dynamoDB.updateItem(params, function(err, data) {
                    if (err) {
                        console.log(err, err.stack); // an error occurred
                        reject(err);
                    }
                    else {
                        console.log(data);
                        resolve(true); 
                    }   
                });
            } else reject("result is undefined");
        });
    };

    const updateLocalMovieInfo = (Payload) => {
        return new Promise((resolve, reject) => {
            if (Payload) {
                console.log("===== updateLocalMovieInfo =====");
                let promises = [];
                const length = Payload.length;
                for (let i = 0; i < length; i++) {
                    if (Payload[i].subType != "Feature Film")
                        continue;
                    else 
                        promises.push(update(Payload[i]));
                }
                Promise.all(promises)
                    .then(fulfilled => {
                        console.log("===== updateLocalMovieInfo ====> SUCCESS");
                        resolve("===== updateLocalMovieInfo ====> RESOLVED");
                    })
                    .catch(error => reject(error));
            } else reject("result of getLocalMovies is undefined");
        });
    };

    const run = () => {
        getLocalMovies
            .then(updateLocalMovieInfo)
            .then(fulfilled => callback(null, fulfilled))
            .catch(error => callback(error.message));
    };

    run();

}



