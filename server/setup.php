<?php

require "config.php";
require "utils.php";

$conn = mysqli_connect($dbhost, $dbuser, $dbpass);

echo "<pre>";

if (!$conn) {
    echo "<p style='color:Red;'>Failed to connect to MySQL: " . mysqli_connect_error() . "</p>";
    echo "<p style='color:Red;'>Please check your credentials in 'config.php'</p>";
    die('');
}

echo "<p>Successfully connected to MySQL.</p>";

if (!mysqli_select_db($conn, $dbname)) {
    echo "<p>Create new database '$dbname'...</p>";
    $query = "create database $dbname;";
    if (!mysqli_query($conn, $query))
        die("<p style='color:Red'>Failed to create database '$dbname': " . mysqli_error($conn) . "</p>");
    if (!mysqli_select_db($conn, $dbname))
        die("<p style='color:Red'>Failed to select database '$dbname': " . mysqli_error($conn) . "</p>");
}

echo "<p>Successfully connected to database '$dbname'.</p>";

echo "<p>Checking tables....</p>";

$query = "select 1 from Student limit 1;";
if (!mysqli_query($conn, $query)) {
    $query = "CREATE TABLE Student (".
        "sid INT NOT NULL AUTO_INCREMENT,".
        "username VARCHAR(100) NOT NULL,".
        "password VARCHAR(100) NOT NULL,".
        "realname VARCHAR(100) NOT NULL,".
        "gender VARCHAR(10) NOT NULL,".
        "PRIMARY KEY (sid)".
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8;";
    if (mysqli_query($conn, $query))
        echo "<p>Table 'Student' created successfully.</p>";
    else
        die("<p>Failed to create table 'Student': " . mysqli_error($conn) . "</p>");
} else {
    echo "<p>Table 'Student' exists.</p>";
}

$query = "select 1 from Teacher limit 1;";
if (!mysqli_query($conn, $query)) {
    $query = "CREATE TABLE Teacher (".
        "tid INT NOT NULL AUTO_INCREMENT,".
        "username VARCHAR(100) NOT NULL,".
        "password VARCHAR(100) NOT NULL,".
        "realname VARCHAR(100) NOT NULL,".
        "gender VARCHAR(10) NOT NULL,".
        "PRIMARY KEY (tid)".
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8;";
    if (mysqli_query($conn, $query))
        echo "<p>Table 'Teacher' created successfully.</p>";
    else
        die("<p>Failed to create table 'Teacher': " . mysqli_error($conn) . "</p>");
} else {
    echo "<p>Table 'Teacher' exists.</p>";
}

$query = "select 1 from Course limit 1;";
if (!mysqli_query($conn, $query)) {
    $query = "CREATE TABLE Course (".
        "cid INT NOT NULL AUTO_INCREMENT,".
        "tid INT NOT NULL,".
        "name VARCHAR(100) NOT NULL,".
        "credit INT NOT NULL,".
        "FOREIGN KEY (tid) REFERENCES Teacher(tid),".
        "PRIMARY KEY (cid)".
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8;";
    if (mysqli_query($conn, $query))
        echo "<p>Table 'Course' created successfully.</p>";
    else
        die("<p>Failed to create table 'Course': " . mysqli_error($conn) . "</p>");
} else {
    echo "<p>Table 'Course' exists.</p>";
}

$query = "select 1 from Lesson limit 1;";
if (!mysqli_query($conn, $query)) {
    $query = "CREATE TABLE Lesson (".
        "lid INT NOT NULL AUTO_INCREMENT,".
        "cid INT NOT NULL,".
	    "start_time DATETIME,".
        "end_time DATETIME,".
        "latitude DOUBLE,".
        "longitude DOUBLE,".
        "FOREIGN KEY (cid) REFERENCES Course(cid),".
        "PRIMARY KEY (lid)".
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8;";
    if (mysqli_query($conn, $query))
        echo "<p>Table 'Lesson' created successfully.</p>";
    else
        die("<p>Failed to create table 'Lesson': " . mysqli_error($conn) . "</p>");
} else {
    echo "<p>Table 'Lesson' exists.</p>";
}

$query = "select 1 from StudentCourse limit 1;";
if (!mysqli_query($conn, $query)) {
    $query = "CREATE TABLE StudentCourse (".
        "sid INT NOT NULL,".
        "cid INT NOT NULL,".
        "FOREIGN KEY (sid) REFERENCES Student(sid),".
        "FOREIGN KEY (cid) REFERENCES Course(cid),".
        "PRIMARY KEY (sid, cid)".
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8;";
    if (mysqli_query($conn, $query))
        echo "<p>Table 'StudentCourse' created successfully.</p>";
    else
        die("<p>Failed to create table 'StudentCourse': " . mysqli_error($conn) . "</p>");
} else {
    echo "<p>Table 'StudentCourse' exists.</p>";
}

$query = "select 1 from StudentLesson limit 1;";
if (!mysqli_query($conn, $query)) {
    $query = "CREATE TABLE StudentLesson (".
        "sid INT NOT NULL,".
        "lid INT NOT NULL,".
        "checkin_time DATETIME,".
        "status VARCHAR(20) NOT NULL,".
        "FOREIGN KEY (sid) REFERENCES Student(sid),".
        "FOREIGN KEY (lid) REFERENCES Lesson(lid),".
        "PRIMARY KEY (sid, lid)".
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8;";
    if (mysqli_query($conn, $query))
        echo "<p>Table 'StudentLesson' created successfully.</p>";
    else
        die("<p>Failed to create table 'StudentLesson': " . mysqli_error($conn) . "</p>");
} else {
    echo "<p>Table 'StudentLesson' exists.</p>";
}

echo "<p>Everything works fine.</p>";

echo "</pre>";

?>
