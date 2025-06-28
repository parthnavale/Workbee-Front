# WorkBee App - UML Diagrams Documentation

## Table of Contents
1. [Class Diagram](#class-diagram)
2. [Use Case Diagram](#use-case-diagram)
3. [Sequence Diagram](#sequence-diagram)
4. [State Diagram](#state-diagram)
5. [Component Diagram](#component-diagram)
6. [Activity Diagram](#activity-diagram)

---

## Class Diagram

```mermaid
classDiagram
    %% Main App Classes
    class MyApp {
        +build(BuildContext) Widget
    }
    
    class HomeScreen {
        +build(BuildContext) Widget
    }
    
    class LoginScreen {
        -_controller: AnimationController
        -_opacity: Animation
        -_slide: Animation
        +initState()
        +dispose()
        -_handleNavigation(String)
        +build(BuildContext) Widget
    }
    
    class SignInScreen {
        -_formKey: GlobalKey
        -_emailController: TextEditingController
        -_passwordController: TextEditingController
        -_isPasswordVisible: bool
        -_selectedRole: UserRole?
        +dispose()
        -_signIn()
        +build(BuildContext) Widget
    }
    
    class DashboardScreen {
        -_handleNavigation(String, BuildContext)
        +build(BuildContext) Widget
        -_buildStatCard(String, String, IconData) Widget
    }
    
    class PosterHomeScreen {
        +build(BuildContext) Widget
    }
    
    class SeekerHomeScreen {
        +build(BuildContext) Widget
    }
    
    class AddJobScreen {
        -_formKey: GlobalKey
        -_title: String
        -_description: String
        -_location: String
        -_saveJob()
        +build(BuildContext) Widget
    }
    
    %% Widget Components
    class AppHeader {
        +onNavigation: Function(String)
        +preferredSize: Size
        +build(BuildContext) Widget
    }
    
    class AnimatedJobCard {
        +job: Job
        +onTap: VoidCallback?
        +index: int
        -_controller: AnimationController
        -_opacity: Animation
        -_offset: Animation
        +initState()
        +dispose()
        +build(BuildContext) Widget
    }
    
    class AnimatedScaleButton {
        +child: Widget
        +onTap: VoidCallback
        +backgroundColor: Color?
        +foregroundColor: Color?
        +minimumSize: Size?
        +icon: IconData?
        +borderColor: Color?
        +borderWidth: double?
        -_controller: AnimationController
        -_scale: Animation
        +initState()
        +build(BuildContext) Widget
    }
    
    class FadePageRoute {
        +page: Widget
        +pageBuilder()
        +transitionsBuilder()
    }
    
    %% Models
    class Job {
        +String id
        +String businessId
        +String businessName
        +String title
        +String description
        +List~String~ requiredSkills
        +String location
        +String address
        +String state
        +String city
        +String pinCode
        +double hourlyRate
        +int estimatedHours
        +DateTime postedDate
        +DateTime? startDate
        +JobStatus status
        +List~JobApplication~ applications
        +String contactPerson
        +String contactPhone
        +String contactEmail
        +copyWith()
        +toJson()
        +fromJson()
    }
    
    class JobApplication {
        +String id
        +String jobId
        +String workerId
        +String workerName
        +String workerEmail
        +String workerPhone
        +List~String~ workerSkills
        +int yearsOfExperience
        +String previousWorkExperience
        +ApplicationStatus status
        +DateTime appliedDate
        +DateTime? respondedDate
        +String? message
        +copyWith()
        +toJson()
        +fromJson()
    }
    
    %% Enums
    class UserRole {
        <<enumeration>>
        poster
        seeker
    }
    
    %% Providers
    class JobProvider {
        -List~Job~ _jobs
        -List~JobApplication~ _myApplications
        -List~Job~ _myPostedJobs
        +List~Job~ jobs
        +List~JobApplication~ myApplications
        +List~Job~ myPostedJobs
        +List~Job~ openJobs
        +List~Job~ jobsWithPendingApplications
        +postJob(Job job)
        +applyForJob(JobApplication application)
        +respondToApplication(String jobId, String applicationId, ApplicationStatus status)
        +updateJobStatus(String jobId, JobStatus status)
        +getJobById(String jobId)
        +getMyApplicationForJob(String jobId)
        +hasAppliedForJob(String jobId)
        +getPendingApplicationsCount()
        +loadJobs()
        +clearData()
    }
    
    class AuthProvider {
        -bool _isLoggedIn
        -String? _userName
        -UserRole? _userRole
        +bool isLoggedIn
        +String? userName
        +UserRole? userRole
        +login(String email, String password, UserRole role)
        +logout()
        +register(String email, String password, UserRole role)
    }
    
    class ThemeProvider {
        -bool _isDarkMode
        +bool isDarkMode
        +toggleTheme()
    }
    
    class JobStatus {
        <<enumeration>>
        open
        inProgress
        completed
        cancelled
    }
    
    class ApplicationStatus {
        <<enumeration>>
        pending
        accepted
        rejected
    }
    
    %% Relationships
    MyApp --> HomeScreen
    HomeScreen --> LoginScreen
    HomeScreen --> DashboardScreen
    LoginScreen --> SignInScreen
    LoginScreen --> PosterHomeScreen
    LoginScreen --> SeekerHomeScreen
    LoginScreen --> AppHeader
    DashboardScreen --> AppHeader
    DashboardScreen --> PosterHomeScreen
    DashboardScreen --> SeekerHomeScreen
    PosterHomeScreen --> AddJobScreen
    PosterHomeScreen --> AnimatedJobCard
    SeekerHomeScreen --> AnimatedJobCard
    LoginScreen --> AnimatedScaleButton
    SignInScreen --> AnimatedScaleButton
    DashboardScreen --> AnimatedScaleButton
    AddJobScreen --> JobProvider
    PosterHomeScreen --> JobProvider
    SeekerHomeScreen --> JobProvider
    SignInScreen --> AuthProvider
    DashboardScreen --> AuthProvider
    DashboardScreen --> JobProvider
    LoginScreen --> FadePageRoute
    SignInScreen --> FadePageRoute
    DashboardScreen --> FadePageRoute
    JobProvider --> Job
    JobProvider --> JobApplication
    AuthProvider --> UserRole
    Job --> JobStatus
    JobApplication --> ApplicationStatus
    ThemeProvider --> JobProvider
```

---

## Use Case Diagram

```mermaid
graph TB
    subgraph "WorkBee App Use Cases"
        subgraph "Authentication"
            UC1[Sign In]
            UC2[Sign Out]
            UC3[Select Role]
        end
        
        subgraph "Business Owner"
            UC4[Post Job]
            UC5[Manage Jobs]
            UC6[View Job Applications]
            UC7[Edit Job Details]
        end
        
        subgraph "Worker"
            UC8[Browse Jobs]
            UC9[Apply for Job]
            UC10[View Job Details]
            UC11[Track Applications]
        end
        
        subgraph "General"
            UC12[View Dashboard]
            UC13[Navigate App]
            UC14[View Statistics]
        end
    end
    
    subgraph "Actors"
        A1[Business Owner]
        A2[Worker]
        A3[Guest User]
    end
    
    %% Business Owner Use Cases
    A1 --> UC1
    A1 --> UC2
    A1 --> UC3
    A1 --> UC4
    A1 --> UC5
    A1 --> UC6
    A1 --> UC7
    A1 --> UC12
    A1 --> UC13
    A1 --> UC14
    
    %% Worker Use Cases
    A2 --> UC1
    A2 --> UC2
    A2 --> UC3
    A2 --> UC8
    A2 --> UC9
    A2 --> UC10
    A2 --> UC11
    A2 --> UC12
    A2 --> UC13
    A2 --> UC14
    
    %% Guest User Use Cases
    A3 --> UC1
    A3 --> UC3
    A3 --> UC13
```

---

## Sequence Diagram

```mermaid
sequenceDiagram
    participant User
    participant HomeScreen
    participant AuthProvider
    participant LoginScreen
    participant SignInScreen
    participant DashboardScreen
    participant JobProvider
    
    %% Initial App Launch
    User->>HomeScreen: Launch App
    HomeScreen->>AuthProvider: Check Login Status
    AuthProvider-->>HomeScreen: Not Logged In
    HomeScreen-->>User: Show LoginScreen
    
    %% Sign In Process
    User->>LoginScreen: Click "Sign In"
    LoginScreen->>SignInScreen: Navigate
    User->>SignInScreen: Select Role (Business Owner/Worker)
    User->>SignInScreen: Enter Email & Password
    User->>SignInScreen: Click "Sign In"
    SignInScreen->>AuthProvider: loginAsBusinessOwner/loginAsWorker
    AuthProvider->>AuthProvider: Update State
    SignInScreen->>DashboardScreen: Navigate
    DashboardScreen->>JobProvider: Get Jobs
    JobProvider-->>DashboardScreen: Job List
    DashboardScreen-->>User: Show Dashboard
    
    %% Job Management (Business Owner)
    User->>DashboardScreen: Click "Manage Jobs"
    DashboardScreen->>PosterHomeScreen: Navigate
    PosterHomeScreen->>JobProvider: Get Posted Jobs
    JobProvider-->>PosterHomeScreen: Job List
    PosterHomeScreen-->>User: Show Posted Jobs
    
    User->>PosterHomeScreen: Click "Add Job"
    PosterHomeScreen->>AddJobScreen: Navigate
    User->>AddJobScreen: Fill Job Details
    User->>AddJobScreen: Submit Job
    AddJobScreen->>JobProvider: addJob()
    JobProvider->>JobProvider: Update Jobs List
    AddJobScreen-->>PosterHomeScreen: Navigate Back
    
    %% Job Search (Worker)
    User->>DashboardScreen: Click "Find Jobs"
    DashboardScreen->>SeekerHomeScreen: Navigate
    SeekerHomeScreen->>JobProvider: Get Available Jobs
    JobProvider-->>SeekerHomeScreen: Job List
    SeekerHomeScreen-->>User: Show Available Jobs
    
    %% Logout
    User->>DashboardScreen: Click Logout
    DashboardScreen->>AuthProvider: logout()
    AuthProvider->>AuthProvider: Clear State
    DashboardScreen->>LoginScreen: Navigate
    LoginScreen-->>User: Show Login Screen
```

---

## State Diagram

```mermaid
stateDiagram-v2
    [*] --> AppLaunch
    
    AppLaunch --> CheckAuthState
    
    CheckAuthState --> BeforeSignIn : Not Logged In
    CheckAuthState --> AfterSignIn : Logged In
    
    %% Before Sign In States
    BeforeSignIn --> LoginScreen
    LoginScreen --> SignInScreen : Click Sign In
    SignInScreen --> RoleSelection : Show Role Options
    RoleSelection --> CredentialsInput : Role Selected
    CredentialsInput --> Validation : Submit Form
    Validation --> AfterSignIn : Valid Credentials
    Validation --> CredentialsInput : Invalid (Show Error)
    
    %% After Sign In States
    AfterSignIn --> DashboardScreen
    DashboardScreen --> PosterHomeScreen : Business Owner Actions
    DashboardScreen --> SeekerHomeScreen : Worker Actions
    DashboardScreen --> BeforeSignIn : Logout
    
    %% Business Owner Flow
    PosterHomeScreen --> AddJobScreen : Add New Job
    AddJobScreen --> PosterHomeScreen : Job Added
    PosterHomeScreen --> DashboardScreen : Back to Dashboard
    
    %% Worker Flow
    SeekerHomeScreen --> JobDetail : View Job Details
    JobDetail --> SeekerHomeScreen : Back to Jobs
    SeekerHomeScreen --> DashboardScreen : Back to Dashboard
    
    %% Navigation
    DashboardScreen --> LoginScreen : Logout
    LoginScreen --> [*] : App Close
```

---

## Component Diagram

```mermaid
graph TB
    subgraph "WorkBee App Architecture"
        subgraph "Presentation Layer"
            UI[UI Components]
            Navigation[Navigation System]
            Animations[Animation System]
        end
        
        subgraph "Business Logic Layer"
            AuthService[Authentication Service]
            JobService[Job Management Service]
            StateManagement[State Management]
        end
        
        subgraph "Data Layer"
            Models[Data Models]
            Providers[Provider Classes]
            LocalStorage[Local Storage]
        end
        
        subgraph "External Dependencies"
            Flutter[Flutter Framework]
            Provider[Provider Package]
            Material[Material Design]
        end
    end
    
    %% Component Relationships
    UI --> Navigation
    UI --> Animations
    Navigation --> AuthService
    Navigation --> JobService
    AuthService --> StateManagement
    JobService --> StateManagement
    StateManagement --> Providers
    Providers --> Models
    Models --> LocalStorage
    
    %% External Dependencies
    UI --> Flutter
    UI --> Material
    StateManagement --> Provider
    Navigation --> Flutter
```

---

## Activity Diagram

```mermaid
flowchart TD
    Start([App Start]) --> CheckAuth{User Logged In?}
    
    CheckAuth -->|No| ShowLogin[Show Login Screen]
    CheckAuth -->|Yes| ShowDashboard[Show Dashboard]
    
    %% Login Flow
    ShowLogin --> SelectRole[Select Role]
    SelectRole --> EnterCredentials[Enter Email & Password]
    EnterCredentials --> ValidateForm{Form Valid?}
    ValidateForm -->|No| ShowError[Show Error Message]
    ShowError --> EnterCredentials
    ValidateForm -->|Yes| Authenticate[Authenticate User]
    Authenticate --> UpdateState[Update Auth State]
    UpdateState --> ShowDashboard
    
    %% Dashboard Flow
    ShowDashboard --> CheckRole{User Role?}
    
    %% Business Owner Flow
    CheckRole -->|Business Owner| BusinessActions[Show Business Actions]
    BusinessActions --> ManageJobs[Manage Jobs]
    ManageJobs --> AddJob[Add New Job]
    AddJob --> SaveJob[Save Job]
    SaveJob --> UpdateJobs[Update Job List]
    UpdateJobs --> ManageJobs
    
    %% Worker Flow
    CheckRole -->|Worker| WorkerActions[Show Worker Actions]
    WorkerActions --> BrowseJobs[Browse Available Jobs]
    BrowseJobs --> ViewJob[View Job Details]
    ViewJob --> ApplyJob[Apply for Job]
    ApplyJob --> TrackApplication[Track Application]
    TrackApplication --> BrowseJobs
    
    %% Common Actions
    ManageJobs --> Logout[Logout]
    BrowseJobs --> Logout
    Logout --> ClearState[Clear Auth State]
    ClearState --> ShowLogin
    
    %% Navigation
    ManageJobs --> ShowDashboard
    BrowseJobs --> ShowDashboard
    ShowDashboard --> End([End])
```

---

## Key Design Patterns Used

### 1. **Provider Pattern**
- `AuthProvider`: Manages authentication state
- `JobProvider`: Manages job data
- Centralized state management

### 2. **Observer Pattern**
- `ChangeNotifier` for state updates
- UI automatically rebuilds when state changes

### 3. **Factory Pattern**
- `FadePageRoute` for creating custom page transitions

### 4. **Strategy Pattern**
- Different navigation strategies for different user roles

### 5. **Component Pattern**
- Reusable widgets (`AnimatedJobCard`, `AnimatedScaleButton`, `AppHeader`)

---

## Architecture Principles

### ✅ **SOLID Principles**
- **Single Responsibility**: Each class has one purpose
- **Open/Closed**: Components are extensible without modification
- **Liskov Substitution**: Widgets properly extend base classes
- **Interface Segregation**: Focused, specific interfaces
- **Dependency Inversion**: Dependencies on abstractions, not concretions

### ✅ **Clean Architecture**
- **Separation of Concerns**: UI, Business Logic, Data layers separated
- **Dependency Direction**: Dependencies point inward
- **Testability**: Each layer can be tested independently

### ✅ **Flutter Best Practices**
- **Widget Composition**: Building complex UIs from simple widgets
- **State Management**: Using Provider for app-wide state
- **Navigation**: Custom page routes for smooth transitions
- **Responsive Design**: Adapts to different screen sizes

---

*This documentation provides a comprehensive overview of the WorkBee app's architecture, design patterns, and user flows.* 