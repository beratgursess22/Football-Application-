⚽ Football School Management App ⚽

📌 Project Overview

This project was developed during my 30-day internship to build a Football School Management System using Flutter (frontend), Node.js + Express (backend), and MySQL (database). The system was designed to provide a digital solution for managing football teams, players, coaches, and training schedules.

🚀 Features Implemented

1- Authentication#

Login system with role-based navigation (Coach, Player, Parent).
Register page to create new users with assigned roles.
JWT-based authentication connected to Node.js backend.

<img width="413" height="866" alt="Screenshot 2025-09-02 at 11 23 19" src="https://github.com/user-attachments/assets/0e750d32-4fd8-485e-8c64-6fa7e154bbc2" />

2- Player Management#

Add, update, delete, and view players.
Each player record stores details such as: name, surname, birthday, position, dominant foot, height, weight, phone number, jersey number, medical notes, avatar URL, and status.
Players are linked to their respective teams using foreign key relations.

<img width="374" height="793" alt="Screenshot 2025-09-02 at 11 34 14" src="https://github.com/user-attachments/assets/fd71b3ba-d64e-43e3-b1d2-15e8a7483a4f" />
<img width="398" height="808" alt="Screenshot 2025-09-02 at 11 33 48" src="https://github.com/user-attachments/assets/bdce44f2-642e-4ae8-a153-e8109a5ed8c9" />

3- Team Management#

Add/Delete Team Page created with a modern, responsive UI.
Coaches can create new teams with validation and delete teams safely via confirmation dialogs.
Teams are displayed in a structured and accessible format.

<img width="384" height="807" alt="Screenshot 2025-09-02 at 11 24 03" src="https://github.com/user-attachments/assets/e8e67236-ecf3-450b-95b6-b4958d6e0d70" />

4- Calendar Module#

Coaches can create, update, and delete training sessions or events.
Each event stores title, description, location, start & end dates, and links to the coach or players.
Calendar UI includes:
Date picker to browse events.
Bottom sheet form for event creation/editing.
Confirmation dialog for event deletion.
Loading, error, and empty states for better UX.
State managed with Provider + Controller + Service layers.

<img width="397" height="793" alt="Screenshot 2025-09-02 at 11 24 34" src="https://github.com/user-attachments/assets/1f24d671-3894-4e7f-a0a2-fe1219ea94e5" />
<img width="414" height="838" alt="Screenshot 2025-09-02 at 11 24 42" src="https://github.com/user-attachments/assets/9a32fa65-f0ed-4f24-a243-de036e6074e8" />


5- Coach Dashboard (CoachPage)

Central page for coaches with navigation to:
Add Player
Add User
Assign Player to Team
Create Team
Calendar
Performance Analysis (placeholder for future work)
Gradient background, glass-effect cards, and responsive layout for a professional look.


<img width="405" height="863" alt="Screenshot 2025-09-02 at 11 23 44" src="https://github.com/user-attachments/assets/6a71d7ee-a868-4ad5-9630-87bf6c57f66f" />



🛠️ Tech Stack

📲 Frontend (Mobile App)#

Flutter (Dart)
Provider for state management
Material Design UI components
Custom UI/UX with gradient backgrounds, glassmorphism, responsive grids

🌐 Backend#

Node.js + Express
RESTful API with structured routes and controllers
Authentication with JWT
CORS enabled for secure cross-origin requests

🗄️ Database#

MySQL with normalized tables:
users (system users)
roles (coach, player, parent)
teams (team info)
players (player details)
calendar_events (coach and player events)

📂 Project Architecture (Flutter)#

1- models/ → Defines entities (UserModel, PlayerModel, TeamModel, CalendarModel).
2- services/ → Handles HTTP requests (AuthService, PlayerService, TeamService, CalendarService).
3- providers/ → Manages app-wide state and notifies UI of changes.
4- controllers/ → Bridges UI and providers/services, handles logic.
5- pages/ → UI pages (LoginPage, CoachPage, AddPlayerPage, AddTeamPage, CalendarPage, etc.).
