<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

if ($_GET["type"] != "Student")
    die(encode_result(1, "Permission denied."));

if (!isset($_GET["latitude"]) || !isset($_GET["longitude"]))
    die(encode_result(1, "Invalid syntax."));

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

if (!get_selection_record($conn, $user_info["sid"], $_GET["cid"]))
    die(encode_result(1, "Course not found."));

$lessonlist = get_lessonlist_by_cid($conn, $_GET["cid"]);

if ($lessonlist == null || $lessonlist[0]["end_time"] != null)
    die(encode_result(1, "Lesson not started."));

$latest_lesson = $lessonlist[0];

$distance = get_distance($_GET["latitude"], $_GET["longitude"], $latest_lesson["latitude"], $latest_lesson["longitude"]);

if ($distance > 100)
    die(encode_result(1, "You are too far away. ($distance m)"));

if ($record = get_checkin_record($conn, $user_info["sid"], $latest_lesson["lid"])) {
    $checkin_time = $record["checkin_time"];
    die(encode_result(1, "You have checked in at $checkin_time."));
}

$cnt_time = get_current_time($conn);
$time_diff = get_time_diff($conn, $cnt_time, $latest_lesson["start_time"]);

if ($time_diff <= 120) {
    new_checkin_record($conn, $user_info["sid"], $latest_lesson["lid"], $cnt_time, "Normal");
    echo encode_result(0, "Welcome to class!");
} else {
    new_checkin_record($conn, $user_info["sid"], $latest_lesson["lid"], $cnt_time, "Late");
    echo encode_result(0, "Welcome to class! But you are late.");
}

close_db($conn);

?>
