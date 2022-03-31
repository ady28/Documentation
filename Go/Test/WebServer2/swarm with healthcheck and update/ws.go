package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"

	"github.com/gorilla/mux"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

type Post struct {
	ID    primitive.ObjectID `bson:"_id,omitempty"`
	Title string             `bson:"title,omitempty"`
	Body  string             `bson:"body,omitempty"`
}

var mongoDBServerName = os.Getenv("MONGODBSERVERNAME")
var mongoDBServerPort = os.Getenv("MONGODBSERVERPORT")
var PORT = os.Getenv("PORT")

//for the healthcheck endpoint
var delayTimes int = 0

var (
	httpDuration = promauto.NewHistogramVec(prometheus.HistogramOpts{
		Name: "myapp_http_duration_seconds",
		Help: "Duration of HTTP requests.",
	}, []string{"path"})
)

// prometheusMiddleware implements mux.MiddlewareFunc.
func prometheusMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		route := mux.CurrentRoute(r)
		path, _ := route.GetPathTemplate()
		timer := prometheus.NewTimer(httpDuration.WithLabelValues(path))
		next.ServeHTTP(w, r)
		timer.ObserveDuration()
	})
}

//run go mod init and go mod tidy

func main() {

	databases := ListDatabases(mongoDBServerName, mongoDBServerPort)
	fmt.Println(databases)
	collections := ListCollections(mongoDBServerName, mongoDBServerPort)
	fmt.Println(collections)

	handleRequests()
}

func handleRequests() {
	myRouter := mux.NewRouter().StrictSlash(true)
	myRouter.Use(prometheusMiddleware)
	myRouter.HandleFunc("/", sroot)
	myRouter.HandleFunc("/posts", getAllPosts)
	//the delete method must be first otherwise the get one will be executed
	myRouter.HandleFunc("/post/{id}", updatePostBody).Methods("PUT")
	myRouter.HandleFunc("/post/{id}", deletePost).Methods("DELETE")
	myRouter.HandleFunc("/post/{id}", findPost)
	myRouter.HandleFunc("/post", newPost).Methods("POST")
	myRouter.Path("/metrics").Handler(promhttp.Handler())
	myRouter.HandleFunc("/health", getHealth)
	http.ListenAndServe(":"+PORT, myRouter)
}

func sroot(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Welcome to the Adi GoLang web server")
}

func getHealth(w http.ResponseWriter, r *http.Request) {
        if delayTimes <= 4 {
                delayTimes++
                w.WriteHeader(http.StatusBadRequest)
        }
        fmt.Fprintf(w, "OK")
}

func MongoDBConnect() (*mongo.Client, context.Context, context.CancelFunc) {
	mongoString := "mongodb://" + mongoDBServerName + ":" + mongoDBServerPort
	ctx, ctxCancel := context.WithTimeout(context.Background(), 10*time.Second)
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(mongoString))
	if err != nil {
		panic(err)
	}

	return client, ctx, ctxCancel
}

func ListDatabases(server, port string) []string {

	client, ctx, ctxCancel := MongoDBConnect()

	defer client.Disconnect(ctx)
	defer ctxCancel()

	databases, err := client.ListDatabaseNames(ctx, bson.M{})
	if err != nil {
		panic(err)
	}

	return databases
}

func ListCollections(server, port string) []string {

	client, ctx, ctxCancel := MongoDBConnect()

	defer client.Disconnect(ctx)
	defer ctxCancel()

	collections, err := client.Database("testdb").ListCollectionNames(ctx, bson.D{})
	if err != nil {
		panic(err)
	}

	return collections
}

func newPost(w http.ResponseWriter, r *http.Request) {
	client, ctx, ctxCancel := MongoDBConnect()

	defer client.Disconnect(ctx)
	defer ctxCancel()

	reqBody, _ := ioutil.ReadAll(r.Body)
	var post Post
	json.Unmarshal(reqBody, &post)

	collection := client.Database("testdb").Collection("testc")
	_, err := collection.InsertOne(ctx, post)
	if err != nil {
		panic(err)
	}

	json.NewEncoder(w).Encode(post)
}

func findPost(w http.ResponseWriter, r *http.Request) {

	vars := mux.Vars(r)
	key := vars["id"]

	id, err := primitive.ObjectIDFromHex(key)
	if err != nil {
		log.Fatal(err)
	}

	var post Post

	client, ctx, ctxCancel := MongoDBConnect()

	defer client.Disconnect(ctx)
	defer ctxCancel()

	collection := client.Database("testdb").Collection("testc")

	if err := collection.FindOne(ctx, bson.M{"_id": id}).Decode(&post); err != nil {
		fmt.Printf("%s not found\n", id)
	} else {
		json.NewEncoder(w).Encode(post)
	}
}

func getAllPosts(w http.ResponseWriter, r *http.Request) {
	var posts []Post

	client, ctx, ctxCancel := MongoDBConnect()

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

	json.NewEncoder(w).Encode(posts)
}

func deletePost(w http.ResponseWriter, r *http.Request) {

	vars := mux.Vars(r)
	key := vars["id"]

	id, err := primitive.ObjectIDFromHex(key)
	if err != nil {
		log.Fatal(err)
	}

	client, ctx, ctxCancel := MongoDBConnect()

	defer client.Disconnect(ctx)
	defer ctxCancel()

	collection := client.Database("testdb").Collection("testc")

	result, err := collection.DeleteOne(ctx, bson.M{"_id": id})
	if err != nil {
		log.Fatal(err)
	}
	json.NewEncoder(w).Encode(result)
}

func updatePostBody(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	key := vars["id"]

	reqBody, _ := ioutil.ReadAll(r.Body)
	var body string
	json.Unmarshal(reqBody, &body)

	id, err := primitive.ObjectIDFromHex(key)
	if err != nil {
		log.Fatal(err)
	}

	client, ctx, ctxCancel := MongoDBConnect()

	defer client.Disconnect(ctx)
	defer ctxCancel()

	collection := client.Database("testdb").Collection("testc")
	filter := bson.M{"_id": bson.M{"$eq": id}}
	update := bson.M{"$set": bson.M{"body": body}}
	updated, err := collection.UpdateOne(ctx, filter, update)

	if err != nil {
		log.Fatal(err)
	}
	json.NewEncoder(w).Encode(updated)
}
