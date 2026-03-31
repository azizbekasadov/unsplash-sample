# Sample Unsplash App Case Study

## Unsplash Feed Feature Specs

### Story: User requests to see the photo feed

### Narrative #1

As an online user  
I want the app to load the latest Unsplash editorial feed  
So I can browse fresh images from the API

#### Scenarios (Acceptance criteria)

Given the user has connectivity  
When the user requests to see the feed  
Then the app should load the latest page of photos from remote  
And the app should display the remote feed  
And the app should replace the cached feed with the new feed metadata

Given the user has connectivity  
When the user requests the next page of the feed  
Then the app should load the next remote page  
And the app should append the new images to the displayed feed

Given the remote service returns invalid data  
When the user requests to see the feed  
Then the app should display an error message

Given the remote service returns an empty page  
When the user requests to see the feed  
Then the app should display an empty state for that page

### Narrative #2

As an offline user  
I want the app to show the latest saved version of the feed  
So I can continue browsing even without connectivity

#### Scenarios (Acceptance criteria)

Given the user doesn't have connectivity  
And there’s a cached version of the feed  
And the cache is less than seven days old  
When the user requests to see the feed  
Then the app should display the latest cached feed

Given the user doesn't have connectivity  
And there’s a cached version of the feed  
And the cache is seven days old or more  
When the user requests to see the feed  
Then the app should display an error message

Given the user doesn't have connectivity  
And the cache is empty  
When the user requests to see the feed  
Then the app should display an error message

### Narrative #3

As a user  
I want the app to render images progressively and efficiently  
So the feed feels responsive and bandwidth-efficient

#### Scenarios (Acceptance criteria)

Given a feed image is visible on screen  
When the image has not been downloaded yet  
Then the app should request the image using the provided Unsplash image URL  
And the app should render a placeholder while loading

Given an image was previously cached locally  
When the user scrolls back to it  
Then the app should render the cached image data

Given an image is no longer visible  
When its loading task is cancelled by the UI lifecycle  
Then the app should not deliver the image result to the old view


## Photo Details Feature Specs

### Story: User requests to see photo details

### Narrative #1

As a user  
I want to open a selected photo in full screen  
So I can inspect the image and its metadata

#### Scenarios (Acceptance criteria)

Given the user selected a photo in the feed  
When the details screen is shown  
Then the app should display the full-screen image  
And the app should display the photo description if available  
And the app should display the author name  
And the app should display the author username  
And the app should display photo metadata if available
And the app should display a download button when downloading is allowed

Given the photo details request fails  
When the details screen is shown  
Then the app should display an error message

Given cached photo details exist  
When the app cannot refresh them from remote  
Then the app may display the cached details

### Narrative #2

As a user  
I want to tap the author's name  
So I can navigate to the author profile screen

#### Scenarios (Acceptance criteria)

Given the details screen is visible  
When the user taps the author button  
Then the app should open the author's profile screen

## Author Profile Feature Specs

### Story: User requests to see an author's profile and collections

### Narrative #1

As a user  
I want to see the selected author's public profile  
So I can learn more about the photographer

#### Scenarios (Acceptance criteria)

Given the user opens an author profile  
When the user has connectivity  
Then the app should load the author's public profile from remote  
And the app should display the author’s name  
And the app should display bio when available  
And the app should display location when available  
And the app should display portfolio link when available  
And the app should display social handles when available  
And the app should display total collections and downloads when available

Given the profile request fails  
When the user opens an author profile  
Then the app should display an error message

### Narrative #2

As a user  
I want to see the author’s collections in a grid  
So I can browse them like an Instagram-style gallery

#### Scenarios (Acceptance criteria)

Given the author profile screen is visible  
When the collections are loaded successfully  
Then the app should display the user’s collections in a grid layout  
And each collection cell should display its cover image, title, and photo count

Given the user selects a collection  
When the collection details are loaded  
Then the app should display the collection photos in a grid layout

Given the collections request fails  
When the user opens the author profile  
Then the app should display an error message for the collections section

## Download Photo Feature Specs

### Story: User requests to download a photo

### Narrative #1

As a user  
I want to download eligible photos  
So I can save images I’m allowed to download

#### Scenarios (Acceptance criteria)

Given the selected photo is eligible for download  
When the user taps the download button  
Then the app should trigger the Unsplash download tracking endpoint  
And the app should retrieve the downloadable URL from the response  
And the app should download the image data  
And the app should save the image to the user’s photo library  
And the app should display a success message

Given the selected photo is not eligible for download by business rules  
When the user views the details screen  
Then the app should hide or disable the download button  
And the app should explain why the image cannot be downloaded

Given the user denies photo library permission  
When the user taps the download button  
Then the app should display a permissions error message

Given the download tracking request fails  
When the user taps the download button  
Then the app should display an error message  
And the app should not save the image

Given the image download fails after tracking succeeded  
When the user taps the download button  
Then the app should display an error message
