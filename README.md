# Architecture

The application utilizes the MVVM (Model-View-ViewModel) architectural pattern, combined with SwiftUI for the user interface. The code is organized into distinct layers:

- **Model**: Represents the data and business logic.
- **View**: Manages the user interface using SwiftUI.
- **ViewModel**: Acts as an intermediary between the Model and View, handling data binding and business logic.
- **Worker**: Acts as an intermediary between the ViewModel and external services (such as network calls or database operations). It encapsulates the logic for fetching, processing, and manipulating data, ensuring that the ViewModel remains focused on UI-related logic.
- **Network**: Handles all network-related operations, including API calls and data fetching.

## Description

The solution includes several key features:

- **Pagination**: Efficiently loads and displays data in chunks, improving performance and user experience.
- **Asynchronous Data Loading**: Utilizes `async/await` for non-blocking data fetching, ensuring smooth and responsive UI.
- **Error Handling**: Robust error handling mechanisms to manage and display errors.

## Used API

The application interacts with the following API to fetch and display data:

- [dummyjson.com](https://dummyjson.com): A free online REST API for testing and prototyping.
