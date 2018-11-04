<?php

require 'config.php';
require 'utils.php';

$conn = connect_db($dbhost, $dbuser, $dbpass, $dbname);

$user_info = validate_user($conn, $_GET["username"], $_GET["password"], $_GET["type"]);

if ($user_info != null)
    echo encode_result(0, $user_info);
else
    echo encode_result(1, "Wrong username or password.");

close_db($conn);

?>    
