<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

if (isset($_GET["cid"]))
    $questionlist = get_question_list_by_cid($conn, $_GET["cid"]);
else if (isset($_GET["lid"]))
    $questionlist = get_question_list_by_lid($conn, $_GET["lid"]);
else
    die(encode_result(1, "Invalid syntax."));

echo encode_result(0, $questionlist);

close_db($conn);

?>
