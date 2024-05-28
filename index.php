<?php
$message = "";
$messageClass = "";

$configFilePath = 'config.txt';
$uploadsDir = 'uploads/';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_FILES['fileToUpload'])) {
        $targetFile = $uploadsDir . basename($_FILES["fileToUpload"]["name"]);
        $fileType = strtolower(pathinfo($targetFile, PATHINFO_EXTENSION));
        
        // Check if file is an MP4
        if ($fileType == "mp4") {
            if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $targetFile)) {
                $message = "The file " . htmlspecialchars(basename($_FILES["fileToUpload"]["name"])) . " has been uploaded.";
                $messageClass = "alert-success";
            } else {
                $message = "Sorry, there was an error uploading your file.";
                $messageClass = "alert-danger";
            }
        } else {
            $message = "Only MP4 files are allowed.";
            $messageClass = "alert-danger";
        }
    } elseif (isset($_POST['selectFile'])) {
        $selectedFile = $_POST['selectFile'];
        if (file_put_contents($configFilePath, $selectedFile) !== false) {
            $message = "The file " . htmlspecialchars($selectedFile) . " has been selected.";
            $messageClass = "alert-success";
        } else {
            $message = "Failed to write to config.txt. Please check file permissions.";
            $messageClass = "alert-danger";
        }
    } elseif (isset($_POST['deleteFile'])) {
        $fileToDelete = $_POST['deleteFile'];
        $filePath = $uploadsDir . $fileToDelete;
        if (file_exists($filePath)) {
            if (unlink($filePath)) {
                if (file_exists($configFilePath) && trim(file_get_contents($configFilePath)) == $fileToDelete) {
                    file_put_contents($configFilePath, ""); // Clear the config file if the deleted file is the selected file
                }
                $message = "The file " . htmlspecialchars($fileToDelete) . " has been deleted.";
                $messageClass = "alert-success";
            } else {
                $message = "Failed to delete file. Please check file permissions.";
                $messageClass = "alert-danger";
            }
        } else {
            $message = "The file " . htmlspecialchars($fileToDelete) . " does not exist.";
            $messageClass = "alert-danger";
        }
    }
}

if (file_exists($configFilePath)) {
    $selectedFile = trim(file_get_contents($configFilePath));
}

$files = array_diff(scandir($uploadsDir), array('.', '..'));
?>

<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <style>
        body {
            background-image: url('images/background.png');
            background-size: cover;
            background-repeat: no-repeat;
            background-attachment: fixed;
            font-family: 'Arial', sans-serif;
        }
        .container {
            margin-top: 50px;
            padding: 20px;
            background-color: rgba(255, 255, 255, 0.8);
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h2 {
            color: #007bff;
        }
        .form-group label {
            color: #495057;
        }
        .btn-primary {
            background-color: #007bff;
            border-color: #007bff;
        }
        .btn-primary:hover {
            background-color: #0056b3;
            border-color: #0056b3;
        }
        .btn-danger {
            background-color: #dc3545;
            border-color: #dc3545;
        }
        .btn-danger:hover {
            background-color: #c82333;
            border-color: #bd2130;
        }
        .alert {
            display: block; /* Always display alerts as block */
        }
        .logo {
            max-width: 200px;
            display: block;
            margin: 0 auto 20px auto;
        }
        .file-list {
            list-style-type: none;
            padding: 0;
        }
        .file-list-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px;
            border: 1px solid #ddd;
            margin-bottom: 10px;
            background-color: #f9f9f9;
            border-radius: 5px;
        }
        .file-list-item.selected {
            background-color: #e9ecef;
        }
        .file-upload-wrapper {
            position: relative;
            width: 100%;
            text-align: center;
        }
        .file-upload {
            position: absolute;
            top: 0;
            left: 0;
            opacity: 0;
            font-size: 100px;
            width: 100%;
            height: 100%;
            cursor: pointer;
        }
        .upload-btn {
            display: inline-block;
            padding: 10px 20px;
            border-radius: 5px;
            background-color: #007bff;
            color: #fff;
            cursor: pointer;
        }
        .upload-btn:hover {
            background-color: #0056b3;
        }
        .spinner {
            display: none;
            margin-top: 20px;
        }
        .spinner-border {
            color: #007bff;
        }
    </style>
</head>
<body>

<div class="container text-center">
    <img src="images/logo.png" alt="Logo" class="logo">
    <h2 class="mb-3">MP4 File Upload and Management</h2>
    <?php if ($message): ?>
        <div class="alert <?= $messageClass ?>"><?= $message ?></div>
    <?php endif; ?>

    <!-- Upload Form -->
    <form method="post" enctype="multipart/form-data" class="upload-form">
        <div class="form-group file-upload-wrapper">
            <span class="upload-btn">Choose file</span>
            <input type="file" class="file-upload" name="fileToUpload" id="fileToUpload" required accept=".mp4">
        </div>
        <button type="submit" class="btn btn-primary upload-button">Upload MP4</button>
        <div class="spinner mt-3">
            <div class="spinner-border" role="status">
                <span class="sr-only">Loading...</span>
            </div>
        </div>
    </form>

    <hr>

    <!-- File Management -->
    <div class="mb-3">
        <?php if (!empty($selectedFile)): ?>
            <p class="font-weight-bold">Selected File: <?= htmlspecialchars($selectedFile) ?></p>
        <?php else: ?>
            <p class="font-italic">No file selected</p>
        <?php endif; ?>
    </div>

    <ul class="file-list">
        <?php foreach ($files as $file): ?>
            <li class="file-list-item <?= (isset($selectedFile) && $selectedFile == $file) ? 'selected' : '' ?>">
                <span><?= $file ?></span>
                <div>
                    <form method="post" class="select-file-form" style="display:inline">
                        <input type="hidden" name="selectFile" value="<?= $file ?>">
                        <button type="submit" class="btn btn-primary btn-sm select-button">Select</button>
                    </form>
                    <form method="post" class="delete-file-form" style="display:inline">
                        <input type="hidden" name="deleteFile" value="<?= $file ?>">
                        <button type="submit" class="btn btn-danger btn-sm delete-button">Delete</button>
                    </form>
                </div>
            </li>
        <?php endforeach; ?>
    </ul>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.1/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
$(document).ready(function(){
    // Display the selected file name
    $('.file-upload').on('change', function() {
        var filename = $(this).val().split('\\').pop();
        $('.upload-btn').text(filename);
    });

    // Show spinner during form submission
    $('.upload-form').on('submit', function() {
        $('.spinner').show();
        $('.upload-button').prop('disabled', true);
    });

    $('.select-file-form, .delete-file-form').on('submit', function() {
        $('.spinner').show();
        $('.select-button, .delete-button').prop('disabled', true);
    });
});
</script>

</body>
</html>
