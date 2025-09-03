## Serializer Demo

Simple demonstration of how to use an AsyncStream as a way of lining up asynchronous events to be synchronously serial in Swift Concurrency.

## How to Use the Demo

Run the project. Tap the Push bar button; now you are on the Serializer screen. Tap the main button several times quickly and watch the Xcode console. You will see that the button tap values are not sent to the Printer object until all previously generated button tap values have been processed by the long-running process.

Alternatively, tap the main button several times quickly, and then tap the Cancel button. You will see that the whole queue of button tap events is thrown away and the Serializer stops.

Alternatively, tap the main button several times quickly, and then pop back to the app's first screen with the Back button. You will see that this is just like the Cancel button. This proves that there is no retain cycle.
