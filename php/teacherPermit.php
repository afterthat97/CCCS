<?php
	$dbhost = 'localhost:3306';
	$dbuser = 'root';
	$dppass = 'breeze320681';
	$conn = mysqli_connect($dbhost, $dbuser, $dbpass);
	if (!$conn) {
		echo '{ "code":1, "info" : "Failed to connect to database." }';
		die('');
	}
    mysqli_select_db($conn, 'cccs');

	if (isset($_GET["tid"])) {
		$tid = $_GET["tid"];
		$sid = $_GET["sid"];
		$cid = $_GET["cid"];
		$password=$_GET["password"];

	
        $sql_query = "select * from Teacher where tid='$tid'";
        $retval = mysqli_query( $conn, $sql_query );
        $row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
        if ($row['password'] == $password) {
            $sql = "update temp set state='Allowed' where cid='$cid' and sid='$sid'  ";
            mysqli_query( $conn, $sql );
            echo '{ "code" : 0, "info" : "Request has been accepted." }';
        } else {
            echo '{ "code" : 1, "info" : "Authentication failed." }';
        }
    }
    mysqli_close($conn);
?>
