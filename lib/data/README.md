# Data Layer Architecture

## Overview
This data layer provides a complete backend-ready structure similar to the authentication system, with models, repositories, and API integration.

## Structure

### Models (`lib/data/models/`)
- **PathModel**: Represents hiking paths/routes with full JSON serialization
- **ReviewModel**: User reviews and ratings
- **TripRegistrationModel**: Trip registration requests
- **UserModel**: User information
- **ActivityModel**: Activity types

### Repositories (`lib/data/repositories/`)
All repositories follow the same pattern as `UserRepository`:

1. **PathsRepository**
   - `getAllPaths()`: Get all paths (with API fallback)
   - `getFeaturedPaths()`: Get featured/popular paths
   - `getPathById(id)`: Get specific path
   - `searchPaths(query)`: Search paths
   - `getPathsByActivity(activity)`: Filter by activity type
   - `getPathsByDifficulty(difficulty)`: Filter by difficulty

2. **ReviewsRepository**
   - `getReviews()`: Get all reviews with filters
   - `getReviewById(id)`: Get specific review
   - `createReview()`: Add new review
   - `updateReview()`: Update review
   - `deleteReview()`: Delete review
   - `getReviewStats()`: Get statistics
   - `canReview()`: Check if user can review

3. **TripRegistrationRepository**
   - `getTripRegistrations()`: Get all registrations
   - `getTripRegistrationById(id)`: Get specific registration
   - `createTripRegistration()`: Create new registration
   - `updateTripRegistration()`: Update registration
   - `deleteTripRegistration()`: Delete registration

4. **SavedPathsRepository**
   - `getSavedPaths()`: Get all saved paths
   - `savePath(id)`: Save a path
   - `removeSavedPath(id)`: Remove from saved
   - `isPathSaved(id)`: Check if saved
   - `toggleSavedPath(id)`: Toggle save status

5. **UserRepository** (existing)
   - Authentication methods
   - Profile management

### Services (`lib/data/services/`)
- **ApiService**: Centralized API communication
  - Base URL configuration
  - Authentication token management
  - HTTP methods (GET, POST, PUT, DELETE)
  - Error handling

## Usage

### Switching to API Mode

Currently, repositories use dummy data by default. To enable API integration:

```dart
// In PathsRepository
final pathsRepo = PathsRepository();
pathsRepo.useApi = true; // Enable API mode

// Now all methods will try API first, fallback to dummy data if fails
final paths = await pathsRepo.getAllPaths();
```

### Example: Using PathsRepository

```dart
final repository = PathsRepository();
repository.useApi = true; // Enable when backend is ready

// Get all paths
final paths = await repository.getAllPaths();

// Get featured paths
final featured = await repository.getFeaturedPaths();

// Search
final results = await repository.searchPaths('Jericho');

// Get by ID
final path = await repository.getPathById('1');
```

### Example: Using ReviewsRepository

```dart
final repository = ReviewsRepository();

// Get reviews for a site
final reviews = await repository.getReviews(siteId: '123');

// Create review
final review = await repository.createReview(
  siteId: '123',
  rating: 5,
  comment: 'Amazing path!',
);

// Get stats
final stats = await repository.getReviewStats(siteId: '123');
```

### API Configuration

The API base URL is configured in `ApiService`:

```dart
// For Android Emulator:
final String baseUrl = 'http://10.0.2.2:8000/api';

// For iOS Simulator:
// final String baseUrl = 'http://127.0.0.1:8000/api';

// For real device:
// final String baseUrl = 'http://192.168.1.100:8000/api';
```

### Error Handling

All repositories handle errors gracefully:
- API errors are caught and logged
- Fallback to dummy data if API is unavailable
- Exceptions are thrown with descriptive Arabic messages

### Response Format

The repositories expect API responses in this format:

```json
{
  "status": "success",
  "data": {
    // ... actual data
  },
  "message": "Optional message"
}
```

For lists, the data can be either:
- Direct array: `"data": [...]`
- Nested: `"data": { "paths": [...] }` or `"data": { "sites": [...] }`

## Next Steps

1. **Enable API Mode**: Set `useApi = true` in repositories when backend is ready
2. **Update Endpoints**: Adjust API endpoints in `ApiService` if needed
3. **Test Connectivity**: Use `ApiService.testConnection()` to verify API
4. **Handle Authentication**: Ensure tokens are set via `ApiService.setAuthToken()`

## Backend Requirements

Your Laravel backend should provide these endpoints:

- `GET /api/sites` - Get paths (sites with type='route')
- `GET /api/sites/{id}` - Get specific path
- `GET /api/reviews` - Get reviews
- `POST /api/reviews` - Create review
- `GET /api/saved-paths` - Get saved paths
- `POST /api/saved-paths` - Save path
- `POST /api/trip-registrations` - Create trip registration

All protected endpoints should accept Bearer token in Authorization header.








