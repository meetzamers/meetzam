# meetZam Overview

				 	 						
### Problem Statement 

Has anyone ever found any difficulty finding the correct movie and the ideal company to watch a movie with? Oftentimes, just the process of finding the right movie and organizing it with the right people can be a time-consuming task.

Here at meetZam, we envision a mobile application that allows individuals to search for other people to go to a movie with. Users can select one or more movies that they want to watch and we will match them with a group of people sharing the same interests. 

### Background Info	
					
##### Targeted Users 
		
We noticed a gap in the market for individuals who have difficulty finding the ideal movie to watch. Even after deciding on a movie, finding the ideal company can prove to be an uphill task as well.
					
##### Similar Platforms 
	
There are a couple of movie apps currently available on the App Store, such as Movies by Flixster and Fandango Movies. They provide similar functionalities such as showtime information, commenting and reviewing, online ticketing and detailed movie information.  

##### Limitations 

While both of the apps mentioned above have proven to be useful, they both lack the ability to help people find their movie-buddies. We believe that one of the major factor that hinders people from going to the movies is the fact that they can’t find other people to go with in a timely manner. 

We aim to address the problem by creating a mobile application that not only provides movie showtimes, commenting and reviewing, but also offers a matching mechanism that groups people based on what movies they want to watch.
			
### Functional Requirements

1. As a user, I want to create an account
2. As a user, I want to have multiple signup/login options
3. As a user, I want to know what movies are out this week
4. As a user, I want to know the popularity of the movies
5. As a user, I want to filter movies according to category
6. As a user, I want to check posters and introductions of a movie
7. As a user, I want to have a friend list
8. As a user, I want to invite my friends to watch movies
9. As a user, I want to receive notification when my friends send me movie invitations
10. As a user, I may want to choose to watch movies with strangers rather than alone when my friends are not available
11. As a user, I want to mark the movies I want to watch and wait for others to join me
12. As a user, I want to see who (friends/strangers) are still finding a movie buddy for the movie I want to watch
13. As a developer, I would like to add users who agree to watch movies together to a group chat with 3-10 people
14. As a user, after being added to a stranger group chat, I may want to quit the group chat if I changed my mind
15. As a user, I want to rate the strangers that I went to the movie with
16. As a user, I would like to comment on the movies I have watched
17. As a user, I would like to see other public comments on the movies
18. As a user, I want to chat with friends or strangers about specific plans of how we are going to watch the movie
19. As a user, I want to rate the movies I have watched
20. As a user, I want to create a personal movie list that saves the movies I liked, which can be shared to the public or my friends
21. As a user, I want to know what movies will be out in the next few weeks
22. As a user, I want to see short reviews of the movies that I want to watch
23. As a user, I want to check another user’s meetZam credit score, which indicates a user’s manner on meetZam application and post-matching behaviors
24. As a user, I want to report another user if he or she demonstrated inappropriate behaviors, and their meetZam credit score will be deducted
25. As a user, I want to search and add friends by their usernames
26. As a user, I want to have the option of adding my friends on social media to my friendlist on meetZam
27. As a user, I want to know what movies my friends have watched
28. As a user, I want to filter movies comments to show only my friends’ comments
29. As a user, I want to know what movies my friends want to watch


### Non-Functional Requirements
							
##### Architecture 
					
We’ve decided to develop the application on the iOS platform targeting iPhone users under several considerations, such as operating system performance, stability, security, and platform popularity. One highlight of our application architecture is that we’re building a No-Server backend, or so-called Serverless Architecture. 

The idea is that we will break our backend functionalities and logics into many small pieces that each serve as an individual cloud-based micro-service that performs some simple tasks. This approach solves many problems that arises from a traditional server-based architecture such as network and server management, compatibility and dependency management, scalability problems, and inefficient use of resources. In addition, since many application backends share common functionalities, breaking them into individual micro-services increases code reusability significantly. 

##### Framework and Tools

We will utilize Serverless Framework to help configure, provision and deploy Lambda functions onto AWS services. These Lambda functions respond to events, and can be triggered by our mobile app using AWS Mobile SDK or HTTP(s) requests via a custom API hosted on AWS API Gateway. Once triggered, the Lambda functions will perform tasks suitable to support the functional needs of our application, such as data processing, user authentication, communicate with database, file system, and external APIs. 

Client side logics will be written in Swift and uses Xcode as the primary development environment. Lambda functions will be written in JavaScript using Node.js 4.3 runtime. User authentication will support 3rd-party authentication providers such as Facebook, Google, and Amazon. In-app push notification will be done using Amazon Pinpoint, while email notification will be done using AWS SNS. 

##### Security

One advantage of building backend on a matured platform like AWS is security. AWS services come with several security feathers out of the box. AWS IAM is a permission management service that enable us to assign appropriate permissions to different user groups, and admin groups to make sure no surprise will hit our face from the ground up. In addition, user authentication and other user activities will be filtered, monitored, and reported through Amazon Cognito so that things could fly smoothly and securely.  

##### Usability

Our users are very important to us, because everything eventually comes down to if users like the product or not. Thus user experience will be a driven factor of our UI/UX design process. We try to make things easy for our users from the very beginning by allowing only 3rd-party authentication to free our users from memorizing yet another password and the frustrating process of entering the password. Once logged in, it is easy to navigate through and understand the functionality of our app via a thoughtful, intuitive user interface. 

In addition, we require essentially no input from our users to minimize the initial setup process so that a new user can start to enjoy the exciting service we aimed to provide right away. Furthermore, by utilizing both in-app and email notification mechanism, we can provide our users with their matching status in real time to make sure everyone gets notified as soon as we match our user with a group. Combining with an in-app group chat room, our users will be able to have more detailed discussions and plan an outing with their new movie buddies. 

##### Protecting Our Users

We have reimagined the reviewing and commenting process because we understand the importance of reviewing and commenting and how they can be abused by hostile users which leads to a significant drawback in the experience for other users. And finally, to make sure our users have enjoyable experiences, we think beyond the scope of just the application by providing a user rating mechanism as a method encouraging proper social conduct during group movie sessions.


