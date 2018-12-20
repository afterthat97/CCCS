<?php

require "config.php";
require "utils.php";

$conn = mysqli_connect($dbhost, $dbuser, $dbpass);

if (!$conn)
    die(encode_result(1, "Failed to connect to MySQL database."));

if (!mysqli_select_db($conn, $dbname))
    die(encode_result(1, "Failed to select database '$dbname'."));

$tables = array("Student", "Teacher", "Course", "Lesson", "StudentCourse", "StudentLesson", "StudentQuestion");

for ($i = 0; $i < count($tables); $i++) {
    $table = $tables[$i];
    $query = "select 1 from $table limit 1;";
    if (!mysqli_query($conn, $query))
        die(encode_result(1, "Missing database table: '$table'."));
}

echo encode_result(0, "Everything works fine.");

?>
