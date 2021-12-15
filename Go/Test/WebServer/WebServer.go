package main

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

//run go mod init and go mod tidy

func main() {

	client, err := mongo.NewClient(options.Client().ApplyURI("mongodb://localhost:27017"))
	if err != nil {
		fmt.Println(err)
		return
	}
	ctx, ctxc := context.WithTimeout(context.Background(), 10*time.Second)
	err = client.Connect(ctx)
	if err != nil {
		fmt.Println(err)
		return
	}
	defer client.Disconnect(ctx)
	defer ctxc()
	databases, err := client.ListDatabaseNames(ctx, bson.M{})
	if err != nil {
		fmt.Println(err)
	}
	fmt.Println(databases)

	type Post struct {
		Title string `bson:"title,omitempty"`
		Body  string `bson:"body,omitempty"`
	}

	cols, _ := client.Database("testdb").ListCollectionNames(ctx, bson.D{})
	fmt.Println(cols)
	collection := client.Database("testdb").Collection("testc")
	filter := bson.D{}
	c, _ := collection.CountDocuments(ctx, filter)
	fmt.Println(c)
	//docs := []interface{}{
	//	bson.D{{"title", "World"}, {"body", "Hello World"}},
	//	bson.D{{"title", "Mars"}, {"body", "Hello Mars"}},
	//	bson.D{{"title", "Pluto"}, {"body", "Hello Pluto"}},
	//}
	//res, insertErr := collection.InsertMany(ctx, docs)
	//if insertErr != nil {
	//	fmt.Println(insertErr)
	//}
	//fmt.Println(res)

	cur, currErr := collection.Find(ctx, bson.D{})

	if currErr != nil {
		panic(currErr)
	}
	defer cur.Close(ctx)

	var posts []Post
	if err = cur.All(ctx, &posts); err != nil {
		panic(err)
	}
	fmt.Println(posts)

	//http.HandleFunc("/", sroot)
	//http.ListenAndServe(":8080", nil)
}

func sroot(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Welcome to the Adi GoLang web server")
}
