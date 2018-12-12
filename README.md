Ablegatio Co.
===

This project will be focused on creating a web application for the fictional company, Ablegatio Co. 
The app will be primarily for internal use, thus the two primary end-users will be the administrators (dispatch managers) and the drivers.
The web application will be programmed in Swift with the Vapor framework. 
Rendering will be done with Vapor’s “Leaf” templating language. 
Any client-side behavior will be handled by JavaScript and jQuery. 
The application will be supported by a MySQL database. The “Fluent” framework will be used as a driver and ORM for Vapor.

### Getting Started

To get started with this project, first clone the repository.

Next, install Xcode if you haven't already.

Open terminal and change to the cloned repository directory. Type `xcode-select --install` to make sure that your toolchain is linked and up-and-running. Next, type `swift --version` to make sure Swift is working.

If not already installed it, head over to (brew.sh)[brew.sh] and install Homebrew. This is a really use package manager for macOS.

Run `brew install vapor/tap/vapor` to install the Vapor toolbox.

### Loading the Database

Import the provided SQL file located in the base of the repository into your MySQL server. (This snapshot was taken with MySQL 5.7).

The provided database has two users:
(admin, password) - Administrator
(test, password) - Driver

### Running

`vapor xcode`  
`open Project4.xcodeproj`

Xcode will now open.

You must now configure the database. This project assumes that the MySQL server is running on your local machine.

Create a new Swift file, call it `database-config.swift`. In it, put a single line:

```swift
let dbConfig = DatabaseConfig(username: DB_USER, password: DB_PASS, name: DB_NAME)
```

Replace the all-caps placeholders with your DB username, password, and the DB to use.

Make sure your MySQL servier is running. Finally, press the Run button (or cmd-R).