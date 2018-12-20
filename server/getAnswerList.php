<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

if ($_GET["type"] != "Teacher")
    die(encode_result(1, "Permission denied."));

if (validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]) == null)
    die(encode_result(1, "Wrong username or password."));

$answerlist = get_answer_list_by_qid($conn, $_GET["qid"]);

for ($i = 0; $i < count($answerlist); $i++) {
    $student = get_student_by_id($conn, $answerlist[$i]["sid"]);
    $question = get_question_by_qid($conn, $answerlist[$i]["qid"]);
    $answerlist[$i]["student"] = $student;
    $answerlist[$i]["question"] = $question;
    unset($answerlist[$i]["sid"]);
    unset($answerlist[$i]["qid"]);
}

echo encode_result(0, $answerlist);

close_db($conn);

?>
