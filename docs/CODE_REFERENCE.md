# WorkBee Frontend - Code Reference

## Project Overview
WorkBee is a comprehensive job platform that connects business owners with workers, similar to Uber's model. The platform supports two user roles: Business Owners (Posters) and Workers (Seekers), with separate workflows and interfaces for each role.

## Architecture

### Core Components
```
lib/
├── main.dart                    # App entry point with provider setup
├── constants/                   # App-wide constants
│   ├── app_colors.dart         # Color scheme definitions
│   ├── job_designations.dart   # Predefined job categories
│   └── user_roles.dart         # User role definitions
├── models/                     # Data models
│   └── job.dart               # Job and JobApplication models
├── providers/                  # State management
│   ├── auth_provider.dart     # Authentication and user management
│   ├── job_provider.dart      # Job posting and application management
│   └── theme_provider.dart    # Theme switching functionality
├── screens/                    # UI screens
│   ├── home_screen.dart       # Landing page with role selection
│   ├── sign_in_screen.dart    # User authentication
│   ├── sign_up_screen.dart    # User registration with role selection
│   ├── dashboard_screen.dart  # Main dashboard after login
│   ├── poster_home_screen.dart # Business owner dashboard
│   ├── seeker_home_screen.dart # Worker dashboard
│   ├── post_job_screen.dart   # Job posting form for businesses
│   ├── job_listing_screen.dart # Job browsing for workers
│   ├── job_detail_screen.dart # Detailed job view with apply
│   ├── business_dashboard_screen.dart # Full business management
│   ├── job_applications_screen.dart # Application management
│   └── my_applications_screen.dart # Worker's application tracking
├── widgets/                    # Reusable UI components
│   ├── animated_job_card.dart # Job display with animations
│   ├── animated_scale_button.dart # Interactive buttons
│   ├── app_header.dart        # App header with navigation
│   ├── fade_page_route.dart   # Custom page transitions
│   └── gradient_background.dart # Background styling
└── utils/                     # Utility functions
    └── navigation_utils.dart  # Navigation helpers
```

## Key Features

### 🔐 Authentication System
- **Role-based registration**: Users choose between Business Owner or Worker
- **Comprehensive signup**: Personal info, address, skills, education, security
- **Dynamic validation**: Real-time form validation with error messages
- **Theme support**: Dark/light mode throughout the app

### 💼 Job Management (Business Owners)
- **Comprehensive job posting**: Title, description, skills, location, compensation
- **Multi-select skills**: Dropdown with predefined retail/service skills
- **Dynamic location**: Auto-fill state/city based on pin code
- **Application management**: View, accept, reject applications
- **Real-time notifications**: Badge counts for pending applications
- **Job status tracking**: Open, in progress, completed, cancelled

### 🔍 Job Discovery (Workers)
- **Job browsing**: View all available jobs with detailed information
- **Application system**: Apply for jobs with profile information
- **Application tracking**: Monitor status of all applications
- **Skills matching**: View required skills for each job
- **Location-based**: Jobs filtered by location

### 📱 User Experience
- **Responsive design**: Works on all screen sizes
- **Smooth animations**: Animated job cards and buttons
- **Professional UI**: Modern design with consistent theming
- **Intuitive navigation**: Clear workflow for each user role

## Data Models

### Job Model
```dart
class Job {
  final String id;
  final String businessId;
  final String businessName;
  final String title;
  final String description;
  final List<String> requiredSkills;
  final String location;
  final String address;
  final String state;
  final String city;
  final String pinCode;
  final double hourlyRate;
  final int estimatedHours;
  final DateTime postedDate;
  final DateTime? startDate;
  final JobStatus status;
  final List<JobApplication> applications;
  final String contactPerson;
  final String contactPhone;
  final String contactEmail;
}
```

### JobApplication Model
```dart
class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  final String workerName;
  final String workerEmail;
  final String workerPhone;
  final List<String> workerSkills;
  final int yearsOfExperience;
  final String previousWorkExperience;
  final ApplicationStatus status;
  final DateTime appliedDate;
  final DateTime? respondedDate;
  final String? message;
}
```

