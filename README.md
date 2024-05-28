This is a simple PHP-based web application for uploading, managing, and selecting MP4 files. It provides functionalities to upload MP4 files, select a file as the active file, show the selected video on the HDMI screen, and delete files from the server. The application also displays notifications for actions performed and ensures an enhanced user experience with a loading spinner and disappearing alerts.

## Features

- Upload MP4 files
- Select a file as the active file
- Show the selected video on the HDMI screen
- Delete files from the server
- Display notifications for upload, select, and delete actions
- Show a loading spinner during form submission
- File selection displays the selected file name
- Alerts disappear automatically after 5 seconds

## Installation

1. **Clone the Repo:**

   ```sh
   git clone https://github.com/your-username/mp4-file-upload-management.git
   cd mp4-file-upload-management

2. **Set Up the Environment:**

   Ensure you have a PHP server running. You can use XAMPP, WAMP, MAMP, or any other local PHP server. Place the project folder in your server's root directory (e.g., `htdocs` for XAMPP).

3. **Create Required Directories:**

   Make sure the `uploads` directory exists and is writable by the web server:

   ```sh
   mkdir uploads
   chmod 777 uploads
   ```

4. **Run the Application:**

   Open the project in your web browser by navigating to `http://localhost/mp4-file-upload-management` (or the appropriate URL based on your server configuration).

## Usage

- **Upload a File:** Click on the "Choose file" button to select an MP4 file and then click "Upload MP4".
- **Select a File:** Click on the "Select" button next to the file you want to set as the active file. The selected video will automatically be displayed on the HDMI screen.
- **Delete a File:** Click on the "Delete" button next to the file you want to remove.

## Displaying Video on HDMI Screen

When a file is selected, the application will show the selected video on the HDMI screen connected to your device. This ensures that the currently active video is always visible on your display.

## Screenshots

![Upload and Management Interface](screenshots/screenshot1.png)
*Figure 1: Initial interface for uploading and managing MP4 files.*

![Notification](screenshots/screenshot2.png)
*Figure 2: Notification after an action is performed.*

## Contributing

Contributions are welcome! Please fork the repository and use a feature branch. Pull requests should be submitted to the `main` branch.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

### Additional Instructions:

- **Screenshots**: Add relevant screenshots in a `screenshots` directory to showcase the application's interface and features. Adjust the paths and file names as needed.
- **GitHub Repository**: Replace `https://github.com/your-username/mp4-file-upload-management.git` with the actual URL of your GitHub repository.

By adding the "Displaying Video on HDMI Screen" section, users will understand that the selected video will be shown on the HDMI-connected screen, enhancing the application's usability feature set. Ensure all paths and URLs match your specific project setup before finalizing the `README.md`.
