# object_detection_app

Object Detection app, built using Flutter and TensorFlow Lite (TFLite). This application is designed to provide 
an intuitive and efficient way to detect objects in real-time using our device's camera, capturing the detected image
and real time user guidance using overlay.

## Getting Started

The following tools were used in this project:

- [Tflite](https://www.tensorflow.org/lite)
- [Flutter](https://flutter.dev/)

## Dependencies Used

- [Camera](https://pub.dev/packages/camera) // For using camera
- [Google Fonts](https://pub.dev/packages/google_fonts) // For giving fonts to the text
- [intl](https://pub.dev/packages/intl) // for date formatting
- [Flutter Toast](https://pub.dev/packages/fluttertoast) // For showing toast
- [tflite_v2](https://pub.dev/packages/tflite_v2) //For object detection, used SSDMobileNet 

## Instruction to run app

1. Run the app by clicking the app_icon ( object_detection_app)
2. Splash screen will open and it will redirect to object listing screen
3. Object Listing screen will list the item from pretrained models list
4. For easy to select the item from list of object use search option.
5. If searched object is not available it shows like "No result Found" otherwise it will show the search result
6. choose the object, then click Get Started button it will redirect to the next screen that means the object detection screen
7. Before launching object detection screen,will ask permission for camera access
8. If camera access not provided the object detection will not work properly because it is mainly depends on camera
9. If camera access given, it will launch camera and start to detect objects
10. It will try to detect the object based in your selection from object list screen for 60 seconds ie, 1 minute
11. Real time guidance will show based on the camera position
12. The Guidance like Move closer to the object,"Move farther from the object", "Center the object in the frame", "Object in position" 
13. Follow the guidance until the guidance showing "Object in position"
14. "Center the object in the frame" - object detected and correct the camera position to detect properly
15. If the object is not detected within the 60 seconds of time, it will show a toast message like "Object not found!!.. Please choose another!!"
16. If the object detected, it will capture the image and navigate to the next screen
17. In the new screen it will shows the details like detected object name, date and time stamp
18. If you want to detect another object, click back button then it will open the object listing page and follow process flow from step number 5 to 17

## Use cases
Example 1: Object Detection - mouse

Detected Object: mouse
Accuracy: 73%
Screenshot:https://github.com/fathimashifna/object_detection_app/blob/master/mouse_medium_confidence.jpeg

Explanation: The model correctly identified the mouse in the image with a medium confidence level. The bounding box is tight around the object.


Example 2: Object Detection - Bottle

Detected Object: Bottle
Accuracy: 49%
Screenshot: https://github.com/fathimashifna/object_detection_app/blob/master/detected_object_image.jpeg
https://github.com/fathimashifna/object_detection_app/blob/master/bottle_low_confidence.jpeg

Explanation: The model correctly identified the bottle in the image with a lower confidence score compared to other objects it has been trained on.

Example 3: Object Detection - Table Lamp

Detected Object: Table Lamp
Screenshot: https://github.com/fathimashifna/object_detection_app/blob/master/lamp_not_detected.jpeg

Explanation: The model not identified the Table Lamp in the image.


## Demonstration Video
Video 1 :
    Selected Object detected - bottle with accuracy 74%.
    https://github.com/fathimashifna/object_detection_app/blob/master/detected.mp4
Video 2:
    Selected Object not available in the frame
    https://github.com/fathimashifna/object_detection_app/blob/master/not_detected.mp4
Video 3:
    Selected object not detected - mouse
    https://github.com/fathimashifna/object_detection_app/blob/master/not_in_frame.mp4

## Challenges faced
Gradle Update Issues
I faced challenges while updating Gradle in Android Studio. The build process failed due to version conflicts.

Solution:
I checked the error logs in Android Studio to identify the cause of the issue. Based on the logs, I was able to correct the error and successfully update Gradle.

---------------------------------------------------------------------------------------------------------------------------
Model Creation with TensorFlow
As a beginner in machine learning, I faced challenges while creating my model using TensorFlow. I struggled with understanding how to build and train the model effectively.

Solution:
To overcome this, I referred to online tutorials that provided detailed explanations and example code. These resources helped me understand how to set up the model, prepare the data, and train the model using TensorFlow.