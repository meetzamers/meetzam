# meetZam Overview

				 	 						
### Problem Statement 

Has anyone ever found any difficulty finding the correct movie and the ideal company to watch the movie with? Oftentimes, just the process of finding the right movie and organizing it with the right people can be a time-consuming task.

We are envisioning a mobile application which allows people to find other people to go to a movie together. Users can select one or more movies that they want to watch and we will match them with a group of people with the same interests as them. 

### Background Info	
					
##### Targeted Users 
		
We noticed a gap in the market for individuals who have difficulty finding the ideal movie to watch. Even after deciding on a movie, oftentimes, finding the ideal company can prove to be an uphill task as well.
					
##### Similar Platforms 
	
There are a couple of movie apps currently available on the App Store, Movies by Flixster and Fandango Movies. They provide similar functionalities such as showtime information, commenting and reviewing, online ticketing and detailed movie information.  

##### Limitations 

While both of them have proven to be useful, they both lack the ability of helping people finding their movie-buddies. We believe one of major factor that stops people from going to the movie theater is the simple fact that they can’t find people to go with in a timely manner. 

We aim to address such problem by creating a mobile application that provides not only showtime, commenting and reviewing, but also a matching mechanism that groups people based on what movie they wanted to watch.
			
### Functional Requirements

1. As a user, I would like to create an account
2. As a user, I want to have other signup / login options
3. As a user, I want to know what movies are on nearby me this week
4. As a user, I wish to know the relative heat order of the movies
5. As a user, I want to filter movies according to category
6. As a user, I want to look at posters and introductions of movies
7. As a user, I want to have my friend list
8. As a user, I want to invite my friends to watch movies
9. As a user, I want to receive notification when my friends send me movie invitations
10. As a user, I may want to choose to watch movies with strangers rather than alone when my friends are not available
11. As a user, I want to mark movies I want to watch and wait for others to join me
12. As a user, I want to see who (can be friends/strangers, according to my option) are still finding a movie buddy for the movie I want to watch
13. As a developer, I would like to add users who agree to watch movies together to a group chat with 3-10 people
14. As a user, after being added to a stranger group chat, I may want to quit the group chat if I decided not to go with people in group chat
15. As a user, I want to rate the strangers I went to movie with
16. As a user, I would like to comment the movies I have watched
17. As a user, I would like to see other public comments on movies
18. As a user, I want to chat with friends or strangers about specific plans of watching movies
19. As a user, I want to rate the movies I have watched.
20. As a user, I want to create my personal movie list to save the movies I liked, which can be shared to the public or my friends.

21. As a user, I want to know what movies will be on in next few weeks. 
22. As a user, I want to watch a movie in a group with my friends and strangers.
23. As a user, I want to report another user if he or she assaulted me when we are matched and went to movie together.
24. As a user, I want to search and add friends by their user names or phone numbers.
25. As a user, I want to have my friends on other social media as my friends in meetZam.
26. As a user, I want to know what movies my friends have watched.
27. As a user, I want to filter movies comments to show only my friends’ comments.
28. As a user, I want to know what movies my friends want to watch.
29. As a user, I want to see short reviews of the movies that I want to watch.


### Non-Functional Requirements
							
##### Architecture 
					
We’ve decided to develop the application on iOS platform targeting iPhone users under several considerations, such as operating system performance and stability, security, and platform popularity. One highlight of our application architecture is that we’re building a No-Server backend, or so-called Serverless Architecture. 

The idea is that we will break our backend functionalities and logics into many small pieces that each piece serve as an individual cloud-based micro-service that perform some simple task. This approach solves many problem arises from a traditional server-based architecture such as network and server management, compatibility and dependency management, scalability problems, and inefficient use of resources. In addition, since many application backends share common functionalities, break them into individual micro-services increased code reusability significantly. 

##### Framework and Tools

We will utilize Serverless Framework to help configure, provision and deploy Lambda functions onto AWS services. These Lambda functions responds to events, and can be triggered by our mobile app using AWS Mobile SDK or HTTP(s) requests via a custom API hosted on AWS API Gateway. Once triggered, the Lambda functions will perform tasks suitable to support the functional needs of our application. Such as data processing, user authentication, communicate with database, file system, and external APIs. 

Client side logics will be written in Swift and uses Xcode as primary development environment. Lambda functions will be written in JavaScript using Node.js 4.3 runtime. User authentication will support 3rd-party authentication providers such as Facebook, Google, and Amazon. Support in-app push notification using Amazon Pinpoint, email notification using AWS SNS. 

##### Security

One advantage of building backend on a matured platform like AWS is security. AWS services come with several security feathers out of the box. AWS IAM is a permission management service that enable us to assign appropriate permissions to different user groups, and admin groups to make sure no surprise will hit our face from the ground up. In addition, user authentication and other user activities will be filtered, monitored, and reported through Amazon Cognito so that things could fly smoothly and securely.  

##### Usability

Our users are very important to us, because everything eventually comes down to if users like the product or not. Thus user experience will be a driven factor of our UI/UX design process. We try to make things easy for our users from the very beginning by allowing only 3rd-party authentication to free our users from memorizing yet another password and the frustrating process of entering the password. Once logged in, it is easy to navigate through, and understand the functionality of our app via a thoughtful, intuitive user interface. 

In addition, we require essentially no input from our users to minimize the initial setup process so that a new user can start to enjoy the exciting service we aimed to provide right away. Furthermore, by utilize both in-app and email notification mechanism, we can provide our users with their matching status in real time to make sure everyone get notified as soon as we matched our user with a group. Combining with in-app group chat room, our users will be able to have more detailed discussion and planning with their new movie buddies. 

##### Protecting Our Users

We have reimagined the reviewing and commenting process because we understand the importance and how review and comment can be abused by hostile users which leads to significantly reduction in the experience for other users. And finally, to make sure our users have enjoyable experiences, we think beyond the scope of just the application by providing a user rating mechanism as a method encouraging proper social conduct during group movie sessions and possibly keeping the bad guys away.


