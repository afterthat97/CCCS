<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

if ($_GET["type"] != "Student")
    die(encode_result(1, "Permission denied."));

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

if (get_course_by_id($conn, $_GET["cid"]) == null)
    die(encode_result(1, "Course not found."));

if (get_selection_record($conn, $user_info["sid"], $_GET["cid"]))
    die(encode_result(1, "You have already selected it."));

if (select_course($conn, $user_info["sid"], $_GET["cid"]))
    echo encode_result(0, "Course has been selected.");
else
    echo encode_result(1, "Internal error.");

close_db($conn);

?>
