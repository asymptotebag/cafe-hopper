# Croissavant

<p align="left">
    <img src="/cafe-hopper/Assets.xcassets/icon.imageset/IMG_0035.jpg" height="200" width="200" />
</p>

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Croissavant is an iOS app for cafe hoppers — people who like to visit multiple eateries in a day, trying something small at each one. This app helps you plan trips to hit all the coffee shops, bakeries, and other quick-bite stops on your bucket list.

### App Evaluation
- **Category:** Lifestyle, Travel
- **Mobile:** Portability would be key to making a concept like this work, since it is unlikely that people will tote a laptop from cafe to cafe. Thus, Croissavant would make for a uniquely mobile experience that could not easily be replaced by a website. The app would incorporate maps and location, and possibly camera (if there is a feature to save your own photos to cafes that you've visited). Push notifications would also be relatively natural to incorporate, since the app could remind you of your scheduled plans.
- **Story:** Croissavant allows users to fully experience the vibrant casual dining culture of anywhere, from an unfamiliar city to their own hometown.
- **Market:** The market for this app is broad, appealing mostly to relatively young city-dwellers or those living near downtown / urban regions with clusters of quick-bite options.
- **Habit:** The average user would do a fair amount of both consuming and creating on the app: they consume when they check out cafe listings and information, and create when they add cafes to personal lists or plan and save cafe-hopping routes.
- **Scope:** Incorporating the Google Maps SDK would be the primary backend task. I believe that the core features of the app are of reasonable technical difficulty.  It would be great to be able to "tag" cafes with descriptors such as "historic," "newly-opened," "vegan-friendly," etc. to allow users to discover cafes better within the app. I anticipate that this tagging feature might not be straightforward, and may involve searching the reviews for key words or performing sentiment analysis. However, I believe that even with just the core features, it will still be an interesting app both to build and use.

### Challenges Encountered
[Noteworthy challenges, complexities, and issues](https://docs.google.com/document/d/195XGly5gwrbprS8YwWKYAs6ATSI2Fg8HU30Azu0Fo7M/edit?usp=sharing)

## Product Spec

### 1. User Stories

**Required Must-have Stories**
- [x] User sees an app logo on their home screen and a styled launch screen
- [x] User can create a new account
- [x] User can login and logout
- [x] User can search for eateries
- [x] User can view the location of eateries on a map powered by Google Maps SDK
- [x] User can save (and unsave) eateries to custom collections (e.g. Favorites, Want to Visit)
- [x] User can create (and delete) collections of eateries
- [x] User can view details of an eatery, such as its address, price level ($ to $$$$), rating, etc.
- [x] User can see photos of an eatery
- [x] User can create (and delete) "trips": an ordered list of eateries that the user wants to visit in a single trip
- [x] User can add (and delete) eateries to trips
- [x] User can be redirected to the Google Maps website/app with preloaded navigation directions for a trip

**Optional Nice-to-have Stories**
- [ ] User has multiple options to create a new account (e.g. with email, Google, Facebook)
- [x] User can login with either username or email
- [x] User can adjust account settings (e.g. email, username, profile pic, notifications on/off)
- [x] User has the option to show/hide bars in search results (for those 21+ who enjoy bar-hopping)
- [ ] User can apply search filters (e.g. price level, rating)
- [x] User can see recent searches on the search screen
- [ ] User can see cafe recommendations on the search screen based on previous searches or saves
- [x] User can be redirected to an eatery's website and call their phone number through the app
- [x] User can read reviews, or review keywords, of an eatery
- [x] User can double-tap as a shortcut to save an eatery
- [ ] User can see tags for cafes
  - [ ] User can filter places based on tags
- [ ] User can attach their own notes and photos to an eatery, such as their favorite menu items and pictures of food / atmosphere
- [x] User can see the travel duration between eateries using Google Distance Matrix API
- [x] User can change the travel mode between eateries to either driving (default), walking, or biking, and see the updated travel duration
- [x] User can specify and change how long they'd like to spend at each location on a trip
- [x] User can select "Begin Trip," which sends them local notifications reminding them when to leave for the next stop
  - [x] User can cancel an active trip to stop further notifications; if not cancelled, the app will automatically set the trip as inactive after the trip's duration has elapsed

### 2. Screen Archetypes

* Login Screen
   * User can login
   * User can be redirected to Registration Screen if they do not have an account
* Registration Screen
   * User can create a new account
   * User can be redirected to Login Screen if they already have an account
* Account Screen
    * User can logout here, and also change settings
* Maps / Search Screen
    * User can search for eateries and view their location on the map
    * Users can open a Cafe Details screen for a particular eatery
* Cafe Details Screen
    * User can see the rating, top 5 Google reviews, and photos of the restaurant
    * User can call the cafe, view its website in a browser, and get Google Maps navigation directions
    * User can save eateries to collections and/or trips, including with a double-tap
* Saved Places Screen
    * User can create and delete collections
    * User can view their collections of saved eateries
    * User can tap a collection to open its Collection Screen view
* Collection Screen
    * User can view a list of the eateries saved to the collection
    * User can tap an eatery to open its Cafe Details screen
* Trips Screen
    * User can create and delete trips
    * User can see all the trips they've created
    * User can plan trips between multiple cafes (using Google Maps API to determine walking/biking/driving distance between them), specifying how long they'd like to spend at each one

### 3. Navigation

**Tab Navigation** (Tab to Screen)

From left to right:
* Map / Search Screen
* Saved Places Screen
* Trips Screen
* Account Screen (login/logout/settings)

**Flow Navigation** (Screen to Screen)

* Login Screen
    * Registration Screen
    * Map Screen
* Registration Screen
    * Login Screen
    * Map Screen
* Map Screen
    * Search Screen 
    * Cafe Details Screen
* Saved Places Screen
    * Collection Screen
* Collection Screen
    * Cafe Details Screen
* Trips Screen
    * (Single) Trip Screen
* Account Screen
    * Login Screen

## Wireframes
<img src="/wireframes.jpg" width=800>

## Schema 
### Models:

#### User
| Property    | Type     | Description |
| ----------- | -------- | ----------- |
| email       | String | |
| username    | String | |
| password    | String | |
| name        | String | |
| pfp         | File | user's profile picture |
| collectionNames | Array | names of the user's saved collections |
| tripNames | Array | names of the user's trips |
| timePerStop | Integer | default min/stop on a trip |
| notifsOn | Boolean | whether the user has enabled notifications |
| isShowingBars | Boolean | whether the user wants to see bars in search results |
| searchHistory | Array | name, address, and placeID of user's 5 recent searches |

#### Collection
| Property    | Type     | Description |
| ----------- | -------- | ----------- |
| collectionName | String | user-defined name of collection |
| owner | Pointer to User object | user who created the collection |
| places | Array | array of cafe placeIDs |

#### Trip
| Property    | Type     | Description |
| ----------- | -------- | ----------- |
| tripName    | String | user-defined name of trip |
| owner       | Pointer to User object | user who created the trip |
| stops       | Array  | dictionary containing placeID, minutes spent, travel mode, and travel time to next stop |
| isActive    | Boolean | whether the trip is currently active (sending notifs) |

### Networking

#### Parse network requests by screen

* Login Screen
    * (Read/GET) Query User object
* Registration Screen
    * (Create/POST) Create new User object
* Search Screen
    * (Read/GET) Query logged in User object (for searchHistory, isShowingBars)
* Cafe Details Screen
    * (Read/GET) Query logged in User object (for collectionNames, tripNames)
    * (Read/GET) Query Collection object named "All" owned by current User
    * (Read/GET) Query Trip objects owned by current User
    * (Update/PUT) Add cafe's placeID to Collection object
    * (Update/PUT) Add cafe's placeID to Trip object
* Saved Places Screen
    * (Read/GET) Query all Collection objects owned by current User
    * (Create/POST) Create new Collection object
    * (Delete) Delete existing Collection
* Collection Screen
    * (Update/PUT) Remove cafe's placeID from Collection object
* Trips Screen
    * (Read/GET) Query all Trip objects owned by current User
    * (Create/POST) Create new Trip
    * (Delete) Delete existing Trip
* Trip Screen
    * (Update/PUT) Remove stop from Trip
    * (Update/PUT) Edit stop's duration and travel mode to next stop
    * (Update/PUT) Set Trip as active/inactive
* Account Screen
    * (Read/GET) Query logged in User object
    * (Update/PUT) Update user information (email, name, profile pic, etc.)

#### Existing API Endpoints

##### Google Maps API
- Base URL: [maps.googleapis.com/maps/api](https://maps.googleapis.com/maps/api)

| HTTP Verb | Endpoint | Description |
| --------- | -------- | ----------- |
| `GET`     | /place/details/json?place_id={placeID}&fields=reviews&key={key} | Fetch up to 5 place reviews |
| `GET`     | /distancematrix/json?origins=place_id:{originID}&destinations=place_id:{destinationID}&mode={travelMode}&key={key} | Calculate travel distance between 2 places |


