# Applicant Showcase App - Developer Report

## 1. Introduction
Starting this project, I was excited to tackle the challenge of integrating a "Journalist" feature into an existing codebase. The prompt to allow users to upload their own articles was a great opportunity to demonstrate not just UI skills, but full-stack capabilities using Firebase. My goal was to respect the existing high standards of the project while adding significant value.

## 2. Learning Journey
The most significant part of this journey was adapting to the **Clean Architecture** pattern used in the project.
- **Clean Architecture**: I learned how to strictly separate the code into **Domain** (Entities, UseCases), **Data** (Repositories, DataSources), and **Presentation** (BLoC, UI) layers.
- **Firebase Integration**: I deepened my knowledge of **Firestore** for NoSQL data modeling and **Firebase Storage** for handling binary files like images.
- **Flutter BLoC**: I utilized BLoC/Cubit to manage the state of the upload form (Loading, Success, Error), ensuring the UI is always reactive and responsive.

## 3. Challenges Faced
- **Architecture Compliance**: The biggest challenge was resisting the urge to write "spaghetti code". Implementing a simple upload feature required creating multiple files (Entity, Model, Repository Interface, Repository Implementation, DataSource, UseCase, Bloc). I overcame this by methodically planning the layers before writing the UI.
- **Image Uploading**: Handling the asynchronous nature of uploading an image to Storage *before* creating the database record was tricky. I solved this by chaining the asynchronous operations in the DataSource layer to ensure data integrity.

## 4. Reflection and Future Directions
This project reinforced the value of a well-structured codebase. While Clean Architecture requires more boilerplate, it makes the code infinitely more testable and maintainable.
**Future Directions:**
- **Authentication**: Currently, articles are anonymous. Integrating Firebase Auth would allow linking articles to specific users.
- **Offline Support**: Using a local database (like Floor or Hive) to save drafts when there is no internet connection.
- **Edit/Delete**: Expanding the feature to allow journalists to manage their existing articles.

## 5. Proof of the Project
*[Insert Screenshot here: Home Screen showing the new '+' Floating Action Button]*
*[Insert Screenshot here: The 'Create Article' form filled with data and an image selected]*
*[Insert Screenshot here: The 'Success' snackbar after uploading]*
*[Insert Screenshot here: The Firestore Console showing the new document in the 'articles' collection]*

## 6. Overdelivery
I went beyond the basic requirement of "uploading text" by implementing a production-ready feature:

### 1. Robust Architecture & Validation
Instead of a simple form, I implemented **full Clean Architecture** layers.
- **Frontend Validation**: The form prevents submission if fields are empty or no image is selected.
- **Backend Enforcement**: I wrote custom **Firestore Security Rules** to reject any data that doesn't match the schema, ensuring database integrity.

### 2. Full Image Integration
The assignment hinted at image support. I implemented **Firebase Storage** integration, allowing users to pick images from their gallery, which are then uploaded, stored, and linked via URL to the article document.

### 3. Enhanced UI/UX
- **Floating Action Button**: Integrated a seamless entry point in the main UI.
- **User Feedback**: Added loading indicators during upload and specific error messages if something goes wrong, ensuring the user is never left guessing.

