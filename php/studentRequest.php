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

	if (isset($_GET["sid"])) {		
		$password=$_GET["password"];
		$sid = $_GET["sid"];
		$cid = $_GET["cid"];
		$state = $_GET["state"];
		$reason = $_GET["reason"];
	
        $sql_query = "select * from Student where sid='$sid'";
        $retval = mysqli_query( $conn, $sql_query );
        $row = mysqli_fetch_array($retval, MYSQLI_ASSOC);
        if ($row['password'] == $password) {
            $sql = "INSERT INTO temp".
            "(sid,cid,state,reason)".
            "VALUES".
            "('$sid', '$cid', '$state', '$reason')";
            mysqli_query( $conn, $sql );
            echo '{ "code" : 0, "info" : "request has been added." }';
        } else {
            echo '{ "code" : 1, "info" : "Authentication failed." }';
        }
    }
    mysqli_close($conn);
?>
