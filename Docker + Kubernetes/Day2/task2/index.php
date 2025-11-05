<?php
$user = trim(file_get_contents('/run/secrets/db_user'));
$pass = trim(file_get_contents('/run/secrets/db_password'));
$host = 'db';
$dbname = 'myapp';

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die("<h1>Connection failed: " . $conn->connect_error . "</h1>");
}
echo "<h1>Database connection started.</h1>";
$sql = "SELECT NOW() AS c_time";
$result = $conn->query($sql);

if (!$result) {
    die("<h1>Query error: " . $conn->error . "</h1>");
}

$row = $result->fetch_assoc();

echo "<h1>Connected successfully to MySQL!</h1>";
echo "<h2>Current MySQL Time: " . $row['c_time'] . "</h2>";

$conn->close();
?>
