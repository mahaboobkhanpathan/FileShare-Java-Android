# FileShare - Desktop LAN File Sharing Application

A professional, high-performance client-server desktop application developed in Java (Java 17+) for sharing files between computers across a Local Area Network (Wi-Fi/LAN).

Designed as an exemplary **college-level Java project**, FileShare demonstrates clean architecture, object-oriented principles, multithreaded socket programming, chunked binary streaming, SQLite database integration with JDBC, and modern Java Swing GUIs.

---

## 1. Features

### Server Dashboard (`server.ServerGUI`)
* **One-Click Lifecycle Management**: Start and Stop Server on customizable ports (default: `5000`).
* **LAN IP Auto-Detection**: Displays the host computer's active LAN IPv4 address (`192.168.x.x` or `10.x.x.x`) for easy client connections.
* **Connected Clients Monitor**: Live `JTable` tracking client ID, username, remote IP, port, connected time, and current activity.
* **Shared Storage Manager**: Explore files stored in `shared/`, delete files, or open the folder directly in the system file explorer.
* **Real-Time Transfer & Activity Log**: Timestamped, auto-scrolling log with a "Clear Log" button.
* **Transfer History Viewer**: View all past uploads and downloads recorded in the SQLite database.
* **Event Push Architecture**: Broadcasts instant push notifications to all connected clients when files are added or deleted.

### Client Dashboard (`client.ClientGUI` / `client.DashboardFrame`)
* **Network Connection Bar**: Connect to any server using IP Address and Port with instant status badges (`ONLINE` / `OFFLINE`).
* **User Authentication**:
  * **Login Window (`LoginFrame`)**: Secure user authentication.
  * **Registration Window (`RegisterFrame`)**: Account creation with input validation.
  * **Session Management**: Visual user badges and sign-out controls.
* **Available Files Explorer**:
  * Real-time listing of files available on the server with filename, formatted size (B, KB, MB, GB), file type detection, and upload date.
  * Instant Search/Filter box for quickly locating files.
  * Refresh button (and automated background synchronization via server push events).
* **Chunked File Upload**:
  * `JFileChooser` to upload any file type (PDF, DOCX, TXT, JPG, PNG, MP3, MP4, ZIP, Java files, binary files).
  * Non-blocking background worker (`FileUploader` using `SwingWorker`).
* **Chunked File Download**:
  * Download files directly to chosen destination.
  * Download Location Selector with folder picker (defaults to `downloads/`).
  * Non-blocking background worker (`FileDownloader`).
* **Transfer Metrics & Progress**:
  * Live `JProgressBar` showing percentage, bytes transferred, total size, and transfer speed in MB/s.
  * Live status indicator ("Uploading...", "Downloading...", "Completed in 3.2s").
* **Transfer History Tab**:
  * User transfer logs retrieved from the server's SQLite database.

---

## 2. Architecture & Design

```text
                             FILESHARE SERVER
                        (ServerSocket on Port 5000)
                                     |
               ┌─────────────────────┼─────────────────────┐
               │                     │                     │
         ClientHandler         ClientHandler         ClientHandler
            Thread 1              Thread 2              Thread 3
               │                     │                     │
          Client 1 (Alice)      Client 2 (Bob)        Client 3 (Carol)
```

### Communication Protocol
Commands and responses are transmitted cleanly over TCP sockets using `DataInputStream` and `DataOutputStream`:

| Command | Direction | Parameters | Description |
| :--- | :--- | :--- | :--- |
| `LOGIN` | Client -> Server | `username`, `password` | Authenticate existing user |
| `REGISTER` | Client -> Server | `username`, `password` | Register new user account |
| `LIST_FILES` | Client -> Server | *(none)* | Fetch list of files in `shared/` |
| `UPLOAD` | Client -> Server | `filename`, `fileSize` | Upload binary stream in 64KB chunks |
| `DOWNLOAD` | Client -> Server | `filename` | Download binary stream in 64KB chunks |
| `DELETE` | Client -> Server | `filename` | Delete file from server storage |
| `GET_HISTORY` | Client -> Server | *(none)* | Query transfer records from SQLite |
| `SUBSCRIBE_EVENTS` | Client -> Server | *(none)* | Secondary socket listening for push events |
| `LOGOUT` | Client -> Server | *(none)* | Log out active user session |
| `DISCONNECT` | Client -> Server | *(none)* | Clean socket shutdown |

---

## 3. Core Java Concepts Demonstrated

