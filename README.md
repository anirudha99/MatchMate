# MatchMate
MatchMate is a SwiftUI-based app that allows users to browse through user profiles fetched from a remote API. Users can accept or decline profiles, with all interactions saved locally for offline access.

--------
Features :-
--------
Profile Browsing: Fetches and displays user profiles from the RandomUser API.
Accept/Decline Functionality: Allows users to accept or decline profiles, with dynamic UI updates.
Offline Mode: Caches profiles locally using Core Data, ensuring functionality even without an internet connection.
Data Persistence: Tracks user interactions and saves them for future app sessions.
Modern UI: Built with SwiftUI, featuring card-based design and gradient backgrounds.

----------
Tech Stack :-
----------
Frontend: SwiftUI for modern declarative UI.
Networking: Alamofire for API requests.
Image Loading: SDWebImageSwiftUI for efficient image handling.
Local Database: Core Data for offline storage and persistence.
Error Handling: Graceful handling of API errors and data persistence issues.
Combine Framework: Used for state management and updates.

----------
How It Works :-
----------
On Launch:
Fetches 10 random profiles from the API if online.
Loads cached profiles from Core Data if offline.

User Actions:
Accept or decline profiles via buttons on each profile card.
Updates the profile status locally and in the database.

Offline Mode:
Displays cached profiles and allows users to interact with them offline.
Synchronizes changes with the server when back online.

----------
Running the App :-
----------
Clone the repository
Open the project in Xcode.
Ensure you have a valid Apple developer account for signing.
Run the app on a simulator or device.

----------
Special Instructions :-
----------
Dependencies: Ensure you have the required libraries (Alamofire, SDWebImageSwiftUI) installed via Swift Package Manager.
API Usage: This app fetches data from the RandomUser API. Ensure internet access for API requests.




