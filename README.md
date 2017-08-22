# Pre-work - *Tipper*

**Tipper** is a tip calculator application for iOS.

Submitted by: **Jeremy Broutin**

Time spent: **7.5** hours spent in total

## User Stories

The following **required** functionality is complete:

* [X] User can enter a bill amount, choose a tip percentage, and see the tip and total values.
* [X] Settings page to change the default tip percentage.

The following **optional** features are implemented:
* [X] UI animations
* [X] Remembering the bill amount across app restarts (if <10mins).
* [X] Using locale-specific currency and currency thousands separators.
* [X] Making sure the keyboard is always visible and the bill amount is always the first responder. This way the user doesn't have to tap anywhere to use this app. Just launch the app and start typing. [see additional features]

The following **additional** features are implemented:

* [X] Update constraints when keyboard is displayed to prevent hiding UI elements.
* [X] Add custom Done button to Decimal keyboard.
* [X] Offer 2 color theme choices in settings.
* [X] Enforce textfield formatting (eg: 130.69 is valid, 125.5.2 is not)

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='https://im2.ezgif.com/tmp/ezgif-2-e2e3377df5.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [Ezgif](https://im2.ezgif.com).

## Project Analysis

As part of your pre-work submission, please reflect on the app and answer the following questions below:

**Question 1**: "What are your reactions to the iOS app development platform so far? How would you describe outlets and actions to another developer? Bonus: any idea how they are being implemented under the hood? (It might give you some ideas if you right-click on the Storyboard and click Open As->Source Code")

**Answer:**
Apple APIs are pretty powerful and give developers the necessary tools to create beautiful interfaces, but also handle networking and storage (in our case via the UserDefaults for instance). The Swift language is very "intuitive" with a syntax close to the regular human language, while also being safer than its predecessor Objective-C (with the introduction of Optionals for instance). Swift hides a lot of the language complexity from the developer, which greatly simplify and speed up code writing.
An example of this would be about IBOutlets (interface builder outlets) which are connecting a property to an object (aka a reference to this object), or IBActions which similarly connect a function in response to an interaction with the refered object. Note that an IBOutlet does not need to exist to be able to set an IBAction (if you do not need to act on the object itself, such as changing its text, color, frame, etc etc).
Under the hood, Swift takes care a creating an instance variable as well as setting up getters and setter, An IBOutlet allows a developer to modify the refered object programmatically or using the Attributes Inspector in the Xcode interface. 

Question 2: "Swift uses [Automatic Reference Counting](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-ID49) (ARC), which is not a garbage collector, to manage memory. Can you explain how you can get a strong reference cycle for closures? (There's a section explaining this concept in the link, how would you summarize as simply as possible?)"

**Answer:**
A strong reference cycle happens when two objects are poiting at each other using a strong reference. For instance, when a Son object has a "mother" property pointing to a Mother object, which itself has a "son" property pointing to the Son object. If both property are set with strong, it is impossible for ARC to deallocate any of the two objects from memory, since there is always a strong reference existing from the other.
This strong cycle reference might also happen in closure, when you reference a self property basically creating the loop describe above on your single object (the object has a reference to the closure and the closure (which is a self contained block) to the object). The solution here is similar to how you solve the Mother-Son example above: you need to explictly declare the reference to self in the closure as a weak reference.
Because the reference to self in the closure is now weak, the closure does not retain it and allows ARC to safely deinitialize self.


## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
