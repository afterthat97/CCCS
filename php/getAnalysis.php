<?php
    $dbhost = 'localhost:3306';
    $dbuser = 'root';
    $dbpass = 'breeze320681';
    $conn = mysqli_connect($dbhost, $dbuser, $dbpass);
    if (!$conn) {
        echo '{ "code" : 1, "info" : "Failed to connect to database." }';
        die('');
    }
    mysqli_select_db($conn, 'cccs');
    
    
    $tid = $_GET["tid"];
    $cid = $_GET["cid"];
    $qid = $_GET["qid"];
    
    $sql_query = "select count(sid)  from Answer where qid = '$qid' and cid = '$cid'";
    
    $sql_query2 = "select count(sid)  from Answer a,Question q where a.qid = '$qid' and a.cid = '$cid' and a.cid=q.cid and a.qid=q.qid and Choose=correct";
    
    $retvalfirst = mysqli_query( $conn, $sql_query );
    $retvalsecond = mysqli_query( $conn, $sql_query2 );
 
    
    $results = array();
    while ($row = mysqli_fetch_array($retvalfirst, MYSQLI_ASSOC))
    array_push($results, $row);
    while ($row = mysqli_fetch_array($retvalsecond, MYSQLI_ASSOC))
    array_push($results, $row);
    
    if ($results) {
        echo json_encode($results);
    }
    
    mysqli_close($conn);
?>
