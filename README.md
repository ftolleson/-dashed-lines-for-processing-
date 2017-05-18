# Dashed Lines for Processing

Couldn't be any simpler: just a [Processing](http://processing.org) library to draw geometry with dashed strokes!

### Installation
You can install the library from Processing's Contribution Manager.

Alternatively, you can extract the distribution file on your Processing's sketchbook. Download `dashedlines.zip` from the `dist` folder. Now go to your sketchbook folder (in Windows it will be something like `C:\Users\JohnDoe\Documents\Processing`), go inside `libraries`, and extract the contents of the `.zip` file to a folder called `dashedlines`. Once finished, your library should be found under: `C:\Users\JohnDoe\Documents\Processing\libraries\dashedlines\library\dashedlines.jar`.

Still having trouble? [Read this](https://github.com/processing/processing/wiki/How-to-Install-a-Contributed-Library).

### Hello Dash
Let's take a look at a basic example on how to draw a simple dashed line now:

```java
// Import the library
import garciadelcastillo.dashedlines.*;

// Declare the main DashedLines object
DashedLines dash;

void setup() {
  // Initialize it, passing a reference to the current PApplet
  dash = new DashedLines(this);

  // Set the dash-gap pattern in pixels
  dash.pattern(10, 5);
}

void draw() {
  background(127);

  // Call the line method of the 'dash' object,
  // as if it was Processing's native
  dash.line(10, 10, 90, 90);
  dash.line(10, 90, 90, 10);
}

```

And voilà!

![Hello Dash!](https://github.com/garciadelcastillo/-dashed-lines-for-processing-/blob/master/assets/hello_dash.png "Hello Dash!")



Drawing dashed lines is now as easy as instantiating a DashedLines object in your sketch, and using it



- Intro / Description
- Installation
- Hello Dash
- Features: Processing-like API, inherited styling
- More examples (gifs?)
- Contribute: link to TODO list
- Acknowledgments