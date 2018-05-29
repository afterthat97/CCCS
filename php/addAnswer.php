<?php
    $dbhost = 'localhost:3306';
    $dbuser = 'root';
    $dbpass = 'breeze320681';
    $conn = mysqli_connect($dbhost, $dbuser, $dbpass);
    if (!$conn) {
        echo '{ "code":1, "info" : "Failed to connect to database." }';
        die('');
    }
    mysqli_select_db($conn, 'cccs');
    
    if (isset($_GET["sid"])) {
        $sid = $_GET["sid"];
        $cid = $_GET["cid"];
        $qid = $_GET["qid"];
        $Choose = $_GET["Choose"];
        
        $sql_check = "select * from Answer where cid='$cid' and qid='$qid' and sid='$sid'";
        $retval = mysqli_query( $conn, $sql_check);
            if ($row = mysqli_fetch_array($retval, MYSQLI_ASSOC)) {
                echo '{ "code" : 1, "info" : "You have already answered." }';
            }else{
                $sql = "INSERT INTO Answer".
                "(sid, cid, qid, Choose)".
                "VALUES".
                "('$sid', '$cid', '$qid', '$Choose')";
                mysqli_query( $conn, $sql );
                echo '{ "code" : 0, "info" : "Answer success." }';
              
            }
        
        
    }
    mysqli_close($conn);
?>
