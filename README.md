# README #

### What is this repository for? ###

This is the repository of Nevo-iOS version

### Contribution guidelines ###

1-Naming conventions :
Variable :
/**
Comments goeS here
*/
private var mNameOfTheVariable  (all Object variables should be private and start with an m.
If you want to get or set a variable, create a getter or setter)

Constant :
let NAME_OF_VARIABLE

Class :
​class NameOfClass {

}​
​(Why : Because if all variables are private, a variable won't be changed without your consent)​


​2- Optionals​ : https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html#//apple_ref/doc/uid/TP40014097-CH5-ID330

We should never use :
var mNameOfObject:TypeOfObject!

but always :
var mNameOfObject:TypeOfObject? or var mNameOfObject:TypeOfObject

​Then :
​
mNameOfObject?.someFunction()
or

if let nameOfObject = mNameOfObject {
//Do something witht he object
}

(Why ? Because using ObjectType! exposes to geart danger. We had a big big crash because of a variable initialised that way. It is too hard to know if it is null or not)
3- Everything which have a close relation to the UI, should be inside a View
Ex This shouldn't be inside a Controller :
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 120, 30))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = NSLocalizedString("stepGoalTitle", comment: "")
        titleLabel.font = UIFont.systemFontOfSize(25)
Everything that starts with UIXXXXX or ColorXXX should be done inside a View
(Why ? UI changes often, Controller much less often. So every thigns specific to teh appearance. Colors, Fonts, positions. Should be isolated from the rest of the code)
​4- Sync Controller
Normally, all bluetooth operations should go through the Sync controller.

If you do this inside a controller : ConnectionControllerImpl.sharedInstance
​Then there's a mistake.

(I was the first one to make this mistake)

(Why ? Because everything can happen about Bluetooth. Maybe the watch is not up to date, maybe we are in OTA mode. For all those reasons, only the SyncController is smart enough to do things with bluetooth)
​5- TODO
It is ok to leave //TODO in the code, but you should write your name on it
ex :

//TODO by Hugo

(Why ? So when I publish, I will contact you and check if we can publish even with this TODO​)

### Who do I talk to? ###

* Repo owner or admin
hugo@five-doors.com