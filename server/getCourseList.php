<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

if (isset($_GET["all"]) && $_GET["all"] == "1") {
    $courselist = get_courselist_all($conn);
} else if ($_GET["type"] == "Student") {
    $courselist = get_courselist_by_sid($conn, $user_info["sid"]);
} else if ($_GET["type"] == "Teacher") {
    $courselist = get_courselist_by_tid($conn, $user_info["tid"]);
} else
    die(encode_result(1, "Permission denied."));

for ($i = 0; $i < count($courselist); $i++) {
    $teacher = get_teacher_by_id($conn, $courselist[$i]["tid"]);
    $lessonlist = get_lessonlist_by_cid($conn, $courselist[$i]["cid"]);
    $courselist[$i]["teacher"] = $teacher;
    $courselist[$i]["lessonlist"] = $lessonlist;
    unset($courselist[$i]["tid"]);
}

echo encode_result(0, $courselist);

close_db($conn);

?>