* **Classes & Objects**: Strong encapsulation across data models (`User`, `FileInfo`, `TransferRecord`, `ClientInfo`).
* **Interfaces & Polymorphism**:
  * `ServerListener`: Implements the Observer pattern to decouple server network logic from Swing GUI presentation.
  * `ClientEventListener`: Decouples background socket event reception from UI refresh actions.
  * `ProgressCallback`: Functional interface providing real-time streaming progress to progress bars.
* **Multithreading & Concurrency**:
  * Dedicated `ClientHandler` thread per connected socket.
  * Background thread for `ServerSocket.accept()`.
  * Non-blocking `SwingWorker<Void, Long>` threads (`FileUploader`, `FileDownloader`) preventing GUI freeze.
  * Thread-safe collections (`CopyOnWriteArrayList`, `AtomicInteger`).
* **Java I/O & NIO**:
  * Buffered binary streams (`BufferedInputStream`, `BufferedOutputStream`).
  * 64 KB chunked data transfer (`byte[64 * 1024]`), preventing high memory usage even when transferring gigabyte files.
  * Safe file handling and atomic `.part` file renaming to avoid partial/corrupted files during aborted transfers.
* **Networking (Sockets)**:
  * `ServerSocket` and `Socket` programming.
  * Detection of LAN IP addresses using `NetworkInterface` and `Inet4Address`.
* **Database & JDBC**:
  * Embedded SQLite database (`database/fileshare.db`) with automatic schema creation.
  * `PreparedStatement` to prevent SQL injection.
  * Write-Ahead Logging (WAL) enabled (`PRAGMA journal_mode=WAL`) for concurrent multi-client database operations.
* **Security & Hardening**:
  * **Password Hashing**: Cryptographically secure 16-byte random salt + SHA-256 password hashing via standard `java.security.MessageDigest`.
  * **Path Traversal Protection**: Canonical path validation (`SecurityUtils.getSafeFile()`) preventing access outside `shared/` (e.g. `../../windows/system32`).
  * **LAN Validation**: Filename sanitization, authentication enforcement, and command validation.

---

## 4. Project Directory Structure

```text
FileShare/
│
├── src/
│   ├── client/
│   │   ├── Client.java               # Client network controller
│   │   ├── ClientEventListener.java  # Push notification interface
│   │   ├── ClientGUI.java            # Main client launcher
│   │   ├── DashboardFrame.java       # Primary client GUI window
│   │   ├── FileDownloader.java       # SwingWorker download background worker
│   │   ├── FileUploader.java         # SwingWorker upload background worker
│   │   ├── LoginFrame.java           # Login window
│   │   └── RegisterFrame.java        # Registration window
│   │
│   ├── server/
│   │   ├── ClientHandler.java        # Per-client multithreaded session handler
│   │   ├── ClientInfo.java           # Client session presentation model
│   │   ├── FileManager.java          # Shared folder file operations & streaming
│   │   ├── Server.java               # Main server launcher (GUI & CLI support)
│   │   ├── ServerGUI.java            # Primary server dashboard GUI
│   │   ├── ServerListener.java       # Observer interface for server events
│   │   └── ServerManager.java        # Server lifecycle & thread manager
│   │
│   ├── database/
│   │   ├── DatabaseManager.java      # SQLite connection & table auto-initialization
│   │   ├── TransferDAO.java          # Data Access Object for transfer_history
│   │   └── UserDAO.java              # Data Access Object for users & credentials
│   │
│   ├── common/
│   │   ├── FileInfo.java             # Shared file metadata model
│   │   ├── NetworkUtils.java         # LAN IP detection & byte formatting
│   │   ├── ProgressCallback.java     # Streaming progress callback interface
│   │   ├── Protocol.java             # Centralized protocol commands & constants
│   │   ├── SecurityUtils.java        # SHA-256 salted hashing & path traversal checks
│   │   ├── TransferRecord.java       # Transfer history record model
│   │   ├── UITheme.java              # Modern styling, colors, and UI component helpers
│   │   └── User.java                 # User entity model
│   │
│   └── test/
│       ├── ComprehensiveTestSuite.java # 14-point automated test suite
│       └── IntegrationTest.java        # End-to-end integration test
│
├── lib/
│   ├── sqlite-jdbc-3.45.2.0.jar      # SQLite JDBC driver
│   ├── slf4j-api-2.0.12.jar          # SLF4J logging API
│   └── slf4j-simple-2.0.12.jar       # SLF4J provider
│
├── shared/                           # Server shared files directory
├── downloads/                        # Default client download destination
├── database/                         # SQLite database storage (fileshare.db)
├── bin/                              # Compiled .class files
│
├── build.bat                         # Windows build script
├── run-server.bat                    # Windows server launcher
├── run-client.bat                    # Windows client launcher
├── run-tests.bat                     # Windows test suite runner
│
├── build.sh                          # Linux/macOS build script
├── run-server.sh                     # Linux/macOS server launcher
├── run-client.sh                     # Linux/macOS client launcher
├── run-tests.sh                      # Linux/macOS test suite runner
│
└── README.md                         # Project documentation
```

