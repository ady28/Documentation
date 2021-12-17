package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Post struct {
	ID    primitive.ObjectID `bson:"_id,omitempty"`
	Title string             `bson:"title,omitempty"`
	Body  string             `bson:"body,omitempty"`
}

var mongoDBServerName = "localhost"
var mongoDBServerPort = "27017"

//run go mod init and go mod tidy

func main() {

	databases := ListDatabases(mongoDBServerName, mongoDBServerPort)
	fmt.Println(databases)
	collections := ListCollections(mongoDBServerName, mongoDBServerPort)
	fmt.Println(collections)
	//newPost(mongoDBServerName, mongoDBServerPort)
	//findPost(mongoDBServerName, mongoDBServerPort, "Adi1")
	//deletePost(mongoDBServerName, mongoDBServerPort, "Adi1")
	findPost(mongoDBServerName, mongoDBServerPort, "61bbbd14f24141e64eb8648a")
	//getAllPosts(mongoDBServerName, mongoDBServerPort)

}

func MongoDBConnect(server, port string) (*mongo.Client, context.Context, context.CancelFunc) {
	mongoString := "mongodb://" + server + ":" + port
	ctx, ctxCancel := context.WithTimeout(context.Background(), 10*time.Second)
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(mongoString))
	if err != nil {
		panic(err)
	}

	return client, ctx, ctxCancel
}

func ListDatabases(server, port string) []string {

	client, ctx, ctxCancel := MongoDBConnect(server, port)

	defer client.Disconnect(ctx)
	defer ctxCancel()

	databases, err := client.ListDatabaseNames(ctx, bson.M{})
	if err != nil {
		panic(err)
	}

	return databases
}

func ListCollections(server, port string) []string {

	client, ctx, ctxCancel := MongoDBConnect(server, port)

	defer client.Disconnect(ctx)
	defer ctxCancel()

	collections, err := client.Database("testdb").ListCollectionNames(ctx, bson.D{})
	if err != nil {
		panic(err)
	}

	return collections
}

func newPost(server, port string) {
	client, ctx, ctxCancel := MongoDBConnect(server, port)

	defer client.Disconnect(ctx)
	defer ctxCancel()

	post := Post{
		Title: "Adi1",
		Body:  "Adi1 body",
	}

	collection := client.Database("testdb").Collection("testc")
	_, err := collection.InsertOne(ctx, post)
	if err != nil {
		panic(err)
	}
}

func findPost(server, port, title string) {

	var post Post

	client, ctx, ctxCancel := MongoDBConnect(server, port)

	defer client.Disconnect(ctx)
	defer ctxCancel()

	collection := client.Database("testdb").Collection("testc")

	ID, err := primitive.ObjectIDFromHex(title)
	if err != nil {
		log.Fatal(err)
	}

	if err := collection.FindOne(ctx, bson.M{"_id": ID}).Decode(&post); err != nil {
		fmt.Printf("%s not found\n", title)
	} else {
		fmt.Println(post.ID.Hex())
	}
}

func getAllPosts(server, port string) {
	var posts []Post

	client, ctx, ctxCancel := MongoDBConnect(server, port)

	defer client.Disconnect(ctx)
	defer ctxCancel()

	collection := client.Database("testdb").Collection("testc")

	filterCursor, err := collection.Find(ctx, bson.M{})
	if err != nil {
		log.Fatal(err)
	}
	if err = filterCursor.All(ctx, &posts); err != nil {
		log.Fatal(err)
	}

	fmt.Println(posts)
}

func deletePost(server, port, title string) {
	client, ctx, ctxCancel := MongoDBConnect(server, port)

	defer client.Disconnect(ctx)
	defer ctxCancel()

	collection := client.Database("testdb").Collection("testc")

	result, err := collection.DeleteOne(ctx, bson.M{"title": title})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("DeleteOne removed %v document(s)\n", result.DeletedCount)
}
