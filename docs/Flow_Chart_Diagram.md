# WorkBee App Flow Chart Diagram

## Application Flow Overview

```mermaid
flowchart TD
    A[App Launch] --> B[main.dart]
    B --> C[HomeScreen]
    C --> D{AuthProvider.isLoggedIn?}
    
    D -->|No| E[LoginScreen]
    D -->|Yes| F[DashboardScreen]
    
    E --> G[User Sees Landing Page]
    G --> H[Statistics Section]
    H --> I[Action Buttons]
    I --> J[Why Choose Us Section]
    
    I --> K{User Clicks}
    K -->|Hire Workers| L[SignInScreen with Poster Role]
    K -->|Find Work| M[SignInScreen with Seeker Role]
    
    L --> N[Business Owner Sign In]
    M --> O[Worker Sign In]
    
    N --> P{Authentication Success?}
    O --> P
    P -->|Yes| Q[AuthProvider Updates State]
    P -->|No| R[Show Error Message]
    R --> L
    
    Q --> S[User Role Determined]
    S --> T{User Role}
    T -->|Business Owner| U[PosterHomeScreen]
    T -->|Worker| V[SeekerHomeScreen]
    
    F --> W{User Role from AuthProvider}
    W -->|Business Owner| U
    W -->|Worker| V
    
    U --> X[Manage Posted Jobs]
    U --> Y[Add New Job]
    U --> Z[Cancel Jobs]
    
    V --> AA[Browse Available Jobs]
    V --> BB[Apply for Jobs]
    V --> CC[View Job Details]
    
    Y --> DD[AddJobScreen]
    DD --> EE[Job Form with Designation]
    EE --> FF[JobProvider.addJob]
    FF --> GG[Job Added to Active Jobs]
    GG --> U
    
    AA --> HH[JobProvider.getJobs]
    HH --> II[Display Job Cards]
    II --> JJ[AnimatedJobCard]
    JJ --> CC
    
    CC --> KK[Job Detail Dialog]
    KK --> LL[Close Dialog]
    LL --> V
    
    Z --> MM[JobProvider.cancelJob]
    MM --> NN[Job Moved to History]
    NN --> U
    
    BB --> OO[Job Application Process]
    OO --> PP[Application Submitted]
    PP --> V
    
    %% Navigation Flow
    U --> QQ[AppHeader Navigation]
    V --> QQ
    QQ --> RR{Navigation Action}
    RR -->|Logout| SS[AuthProvider.logout]
    RR -->|Sign In| TT[SignInScreen]
    RR -->|Sign Up| UU[SignUpScreen]
    RR -->|For Business| U
    RR -->|For Workers| V
    
    SS --> C
    
    TT --> N
    UU --> VV[Role Selection]
    VV --> WW[Form Validation]
    WW --> XX[Registration Success]
    XX --> C
    
    %% Error Handling
    P -->|Network Error| YY[Show Network Error]
    P -->|Invalid Credentials| ZZ[Show Auth Error]
    YY --> L
    ZZ --> L
    
    %% UI Components
    JJ --> AAA[GradientBackground]
    JJ --> BBB[AnimatedScaleButton]
    JJ --> CCC[FadePageRoute]
    
    %% Providers
    Q --> DDD[AuthProvider State Management]
    FF --> EEE[JobProvider State Management]
    MM --> EEE
    
    %% Constants
    EE --> FFF[JobDesignations Constants]
    QQ --> GGG[UserRole Constants]
    QQ --> HHH[AppColors Constants]
    
    %% Utils
    QQ --> III[NavigationUtils]
    III --> RR
    
    style A fill:#e1f5fe
    style C fill:#f3e5f5
    style E fill:#fff3e0
    style F fill:#e8f5e8
    style U fill:#e3f2fd
    style V fill:#f1f8e9
    style DD fill:#fff8e1
    style QQ fill:#fce4ec
```

## Detailed Flow Breakdown

### 1. Application Startup Flow
```
App Launch → main.dart → HomeScreen → Check Authentication Status
```

### 2. Authentication Flow
```
Not Logged In → LoginScreen → User Actions → Sign In/Up → Role Selection → Dashboard
```

### 3. Business Owner Flow
```
Dashboard → PosterHomeScreen → Manage Jobs → Add/Cancel Jobs → Job Management
```

### 4. Worker Flow
```
Dashboard → SeekerHomeScreen → Browse Jobs → View Details → Apply for Jobs
```

### 5. Navigation Flow
```
AppHeader → Navigation Actions → Role-based Routing → Screen Transitions
```

## Key Components and Their Roles

### Screens (2,579 total lines)
- **LoginScreen (303 lines)**: Landing page with statistics and action buttons
- **SignInScreen (384 lines)**: Authentication with role selection
- **SignUpScreen (450 lines)**: Registration with dynamic forms
- **DashboardScreen (251 lines)**: Post-login hub with quick actions
- **PosterHomeScreen (109 lines)**: Business owner job management
- **SeekerHomeScreen (91 lines)**: Worker job browsing
- **AddJobScreen (205 lines)**: Job posting with designation selection

### Providers (65 lines)
- **AuthProvider (40 lines)**: Authentication state management
- **JobProvider (25 lines)**: Job data management

### Widgets (614 lines)
- **AppHeader (216 lines)**: Navigation and user interface
- **AnimatedJobCard (107 lines)**: Job display with animations
- **AnimatedScaleButton (83 lines)**: Interactive buttons
- **GradientBackground (31 lines)**: Reusable background component

### Models & Constants (76 lines)
- **Job Model (18 lines)**: Job data structure
- **AppColors (22 lines)**: Color constants
- **JobDesignations (15 lines)**: Predefined job types
- **UserRoles (0 lines)**: Role enumeration

### Utils (49 lines)
- **NavigationUtils (49 lines)**: Centralized navigation logic

## State Management Flow

```mermaid
stateDiagram-v2
    [*] --> Unauthenticated
    Unauthenticated --> Authenticating: Sign In/Up
    Authenticating --> Authenticated: Success
    Authenticating --> Unauthenticated: Failure
    Authenticated --> BusinessOwner: Role = Poster
    Authenticated --> Worker: Role = Seeker
    BusinessOwner --> Unauthenticated: Logout
    Worker --> Unauthenticated: Logout
    Unauthenticated --> [*]
```

## Data Flow Architecture

```mermaid
graph LR
    A[UI Components] --> B[Providers]
    B --> C[Models]
    B --> D[Constants]
    A --> E[Utils]
    E --> B
    
    B --> F[State Updates]
    F --> A
    
    G[User Actions] --> A
    A --> H[Navigation]
    H --> I[Screen Transitions]
```

## Error Handling Flow

```mermaid
flowchart TD
    A[User Action] --> B{Validation}
    B -->|Pass| C[Process Action]
    B -->|Fail| D[Show Error Message]
    D --> A
    
    C --> E{Network Request}
    E -->|Success| F[Update UI]
    E -->|Failure| G[Show Network Error]
    G --> A
    
    F --> H[State Update]
    H --> I[Provider Notify]
    I --> J[UI Refresh]
```

This flow chart represents the complete application architecture with 2,579 lines of code, showing how user interactions, state management, and navigation work together to create a seamless job portal experience. 