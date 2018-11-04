<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info == null)
    die(encode_result(1, "Wrong username or password."));

$lessonlist = get_lessonlist_by_cid($conn, $_GET["cid"]);

echo encode_result(0, $lessonlist);

close_db($conn);

?>
