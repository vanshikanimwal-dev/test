Ferrero Asset Management App
This is a mobile application built with Flutter to manage and track assets. The app allows users to log in, search for assets, apply various filters, and view or interact with asset-related documents, such as consent forms.

Key Features
Login & Authentication: Users can log in with a username and password to access the app's functionality.

Asset Search: A dedicated search page allows users to find assets by outlet name or UOC (Unique Outlet Code).

Advanced Filtering: A customizable drawer provides options to filter assets by status (Completed, In Progress, Open, Closed) and by a custom date range.

Real-time Status Updates: The search results screen displays the current status of each asset, with color-coded labels for easy identification.

Conditional Interaction:

For Completed assets, tapping on the asset list item launches an external PDF viewer to display the consent form from a dedicated API endpoint.

For assets with other statuses, tapping navigates to a new page to handle or view a consent form.

Project Structure
The key files and directories in the project are organized as follows:

main.dart: The entry point of the application, responsible for setting up the app's overall structure and initial routing.

lib/screens/login/login_page.dart: Contains the UI and logic for the user login screen.

lib/screens/shops/search_page.dart: The main screen for searching and displaying the list of assets. It includes the logic for fetching data from the API and applying filters.

lib/screens/shops/consent_form_page.dart: The page where users can interact with and potentially fill out a consent form for an asset.

lib/models/asset_details_model.dart: Defines the data model for an asset, including fields like UOC, outlet name, status, and various photo/document URLs.

lib/services/app_api_service.dart: Handles all communication with the backend API, including fetching asset details and handling authentication.

lib/provider/data_provider.dart: Manages the application's state, such as the authentication token, using the Provider package.

Setup and Installation
To run this application, you need to have Flutter installed and configured on your system.

Clone the repository:

git clone [repository-url]
cd [repository-name]

Install dependencies:

flutter pub get

Run the app:

flutter run
