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

if ($lessonlist == null || $lessonlist[0]["end_time"] != null)
    die(encode_result(1, "Lesson not started."));

$latest_lesson = get_lessonlist_by_cid($conn, $_GET["cid"])[0];

$selection_records = get_selection_records_by_cid($conn, $_GET["cid"]);

$absent_count = 0;

for ($i = 0; $i < count($selection_records); $i++)
    if (!get_checkin_record($conn, $selection_records[$i]["sid"], $latest_lesson["lid"])) {
        $absent_count++;
        if (!new_checkin_record($conn, $selection_records[$i]["sid"], $latest_lesson["lid"], null, "Absent"))
            die(encode_result(1, "Failed to count the absent."));
    }

if (end_lesson($conn, $latest_lesson["lid"]))
    echo encode_result(0, "Lesson is over, $absent_count student(s) absent.");
else
    echo encode_result(1, "Failed to stop lesson.");

close_db($conn);

?>
