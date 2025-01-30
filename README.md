# golang-todo list simple service. Using Golang(Gin) + Flutter(Dart) + DB(MongoDB)


## Usage:
- add task (add title, add description)
- update task (change title, change description, mark as done)
- delete task 

### Run

#### Run back-end (golang):\

- go to back-end folder
- run `go mod tidy` to install all needed depandancies
- run `go run main.go` to run back-end
  
#### Run MongoDB:

- install mongoDB
- run `sudo systemctl start mongodb` to run monodb
  
#### Run front-end(flutter):

- go to front-end/todo-app
- run `flutter run -d chrome --web-port <SELECT YOUR PORT>` to run flutter app for google-chrome using needed port ( i use 14888)
  

  
