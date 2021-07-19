# Cafe Hopper

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Cafe Hopper (app name undecided) is an app that helps you plan routes to coffee shops and similar casual informal drinking and dining options around town.

### App Evaluation
- **Category:** Lifestyle, Travel
- **Mobile:** Portability would be key to making a concept like this work, since it is unlikely that people will tote a laptop from cafe to cafe. Thus, Cafe Hopper would make for a uniquely mobile experience that could not easily be replaced by a website. The app would incorporate maps and location, and possibly camera (if there is a feature to save your own photos to cafes that you've visited). Push notifications would also be relatively natural to incorporate, since the app could remind you of your scheduled plans.
- **Story:** Cafe Hopper allows users to fully experience the vibrant casual dining culture of anywhere, from an unfamiliar city to their own hometown.
- **Market:** The market for this app is broad, appealing mostly to relatively young city-dwellers or those living near downtown / urban regions with clusters of casual dining options.
- **Habit:** The average user would do a fair amount of both consuming and creating on the app: they consume when they check out cafe listings and information, and create when they add cafes to personal lists or plan and save cafe-hopping routes.
- **Scope:** Incorporating the Google Maps SDK would be the primary backend task. I believe that the core features of the app are of reasonable technical difficulty.  It would be great to be able to "tag" cafes with descriptors such as "historic," "newly-opened," "vegan-friendly," etc. to allow users to discover cafes better within the app. I anticipate that this tagging feature might not be straightforward, and may involve searching the reviews for key words or performing sentiment analysis. However, I believe that even with just the core features, Cafe Hopper will still be an interesting app both to build and use.

## Product Spec

### 1. User Stories

**Required Must-have Stories**
- [x] User can create a new account
- [x] User can login and logout
- [x] User can search for eateries
- [x] User can view the location of eateries on a map powered by Google Maps SDK
- [x] User can save (and unsave) eateries to custom collections (e.g. Favorites, Want to Visit)
- [x] User can create (and delete) collections of eateries
- [ ] User can view details of an eatery, such as its address, price level ($ to $$$$), rating, etc.
- [ ] User can see photos of an eatery
- [ ] User can create "trips": an ordered list of eateries that the user wants to visit in a single trip
- [ ] User can be redirected to the Google Maps website/app with preloaded navigation directions for a trip

**Optional Nice-to-have Stories**
- [ ] User has multiple options to create a new account (e.g. with email, Google, Facebook)
  - [ ] User can login with either username or email
- [ ] User can apply search filters (e.g. price level, rating)
- [ ] User can see tags for cafes
  - [ ] User can filter places based on tags
- [ ] User can be redirected to an eatery's website and call their phone number through the app
- [ ] User can read reviews, or review keywords, of an eatery
- [ ] User can double-tap as a shortcut to save an eatery
- [ ] User can attach their own notes and photos to an eatery, such as their favorite menu items and pictures of food / atmosphere
- [ ] User can see the walking/biking/driving distance between eateries using Google Maps API, specifying how long they'd like to spend at each location
- [ ] User can adjust account settings (e.g. email, username, profile pic, notifications)
- [ ] User can choose to be emailed/texted an itinerary for their trip
- [ ] User receives push notifications for cafe recommendations or reminders about a route they've planned

### 2. Screen Archetypes

* Login Screen
   * User can login
   * User can be redirected to Registration Screen if they do not have an account
* Registration Screen
   * User can create a new account
   * User can be redirected to Login Screen if they already have an account
* Account Screen
    * User can login/logout/register here, and also change settings
* Maps / Search Screen
    * User can view cafes / eateries based on current location / zipcode
    * User can search for & filter cafes based on keyword, price point, etc.
* Cafe Details Screen
    * User can see reviews and photos of the restaurant (perhaps posted to either Google, Yelp, or similar rating sites)
    * User can save eateries to lists / favorites -> possibly using double-tap feature
* Saved Places Screen
    * User can view lists of saved eateries
* Routes / Trips Screen
    * [optional feature] User can see routes/trips they've saved
    * User can plan trips between multiple cafes (using Google Maps API to determine walking/biking/driving distance between them), specifying how long they'd like to spend at each one

### 3. Navigation

**Tab Navigation** (Tab to Screen)

From left to right:
* Maps / Search Screen
* Saved Places Screen
* Possibly a middle "+" button to create a trip quickly? for symmetry
* Routes / Trips Screen
* Account Screen (login/logout/settings)

**Flow Navigation** (Screen to Screen)

* Login Screen
    * Registration Screen
    * Maps / Search Screen
* Registration Screen
    * Login Screen
    * Maps / Search Screen
* Account Screen
    * Login Screen
    * Registration Screen
    * [optional] Settings Screen
* Maps / Search Screen
    * Cafe Details Screen
* Cafe Details Screen
    * Back to the screen you came from
* Saved Places Screen
    * Cafe Details Screen
* Routes / Trips Screen
    * Cafe Details Screen (to see cafes on your trip)


## Wireframes
<img src="/wireframes.jpg" width=800>

## Schema 
### Models:

**User**
| Property    | Type     | 
| ----------- | -------- | 
| email       | NSString |
| username    | NSString |
| password    | NSString |
| name        | NSString |
| pfp         | PFFileObject |

**Cafe**
(properties TBD, based on Google Places SDK for iOS [GMSPlace](https://developers.google.com/maps/documentation/places/ios-sdk/reference/interface_g_m_s_place?authuser=0#a126c0feb110b9687c45dfb05ceb2731b) object)
| Property       | Type     | Description  |
| -------------- | -------- | ------------ |
| name           | NSString | name of cafe |
| placeId        | NSString | Google Maps SDK place ID |
| coordinates    | NSArray  | latitude-longitude location of cafe |
| address        | NSString | human-readable address of cafe |
| rating         | float    | average user rating from 1.0 to 5.0, 0.0 if no ratings |
| priceLevel     | NSInteger | price level, from 0 (free) to 4 (expensive) |

**Place Collection**
| Property    | Type     | Description |
| ----------- | -------- | ----------- |
| name        | NSString | user-defined name of collection |
| author      | Pointer to User object | user who created the collection |
| places      | NSArray  | array of cafes, each a pointer to a Cafe object |

**Trip**
| Property    | Type     | Description |
| ----------- | -------- | ----------- |
| name        | NSString | user-defined name of trip |
| author      | Pointer to User object | user who created the trip |
| stops       | NSArray  | array of stops, each a pointer to a Cafe object |

### Networking

**List of network requests by screen**

* Login Screen
    * (Read/GET) Query User object
* Registration Screen
    * (Create/POST) Create new User object
* Account Screen
    * (Read/GET) Query logged in User object
    * (Update/PUT) Update user information (email, name, profile pic, etc.)
    * (Delete) Delete existing User object
* Maps / Search Screen
* Cafe Details Screen
    * (Read/GET) Query Cafe object
    * (Read/GET) Query Place Collection objets containing current Cafe object
    * (Update/PUT) Update existing Place Collection (by adding/removing current Cafe object)
* Saved Places Screen
    * (Read/GET) Query all Place Collection objects
    * (Create/POST) Create new Place Collection object
    * (Update/PUT) Update existing Place Collection
    * (Delete) Delete existing Place Collection
* Routes / Trips Screen
    * (Read/GET) Query all Trip objects
    * (Create/POST) Create new trip
    * (Update/PUT) Update existing Trip object
    * (Delete) Delete existing trip

- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
