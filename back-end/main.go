package main

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

// Task represents a task in the todo list
type Task struct {
    ID          primitive.ObjectID `bson:"_id,omitempty"`
    Title       string             `bson:"title"`
    Description string             `bson:"description"`
    Completed   bool               `bson:"completed"`
}

var client *mongo.Client

func main() {
    var err error
    client, err = mongo.NewClient(options.Client().ApplyURI("mongodb://localhost:27017"))
    if err != nil {
        log.Fatal(err)
    }
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()
    err = client.Connect(ctx)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Disconnect(ctx)

    r := gin.Default()

    // Настройка CORS
    config := cors.Config{
        AllowOrigins:     []string{"http://localhost:14888"}, // Используйте порт вашего фронтенда
        AllowMethods:     []string{"GET", "POST", "PUT", "DELETE"},
        AllowHeaders:     []string{"Origin", "Content-Type"},
        ExposeHeaders:    []string{"Content-Length"},
        AllowCredentials: true,
    }
    r.Use(cors.New(config))

    r.POST("/tasks", createTask)
    r.GET("/tasks", getTasks)
    r.PUT("/tasks/:id", updateTask)
    r.DELETE("/tasks/:id", deleteTask)
    r.Run(":8080")
}

func createTask(c *gin.Context) {
    var task Task
    if err := c.ShouldBindJSON(&task); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // Если название задачи пустое, установим его как "-"
    if task.Title == "" {
        task.Title = "-"
    }

    collection := client.Database("todo").Collection("tasks")
    result, err := collection.InsertOne(context.Background(), task)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    task.ID = result.InsertedID.(primitive.ObjectID)
    c.JSON(http.StatusOK, map[string]interface{}{
        "_id":        task.ID.Hex(),
        "title":      task.Title,
        "description": task.Description,
        "completed":  task.Completed,
    })
}

func getTasks(c *gin.Context) {
    var tasks []Task
    collection := client.Database("todo").Collection("tasks")
    cursor, err := collection.Find(context.Background(), bson.M{})
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    defer cursor.Close(context.Background())
    for cursor.Next(context.Background()) {
        var task Task
        if err := cursor.Decode(&task); err != nil {
            c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
            return
        }
        tasks = append(tasks, task)
    }
    if err := cursor.Err(); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    responseTasks := make([]map[string]interface{}, len(tasks))
    for i, task := range tasks {
        responseTasks[i] = map[string]interface{}{
            "_id":        task.ID.Hex(),
            "title":      task.Title,
            "description": task.Description,
            "completed":  task.Completed,
        }
    }
    c.JSON(http.StatusOK, responseTasks)
}

func updateTask(c *gin.Context) {
    id := c.Param("id")
    objID, err := primitive.ObjectIDFromHex(id)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
        return
    }
    var task Task
    if err := c.ShouldBindJSON(&task); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // Если название задачи пустое, установим его как "-"
    if task.Title == "" {
        task.Title = "-"
    }

    collection := client.Database("todo").Collection("tasks")
    filter := bson.M{"_id": objID}
    update := bson.M{
        "$set": bson.M{
            "title":       task.Title,
            "description": task.Description,
            "completed":   task.Completed,
        },
    }
    result, err := collection.UpdateOne(context.Background(), filter, update)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    if result.MatchedCount == 0 {
        c.JSON(http.StatusNotFound, gin.H{"error": "Task not found"})
        return
    }
    c.JSON(http.StatusOK, result)
}

func deleteTask(c *gin.Context) {
    id := c.Param("id")
    objID, err := primitive.ObjectIDFromHex(id)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
        return
    }
    collection := client.Database("todo").Collection("tasks")
    result, err := collection.DeleteOne(context.Background(), bson.M{"_id": objID})
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    if result.DeletedCount == 0 {
        c.JSON(http.StatusNotFound, gin.H{"error": "Task not found"})
        return
    }
    c.JSON(http.StatusOK, result)
}