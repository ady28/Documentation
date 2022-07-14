To start the application run:
  docker-compose up -d

To get a list of posts:
  Invoke-RestMethod -Uri 'http://localhost:8080/posts'

To insert a new post:
 $j=@"
 {
   "title":"Adi2",
   "body":"Adi2 body"
 }
 "@
 Invoke-RestMethod -Uri 'http://localhost:8080/post' -Method Post -Body $j

 To modify an existing post's body:
   $a="just a test body"
   Invoke-RestMethod -Uri 'http://localhost:8080/post/61bd14510e8437169edd3c2d' -Method Put -Body ($a | ConvertTo-Json)

To get only one post:
  Invoke-RestMethod -Uri 'http://localhost:8080/post/61bd14580e8437169edd3c30'

To delete a post:
  Invoke-RestMethod -Uri 'http://localhost:8080/post/61bd14580e8437169edd3c30' -Method Delete

To stop the application (will remove the containers and the network but not the volume):
  docker-compose down


#For testing an update rollout
#First create a v1 image with the name goapi:v1
#Create another one with goapi:v2 with a small change in the code like the response from the / endpoint
#Deploy with swarm the v1 version (resolv image never is because we do not get the image from a registry)
docker stack deploy --compose-file docker-compose.yml --resolve-image never adigolang
#Modify the compose file to request the v2 image
#Deploy the update
docker stack deploy --compose-file docker-compose.yml --resolve-image never adigolang
#Check the service and the containers
docker service ls
docker container ls