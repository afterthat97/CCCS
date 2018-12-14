<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

if ($_GET["type"] == "Teacher"){
    if($_GET["new_realname"] != NULL && $_GET["new_password"] != NULL){
        if (update_teacher_realname($conn, $_GET["new_realname"], $user_info["tid"])&&update_teacher_password($conn, $_GET["new_password"], $user_info["tid"]))
        echo encode_result(0, "Realname and Password have been updated.");
        else
        echo encode_result(1, "Invalid syntax.");
    }
    if($_GET["new_password"] != NULL && $_GET["new_realname"] == NULL){
        if (update_teacher_password($conn, $_GET["new_password"], $user_info["tid"]))
        echo encode_result(0, "Password has been updated.");
        else
        echo encode_result(1, "Invalid syntax.");
    }
    if($_GET["new_password"] == NULL && $_GET["new_realname"] != NULL){
        if (update_teacher_realname($conn, $_GET["new_realname"], $user_info["tid"]))
        echo encode_result(0, "Realname has been updated.");
        else
        echo encode_result(1, "Invalid syntax.");
    }
}

if ($_GET["type"] == "Student"){
    if($_GET["new_realname"] != NULL && $_GET["new_password"] != NULL){
        if (update_student_realname($conn, $_GET["new_realname"], $user_info["sid"])&&update_student_password($conn, $_GET["new_password"], $user_info["sid"]))
        echo encode_result(0, "Realname and Password have been updated.");
        else
        echo encode_result(1, "Invalid syntax.");
    }
    if($_GET["new_password"] != NULL && $_GET["new_realname"] == NULL){
        if (update_student_password($conn, $_GET["new_password"], $user_info["sid"]))
        echo encode_result(0, "Password has been updated.");
        else
        echo encode_result(1, "Invalid syntax.");
    }
    if($_GET["new_password"] == NULL && $_GET["new_realname"] != NULL){
        if (update_student_realname($conn, $_GET["new_realname"], $user_info["sid"]))
        echo encode_result(0, "Realname has been updated.");
        else
        echo encode_result(1, "Invalid syntax.");
    }
}



close_db($conn);

?>