## State Management

### JobProvider
Centralized job and application management with methods:
- `postJob()` - Business owners post new jobs
- `applyForJob()` - Workers apply for jobs
- `respondToApplication()` - Business owners accept/reject applications
- `updateJobStatus()` - Update job status
- `loadJobs()` - Load sample jobs (simulated API)
- `getPendingApplicationsCount()` - Get notification count

### AuthProvider
User authentication and role management:
- `login()` - User authentication
- `logout()` - User logout
- `register()` - User registration
- Role-based access control

### ThemeProvider
Theme switching functionality:
- `toggleTheme()` - Switch between dark/light modes
- `isDarkMode` - Current theme state

## Workflow Implementation

### Business Owner Flow
1. **Register/Login** → Choose Business Owner role
2. **Post Job** → Fill comprehensive job form
3. **Receive Applications** → Get notified of new applications
4. **Review Applications** → View worker profiles and experience
5. **Accept/Reject** → Respond with status and optional message
6. **Track Progress** → Monitor job status and completion

### Worker Flow
1. **Register/Login** → Choose Worker role
2. **Browse Jobs** → View available jobs with detailed information
3. **Apply for Jobs** → Submit application with profile data
4. **Track Applications** → Monitor application status
5. **Receive Responses** → Get notified of acceptance/rejection
6. **Contact Business** → Reach out when accepted

## UI Components

### AnimatedJobCard
- Displays job information with smooth animations
- Shows business name, location, compensation, skills
- Indicates if user has already applied
- Supports tap interactions for job details

### AnimatedScaleButton
- Interactive buttons with scale animations
- Supports custom styling and borders
- Handles both sync and async callbacks
- Nullable onTap for loading states

### GradientBackground
- Consistent background styling across screens
- Supports custom padding and child widgets
- Theme-aware gradient colors

## Navigation

### NavigationUtils
Centralized navigation management:
- `handleNavigation()` - Route-based navigation
- `navigateToAddJob()` - Job posting navigation
- Role-based navigation logic

### Screen Flow
```
HomeScreen
├── SignInScreen
├── SignUpScreen
└── DashboardScreen
    ├── PosterHomeScreen (Business)
    │   ├── PostJobScreen
    │   ├── BusinessDashboardScreen
    │   └── JobApplicationsScreen
    └── SeekerHomeScreen (Worker)
        ├── JobListingScreen
        ├── JobDetailScreen
        └── MyApplicationsScreen
```

## API Integration Ready

The app is structured for easy backend integration:
- **JobProvider** methods are ready for API calls
- **Data models** support JSON serialization
- **Error handling** framework in place
- **Loading states** implemented throughout

## Future Enhancements

### Planned Features
- **Real-time messaging** between workers and businesses
- **Push notifications** for application updates
- **Payment processing** for completed jobs
- **Rating system** for both workers and businesses
- **Advanced filtering** and search capabilities
- **Job scheduling** and calendar integration
- **Document upload** for resumes and certifications
- **Multi-language support** for international users

### Technical Improvements
- **Backend API integration** with real database
- **Image upload** for job photos and worker profiles
- **Geolocation services** for nearby job matching
- **Offline support** with local data caching
- **Performance optimization** for large job listings
- **Unit and widget testing** coverage
- **CI/CD pipeline** for automated deployment

## Development Guidelines

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent formatting

### State Management
- Use Provider pattern for state management
- Keep providers focused on specific domains
- Avoid deep nesting of providers
- Use Consumer widgets efficiently

### UI/UX Principles
- Maintain consistent theming
- Provide clear feedback for user actions
- Implement proper loading states
- Ensure accessibility compliance
- Test on multiple screen sizes

### Performance
- Optimize widget rebuilds
- Use const constructors where possible
- Implement proper list virtualization
- Minimize network requests
- Cache frequently used data 