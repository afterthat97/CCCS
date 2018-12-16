<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

if($_GET["searchway"] == 0 ){
    $questionlist = get_question_list_by_lid($conn, $_GET["lid"]);
    echo encode_result(0, $questionlist);
}
else{
    $current_course = get_cid_by_lid($conn, $_GET["lid"]);
    $lessonlist = get_lessonlist_by_cid($conn, $current_course["cid"]);
    $questionlist = array();
    foreach($lessonlist as $lesson){
        $subquestionlist = get_question_list_by_lid($conn, $lesson["lid"]);
        foreach($subquestionlist as $question){
            array_push($questionlist, $question);
        }
    }
    echo encode_result(0,$questionlist);
}

close_db($conn);

?>
