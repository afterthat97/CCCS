<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

if ($_GET["type"] != "Teacher")
    die(encode_result(1, "Permission denied."));

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

if (!isset($_GET["option2"]))
    $_GET["option2"] = "";
if (!isset($_GET["option3"]))
    $_GET["option3"] = "";

if (new_question($conn, $_GET["lid"], $_GET["description"], $_GET["option0"], $_GET["option1"], $_GET["option2"], $_GET["option3"], $_GET["answer"]))
    echo encode_result(0, "Question raised.");
else
    echo encode_result(1, "Invalid syntax.");

close_db($conn);

?>
