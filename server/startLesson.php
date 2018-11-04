<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

if ($_GET["type"] != "Teacher")
    die(encode_result(1, "Permission denied."));

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

$course = get_course_by_id($conn, $_GET["cid"]);

if ($course["tid"] != $user_info["tid"])
    die(encode_result(1, "Permission denied."));

$lessonlist = get_lessonlist_by_cid($conn, $_GET["cid"]);

if ($lessonlist != null && $lessonlist[0]["end_time"] == null)
    die(encode_result(1, "Lesson has started."));

if (new_lesson($conn, $_GET["cid"], $_GET["latitude"], $_GET["longitude"]))
    echo encode_result(0, "New lesson starts.");
else
    echo encode_result(1, "Invalid syntax.");

close_db($conn);

?>
