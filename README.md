# Focusdays 2015 - eyes2drive iOS + watchOS App
Keep your eyes on the street while driving. 

This app alerts drowsy and distracted car drivers using face detection with camera. eyes2drive comes with an Apple Watch extension to show your trip events, to be able to start and stop your trip with via the Watch and most important get a Notification if a RED alert (long distraction) occured.

eyes2drive is using state-of-the-art face detection algorithms using OpenCV algorithms to detect the face, eyes closing and head distraction.

eyes2drive is showing the current position of the car while driving including Alert information. In debug mode it is possible to see the current image of the driver

features
* detect face / eyes / nose using face detection algorithms using OpenCV and the iOS camera using [HAAR cascade algorithms from OpenCV](http://docs.opencv.org/doc/tutorials/objdetect/cascade_classifier/cascade_classifier.html)
* use threshold technics to detect if eyes are closed
* show map with current location including minimal debug information (face, eyes, events and debug options for detection algorithms)
* send distraction events from iOS eyes2drive camera App to iOS eyes2drive viewer App via Bluetooth Low Energy connection
* iOS Watch App contains local Notifications on Watch, animated Glances to show current score, 3 different pages in iOS Watch App to show more details of the score, list of all events
* solution does not need internet connection (except if map with location shall be shown)
* compatible starting >iOS 8.4 + iOS 9 and >watchOS2 (watchOS1 is not supported anymore)

installation
* install eyes2drive App on your 2nd Smartphone acting as a camera
* attach your smartphone in the car to a smartphone holder
* install eyes2drive viewer App on your iPhone connected with your Apple Watch

configuration
* configure your bluetooth channel: 1 out of 8 in your settings in both apps (only for test purposes, not valid for production)
* start your eyes2drive camera App
* start your eyes2drive viewer App in the background of our iPhone

start
* press the "start" button the eyes2drive camera App
* your iPhone with Apple Watch shall be in your pocket / locked - DON'T USE IT - it is too dangerous


further features, but not implemented
* integrate eyes-blinking rate in score
* integrate sound (dB) of car into score
* detect if car is driving (auto-pause) or not
* store events in iCloud
* display history of trips
* show scoring of historical trips
* ... 
* and many many more ideas :-)

have fun with our FocusDays 2015 eyes2drive App

your team
Lolo, Anton, Bernhard, Dani, Michael, Rémy
