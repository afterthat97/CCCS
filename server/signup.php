<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

if (exist_user($conn, $_GET["username"], $_GET["type"]))
    die(encode_result(1, "Registration failed: username already exists."));

if (new_user($conn, $_GET["username"], $_GET["password"], $_GET["type"], $_GET["gender"], $_GET["realname"]))
    echo encode_result(0, "You have registered succussfully!");
else
    echo encode_result(1, "Registration failed: invalid syntax.");

close_db($conn);

?>
 