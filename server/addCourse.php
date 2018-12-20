<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

if ($_GET["type"] != "Teacher")
    die(encode_result(1, "Permission denied."));

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

if (get_course_by_name($conn, $_GET["name"], $user_info["tid"]) != null)
    die(encode_result(1, "Course already exists."));

if (new_course($conn, $_GET["name"], $user_info["tid"], $_GET["credit"], $_GET["place"]))
    echo encode_result(0, "Course has been added.");
else
    echo encode_result(1, "Invalid syntax.");

close_db($conn);

?>

