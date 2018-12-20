<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

if ($_GET["type"] == "Student") {
    $checkin_records = get_checkin_records_by_sid_and_cid($conn, $user_info["sid"], $_GET["cid"]);
} else if ($_GET["type"] == "Teacher") {
    $checkin_records = get_checkin_records_by_cid($conn, $_GET["cid"]);
} else {
    die(encode_result(1, "Permission denied."));
}

for ($i = 0; $i < count($checkin_records); $i++) {
    $student = get_student_by_id($conn, $checkin_records[$i]["sid"]);
    $lesson = get_lesson_by_lid($conn, $checkin_records[$i]["lid"]);
    $checkin_records[$i]["student"] = $student;
    $checkin_records[$i]["lesson"] = $lesson;
    if ($checkin_records[$i]["checkin_time"] == NULL)
        $checkin_records[$i]["checkin_time"] = "N/A";
    unset($checkin_records[$i]["sid"]);
    unset($checkin_records[$i]["lid"]);
}

echo encode_result(0, $checkin_records);

close_db($conn);

?>
