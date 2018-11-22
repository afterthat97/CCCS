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

$absent_count = 0;
$leave_early_count = 0;
$lid = $latest_lesson["lid"];
$selection_records = get_selection_records_by_cid($conn, $_GET["cid"]);
$questionlist = get_question_list_by_lid($conn, $lid);

for ($i = 0; $i < count($selection_records); $i++) {
    $sid = $selection_records[$i]["sid"];
    if (!get_checkin_record($conn, $sid, $lid)) {
        $absent_count++;
        new_checkin_record($conn, $sid, $lid, null, "Absent");
    }
    for ($j = 0; $j < count($questionlist); $j++) {
        $qid = $questionlist[$j]["qid"];
        $answer = get_answer_by_sid_and_qid($conn, $sid, $qid);
        if (!$answer || get_time_diff($conn, $answer["submit_time"], $questionlist[$j]["raised_time"]) > 300) {
            $leave_early_count++;
            $checkin_record = get_checkin_record($conn, $sid, $lid);
            if ($checkin_record["status"] == "Normal")
                update_checkin_record($conn, $sid, $lid, "Leave Early");
            break;
        }
    }
}

if (end_lesson($conn, $latest_lesson["lid"]))
    echo encode_result(0, "Lesson is over, $absent_count student(s) absent, $leave_early_count student(s) leaving early.");
else
    echo encode_result(1, "Failed to stop lesson.");

close_db($conn);

?>
