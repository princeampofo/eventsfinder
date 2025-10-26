# eventsfinder
 
 A Flutter application to discover events happening around you. The app allows users to explore events by category, date, and location, providing detailed information and images for each event.
 
 ## Features
 
 - Browse events by categories such as Music, Sports, Arts, and Technology.
 - Filter events based on date and location.
 - View detailed event information including images, descriptions, venues, and prices.
 - Store event data locally for offline access.
 - User-friendly UI/UX design for seamless navigation.
 
 ## Getting Started
 
 1. Clone the repository:
 
    ```bash
    git clone https://github.com/yourusername/eventsfinder.git
    ```

2. Navigate to the project directory:

    ```bash
    cd eventsfinder
    ```

3. Install the dependencies:

    ```bash
    flutter pub get
    ```

4. Run the application:

    ```bash
    flutter run
    ```

## Functionality Overview
- On launching the app, users are greeted with a login/signup screen.
- Users can navigate to the Discover screen to explore events by category, date, and location.
- Dummy data is pre-populated in the local database for demonstration purposes.
- The app supports both light and dark themes for better user experience.
- Users can tap on any event to view detailed information including images, descriptions, venues, and prices.
- Location services are integrated to help users find events near them.
- User can create an account and log in to save favorite events.
- Ubser can create new events which will be stored in the local database.

## Technologies Used
- Flutter
- Dart
- SQLite for local database storage
- Geolocator for location services
- Provider for state management

## Demo login credentials(for testing purposes)
- Email:
    - demo@example.com
- Password:
    - 1234