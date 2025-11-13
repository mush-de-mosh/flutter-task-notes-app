# STD NAME: MUSHABE MOSES
# STD REGNO: 23/U/12131/EVE
# STD NO: 2300712131

# Task Notes Manager

A Flutter mobile application for managing tasks and notes with persistent data storage and theme customization.

# App Description

Task Notes Manager is a comprehensive task management app that allows users to:
 Create, view, and delete tasks with priority levels
 Store tasks persistently using SQLite database
 Toggle between light and dark themes
 Navigate between multiple screens with intuitive UI
 Manage task details including title, description, and priority

# Features

- Task Management: Add new tasks with title, description, and priority (Low/Medium/High)
- Data Persistence: SQLite database for reliable local storage
- Theme Toggle: Switch between light and dark themes with persistent preference
- CRUD Operations: Create, Read, and Delete tasks
- Dynamic UI: Real-time task count and list updates
- Form Validation: Input validation for task creation

# How to Run the Project

# Prerequisites
- Flutter SDK installed
- Android Studio or VS Code with Flutter extensions
- Android emulator or physical device

 Setup Instructions

1. Clone the repository
   bash
   git clone <repository-url>
   cd task_notes_manager
   

2. Install dependencies
bash
   flutter pub get
  

3. Run the application
   bash
   flutter run
   

# For Android Device
bash
flutter run -d <device-id>

# For Android Emulator
bash
flutter emulators --launch <emulator-name>
flutter run


# Dependencies

 flutter: SDK
 sqflite: SQLite database
 shared_preferences: Theme preference storage
cupertino_icons: iOS-style icons

#Project Structure


lib/
  main.dart                 # Main app entry point
  models/
   task_item.dart       # TaskItem data model
 services/
    database_helper.dart  # SQLite database operations
    theme_service.dart    # Theme preference management

