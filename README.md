# WorkBee - Job Platform

A comprehensive job platform that connects business owners with workers, similar to Uber's model. Built with Flutter for cross-platform mobile development and FastAPI for the backend.

## 🚀 Features

### For Business Owners
- **Job Posting**: Create detailed job listings with skills, location, and compensation
- **Application Management**: Review and respond to worker applications with custom messages
- **Real-time Notifications**: Get notified of new applications via WebSocket
- **Job Status Tracking**: Monitor job progress from posting to completion
- **Business Dashboard**: Comprehensive overview with job statistics and notifications
- **Profile Management**: Update business information and contact details

### For Workers
- **Job Discovery**: Browse available jobs with detailed information and filtering
- **Easy Application**: Apply for jobs with automatic profile information
- **Application Tracking**: Monitor status of all applications in real-time
- **Skills Matching**: View required skills for each job
- **Worker Dashboard**: Track applications, notifications, and success rates
- **Profile Management**: Update skills, experience, and contact information

### Platform Features
- **Role-based Authentication**: Secure login with JWT tokens
- **Real-time Updates**: WebSocket notifications and instant status changes
- **Professional UI**: Modern design with dark/light theme support
- **Responsive Design**: Works seamlessly across all devices
- **Comprehensive Forms**: Detailed registration with validation
- **Location Services**: Job location tracking with coordinates
- **WebSocket Integration**: Real-time communication for notifications

## 📱 Screenshots

### Authentication & Onboarding
- Welcome screen with role selection
- Comprehensive signup forms with validation
- Secure login with JWT token authentication

### Business Owner Interface
- Dashboard with job statistics and notifications
- Job posting with multi-select skills and location
- Application management with accept/reject and messaging
- Real-time notification badges and WebSocket integration

### Worker Interface
- Job browsing with detailed cards and filtering
- Application tracking with real-time status updates
- Profile management with skills and experience
- Easy job application process with automatic profile data

## 🛠 Technology Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider pattern
- **UI Components**: Custom animated widgets
- **Theme**: Dark/Light mode support
- **Architecture**: Clean architecture with separation of concerns
- **HTTP Client**: http package for API communication
- **WebSocket**: web_socket_channel for real-time notifications

### Backend Integration
- **API**: FastAPI backend with RESTful endpoints
- **Authentication**: JWT token-based authentication
- **Database**: MySQL with SQLAlchemy ORM
- **Real-time**: WebSocket for notifications
- **Validation**: Pydantic models for data validation

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── constants/                   # App-wide constants and colors
├── models/                     # Data models (Job, JobApplication, etc.)
├── providers/                  # State management (Auth, Job, Notification)
├── screens/                    # UI screens (Dashboard, Job Details, etc.)
├── widgets/                    # Reusable components
├── utils/                     # Utility functions and navigation
└── core/                      # Core services and repositories
    ├── config/                # API configuration
    ├── services/              # API services and WebSocket
    ├── repositories/          # Data access layer
    └── di/                    # Dependency injection
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator
- Backend server running (see backend documentation)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/workbee.git
   cd workbee/Workbee-Front
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure backend connection**
   - Update API endpoints in `lib/core/config/app_config.dart`
   - Ensure backend server is running

4. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Environment Setup
The app is configured for production use with the following features:

1. **API Endpoints**: Configured for FastAPI backend integration
2. **Authentication**: JWT token-based authentication implemented
3. **WebSocket**: Real-time notifications via WebSocket
4. **Database**: Connected to MySQL database through API
5. **Push Notifications**: Framework ready for FCM integration

### API Configuration
Update `lib/core/config/app_config.dart` for your environment:

```dart
class AppConfig {
  static const String baseUrl = 'https://your-api-domain.com';
  static const String wsUrl = 'wss://your-api-domain.com';
  // ... other configurations
}
```

### Theme Customization
Modify `lib/constants/app_colors.dart` to customize the app's color scheme.

## 📊 Key Workflows

### Business Owner Workflow
1. **Register** as a Business Owner with company details
2. **Post Jobs** with detailed requirements, skills, and compensation
3. **Receive Applications** from workers via real-time notifications
4. **Review Applications** and worker profiles with detailed information
5. **Accept/Reject** applications with custom messages
6. **Track Job Progress** and completion status

### Worker Workflow
1. **Register** as a Worker with skills and experience
2. **Browse Available Jobs** with location and skill-based filtering
3. **Apply for Jobs** with automatic profile information
4. **Track Application Status** in real-time with notifications
5. **Receive Responses** from businesses with custom messages
6. **Contact Business** when application is accepted

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Role-based Access Control**: Separate interfaces for different user types
- **Form Validation**: Comprehensive client-side and server-side validation
- **Secure API Communication**: HTTPS/WSS for all network requests
- **Data Protection**: Proper data handling and privacy considerations
- **Input Sanitization**: All user inputs are validated and sanitized

## 🎨 UI/UX Features

- **Smooth Animations**: Animated job cards and interactive buttons
- **Responsive Design**: Optimized for all screen sizes and orientations
- **Theme Support**: Dark and light mode throughout the app
- **Professional Design**: Modern, clean interface with consistent styling
- **Accessibility**: Built with accessibility guidelines in mind
- **Loading States**: Proper loading indicators and error handling
- **Real-time Updates**: Live notification badges and status changes

## 📈 Performance

- **Optimized Widgets**: Efficient rebuilds and rendering with Provider
- **State Management**: Proper provider usage for optimal performance
- **Image Optimization**: Ready for optimized image loading and caching
- **API Caching**: Framework in place for data caching and offline support
- **Memory Management**: Proper disposal of resources and controllers
- **Network Optimization**: Efficient API calls with proper error handling

## 🧪 Testing

The app is structured for comprehensive testing:

- **Unit Tests**: Provider and utility function testing
- **Widget Tests**: UI component testing with Flutter test framework
- **Integration Tests**: End-to-end workflow testing
- **API Tests**: Backend integration testing
- **Performance Tests**: App performance monitoring and optimization

## 🔮 Current Status

### ✅ Implemented Features
- Complete job posting and application system
- User authentication with JWT tokens
- Real-time notifications via WebSocket
- Professional UI/UX with dark/light themes
- Business owner and worker dashboards
- Application management with accept/reject
- Profile management for both user types
- Location-based job filtering
- Comprehensive form validation
- Error handling and user feedback

### 🔄 In Development
- Push notifications (FCM integration)
- Advanced job matching algorithms
- Payment processing system
- Rating and review system

### 📋 Future Roadmap
- Real-time messaging between users
- Video calling for interviews
- Document upload and verification
- Multi-language support
- Advanced analytics and reporting
- Mobile app store deployment

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart conventions and best practices
- Add tests for new features
- Update documentation as needed
- Ensure code quality and performance
- Test on both Android and iOS platforms
- Follow the existing code structure and patterns

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- FastAPI team for the excellent backend framework
- The open-source community for various packages and tools