---

## 5. How to Compile and Run

### Prerequisites
* **Java Development Kit (JDK) 17 or newer** (`java -version` and `javac -version`)

### Option A: Using Provided Scripts (Recommended)

#### On Windows:
1. **Build the project**:
   ```cmd
   build.bat
   ```
2. **Start the Server**:
   ```cmd
   run-server.bat
   ```
3. **Start one or more Clients**:
   ```cmd
   run-client.bat
   ```

#### On Linux / macOS:
```bash
chmod +x *.sh
./build.sh
./run-server.sh
./run-client.sh
```

---

### Option B: Manual Compilation via Command Line

#### 1. Compile
```cmd
javac -encoding UTF-8 -cp "lib/*" -d bin src/common/*.java src/database/*.java src/server/*.java src/client/*.java src/test/*.java
```

#### 2. Run Server GUI
```cmd
java -cp "lib/*;bin" server.Server
```
*(On Linux/macOS, replace `;` with `:` in the classpath: `lib/*:bin`)*

#### 3. Run Client GUI
```cmd
java -cp "lib/*;bin" client.ClientGUI
```

#### 4. Run Server in Headless (Console) Mode:
```cmd
java -cp "lib/*;bin" server.Server --headless 5000
```

---

## 6. How to Test on LAN (Two Computers on Same Wi-Fi)

To share files between two physical computers (e.g. Laptop A and Laptop B) connected to the same Wi-Fi network:

### Step 1: Start Server on Computer A
1. Run `run-server.bat` on Computer A.
2. Note the **Server IP** shown in the dashboard (e.g., `192.168.1.15`).
3. Click **Start Server**. The status badge turns green (`RUNNING`).

> **Windows Firewall Note**: If Windows Defender Firewall prompts you when starting the server, click **"Allow access"** on Private networks so Computer B can reach port 5000.

### Step 2: Connect from Computer B
1. Copy the `FileShare` folder to Computer B (or run `run-client.bat`).
2. In the Client Dashboard connection bar at the top:
   * **Server IP**: Enter Computer A's IP (e.g., `192.168.1.15`).
   * **Port**: `5000`.
3. Click **Connect**. The status badge turns green (`ONLINE`).

### Step 3: Register, Login, and Share
1. Click **Register** on Computer B, enter a username and password, and create an account.
2. Click **Sign In** and log in.
3. Click **Upload File...** to upload files from Computer B to Computer A.
4. Computer A and all other connected computers will see the new file appear immediately.
5. On another computer, select the file and click **Download Selected**!

---

## 7. Automated Test Suite

An automated test suite (`ComprehensiveTestSuite.java`) is included to verify all 14 project requirements:

```cmd
run-tests.bat
```
or
```cmd
java -cp "lib/*;bin" test.ComprehensiveTestSuite
```

### Verified Test Cases:
1. **Server Startup**: ServerSocket initialization on target port.
2. **Client Connection**: TCP socket handshake.
3. **Registration**: Account persistence with salted hash.
4. **Login**: Password verification against SQLite.
5. **File Listing**: Retrieval of shared file metadata.
6. **File Upload**: Streaming text and binary files in chunks.
7. **File Download**: Receiving data and verifying byte integrity.
8. **Multiple Clients**: 3 simultaneous clients (Alice, Bob, Carol) performing concurrent operations.
9. **Large File Transfer**: 5 MB binary file upload and download with SHA-256 checksum verification.
10. **Invalid Login Rejection**: Rejection of bad credentials.
11. **Missing File Request**: Graceful error handling for missing files.
12. **Client Disconnect Handling**: Clean disconnection without server interruption.
13. **Server Shutdown**: Resource release and client notification.
14. **Database Operations & History**: Verified `users` and `transfer_history` tables.

---

## 8. Database Tables Schema

FileShare automatically creates the required SQLite database (`database/fileshare.db`) on first run:

### `users`
```sql
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    salt TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### `transfer_history`
```sql
CREATE TABLE IF NOT EXISTS transfer_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    file_name TEXT NOT NULL,
    operation TEXT NOT NULL, -- 'UPLOAD' or 'DOWNLOAD'
    file_size INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TEXT NOT NULL     -- 'SUCCESS', 'FAILED', 'CANCELLED'
);
```
