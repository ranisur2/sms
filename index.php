<?php
require_once 'config/db.php';
require_once 'config/function.php';

$page = isset($_GET['page']) ? $_GET['page'] : 'dashboard';
$action = isset($_GET['action']) ? $_GET['action'] : 'list';

// 1. Handle Login Logic (Bypass layout)
if ($page === 'login') { include 'modules/login.php'; exit(); }
if ($page === 'logout') { include 'modules/logout.php'; exit(); }
if ($page === 'forgot_password') { include 'modules/forgot_password.php'; exit(); }

// 2. Enforce Authentication
checkAuth();

// 3. Page & Action Level Permissions
$restrictedPages = [
    'settings'   => 'school_admin',
    'institutes' => 'super_admin', // Only super_admin manages institutes
    'logs'       => 'school_admin'
];

// Check page access
if (isset($restrictedPages[$page]) && !hasPermission($restrictedPages[$page])) {
    $_SESSION['msg'] = "Unauthorized access to $page.";
    header("Location: index.php?page=dashboard");
    exit();
}

// Check sensitive actions (e.g., deleting a student)
if ($action === 'delete' && !hasPermission('school_admin')) {
    die("Security Error: You do not have permission to delete records.");
}


$modulePath = "modules/$page/index.php";
if (file_exists($modulePath)) {
    include $modulePath;
} else {
    echo "<center><div class='container mt-5'><h1>404</h1><p>Module not found.</p></div></center>";
}

include 'views/layout/footer.php';
?>
