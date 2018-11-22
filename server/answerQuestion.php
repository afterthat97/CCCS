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

if ($answer = get_answer_by_sid_and_qid($conn, $user_info["sid"], $_GET["qid"])) {
    $submit_time = $answer["submit_time"];
    die(encode_result(1, "You have answered at $submit_time"));
}

$question = get_question_by_qid($conn, $_GET["qid"]);
$lesson = get_lesson_by_lid($conn, $question["lid"]);

$distance = get_distance($_GET["latitude"], $_GET["longitude"], $lesson["latitude"], $lesson["longitude"]);

if ($distance > $checkin_distance_limit)
    die(encode_result(1, "You are too far away. ($distance m)"));

if (new_answer_to_question($conn, $user_info["sid"], $_GET["qid"], $_GET["choice"]))
    echo encode_result(0, "Submitted successfully.");
else
    echo encode_result(1, "Invalid syntax.");

close_db($conn);

?>
