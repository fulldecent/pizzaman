#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();


target.delay(3)
captureLocalizedScreenshot("0-LandingScreen")

target.delay(1)
target.tap({x:274.50, y:166.50});
target.delay(1.5)
captureLocalizedScreenshot("1-GameStart")

target.delay(3)
captureLocalizedScreenshot("2-GameOver")
