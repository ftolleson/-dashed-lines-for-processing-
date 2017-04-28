
float DASH_LENGTH;
float DASH_SPACING;
float CIRCLE_EPSILON = 0.1;
float[] dashes;

void dash(float d1, float d2) {
  DASH_LENGTH = d1;
  DASH_SPACING = d2;
  dashes = new float[2];
  dashes[0] = d1;
  dashes[1] = d2;
}

void dash(float d1, float d2, float d3, float d4) {
  dashes = new float[4];
  dashes[0] = d1;
  dashes[1] = d2;
  dashes[2] = d3;
  dashes[3] = d4;
}


void dashLine(float x1, float y1, float x2, float y2) {
  PVector l = new PVector(x2 - x1, y2 - y1);
  PVector d = (new PVector(x2 - x1, y2 - y1)).setMag(DASH_LENGTH);
  PVector s = (new PVector(x2 - x1, y2 - y1)).setMag(DASH_SPACING);

  float dx = l.x;
  float dy = l.y;
  float ddx = d.x;
  float ddy = d.y;
  float sdx = s.x;
  float sdy = s.y;

  int spaceDashCount = abs(dx) > abs(dy) ? 
    int( dx / (ddx + sdx) ) : 
    int( dy / (ddy + sdy) );

  float x = x1, y = y1;

  // Draw full dash + spaces 
  for (int i = 0; i < spaceDashCount; i++) {
    line(x, y, x + ddx, y + ddy);
    x += ddx + sdx;
    y += ddy + sdy;
  }

  // Figure out how to end the line
  if (abs(ddx) < abs(x2 - x)) {
    line(x, y, x + ddx, y + ddy);
  } else {
    line(x, y, x2, y2);
  }
}

void dashRect(float a, float b, float c, float d) {
  int rectMode = getGraphics().rectMode;

  // From Processing's core
  float hradius, vradius;
  switch (rectMode) {
  case CORNERS:
    break;
  case CORNER:
    c += a; 
    d += b;
    break;
  case RADIUS:
    hradius = c;
    vradius = d;
    c = a + hradius;
    d = b + vradius;
    a -= hradius;
    b -= vradius;
    break;
  case CENTER:
    hradius = c / 2.0f;
    vradius = d / 2.0f;
    c = a + hradius;
    d = b + vradius;
    a -= hradius;
    b -= vradius;
  }

  if (a > c) {
    float temp = a; 
    a = c; 
    c = temp;
  }

  if (b > d) {
    float temp = b; 
    b = d; 
    d = temp;
  }

  // Draw the underlying fill props
  pushStyle();
  noStroke();
  quad(a, b, c, b, c, d, a, d);  // since we already did the calculations, quad is faster than rect()
  popStyle();

  // Draw rect lines (quick and dirty) 
  dashQuad(a, b, c, b, c, d, a, d);
}

void dashQuad(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  pushStyle();
  noStroke();
  quad(x1, y1, x2, y2, x3, y3, x4, y4);
  popStyle();

  dashLine(x1, y1, x2, y2);
  dashLine(x2, y2, x3, y3);
  dashLine(x3, y3, x4, y4);
  dashLine(x4, y4, x1, y1);
}

void dashTriangle(float x1, float y1, float x2, float y2, float x3, float y3) {
  pushStyle();
  noStroke();
  triangle(x1, y1, x2, y2, x3, y3);
  popStyle();

  dashLine(x1, y1, x2, y2);
  dashLine(x2, y2, x3, y3);
  dashLine(x3, y3, x1, y1);
}



void dashEllipse(float a, float b, float c, float d) {
  int ellipseMode = getGraphics().ellipseMode;

  // From Processing's core, CORNER-oriented vars
  float x = a;
  float y = b;
  float w = c;
  float h = d;

  if (ellipseMode == CORNERS) {
    w = c - a;
    h = d - b;
  } else if (ellipseMode == RADIUS) {
    x = a - c;
    y = b - d;
    w = c * 2;
    h = d * 2;
  } else if (ellipseMode == DIAMETER) {  // == CENTER
    x = a - c/2f;
    y = b - d/2f;
  }

  if (w < 0) {  // undo negative width
    x += w;
    w = -w;
  }

  if (h < 0) {  // undo negative height
    y += h;
    h = -h;
  }
  float w2 = 0.5 * w, h2 = 0.5 * h;

  // Compute theta parameters for start-ends of dashes and gaps
  FloatList ts = new FloatList();  // TODO: precompute the size of the t array and create it as an array directly
  int id = 0;
  float run = 0;
  float t = 0;
  float dt = 0.01;
  float samples = Math.round(TAU / dt);
  float len = ellipseCircumference(w2, h2, 0, dt);
  float nextL = 0;

  //println("start: " + millis());
  for (int i = 0; i < samples; i++) {
    run += ellipseArcDifferential(w2, h2, t, dt);
    if ((int) run >= nextL) {
      ts.append(t);
      nextL += dashes[id % dashes.length];
      id++;
    }
    t += dt;
  }
  //println("end: " + millis());
  float[] tsA = ts.array();  // see TODO above

  // Draw the fill part
  pushStyle();
  noStroke();
  ellipseMode(CORNER);  // all correct vars are already calculated, so why not use them...? :)
  ellipse(x, y, w, h);  
  popStyle();

  // Draw dashes
  pushStyle();
  noFill();
  ellipseMode(CORNER);
  for (int i = 0; i < tsA.length; i += 2) {
    if (i == tsA.length - 1) {
      arc(x, y, w, h, tsA[i], TAU);  // TODO: does this account for 2+ dash/gaps?
    } else {
      arc(x, y, w, h, tsA[i], tsA[i+1]);
    }
  }
  popStyle();
}

// Create a dashed arc using Processing same function signature
// (note that start/stop here refer to the THETA parameter, NOT THE POLAR ANGLE)
void dashArc(float a, float b, float c, float d, float start, float stop) {
  dashArc(a, b, c, d, start, stop, 0);
}


// Create a dashed arc using Processing same function signature
// (note that start/stop here refer to the THETA parameter, NOT THE POLAR ANGLE)
void dashArc(float a, float b, float c, float d, float start, float stop, int mode) {
  int ellipseMode = getGraphics().ellipseMode;

  // From Processing's core, CORNER-oriented vars
  float x = a;
  float y = b;
  float w = c;
  float h = d;

  if (ellipseMode == CORNERS) {
    w = c - a;
    h = d - b;
  } else if (ellipseMode == RADIUS) {
    x = a - c;
    y = b - d;
    w = c * 2;
    h = d * 2;
  } else if (ellipseMode == DIAMETER) {  // == CENTER
    x = a - c/2f;
    y = b - d/2f;
  }

  if (w < 0) {  // undo negative width
    x += w;
    w = -w;
  }

  if (h < 0) {  // undo negative height
    y += h;
    h = -h;
  }
  float w2 = 0.5 * w, h2 = 0.5 * h;

  // make sure the loop will exit before starting while
  if (!Float.isInfinite(start) && !Float.isInfinite(stop)) {
    // ignore equal and degenerate cases
    if (stop > start) {
      // make sure that we're starting at a useful point
      while (start < 0) {
        start += TWO_PI;
        stop += TWO_PI;
      }

      if (stop - start > TWO_PI) {
        // don't change start, it is visible in PIE mode
        stop = start + TWO_PI;
      }

      // TODO: implement modes: CHORD, PIE

      // Compute theta parameters for start-ends of dashes and gaps
      FloatList ts = new FloatList();  // TODO: precompute the size of the t array and create it as an array directly
      int id = 0;
      float run = 0;
      float t = start;
      float dt = 0.01;
      float samples = Math.round((stop - start) / dt);
      float len = ellipseCircumference(w2, h2, 0, dt);
      float nextL = 0;

      //println("start: " + millis());
      for (int i = 0; i < samples; i++) {
        run += ellipseArcDifferential(w2, h2, t, dt);
        if ((int) run >= nextL) {
          ts.append(t);
          nextL += dashes[id % dashes.length];
          id++;
        }
        t += dt;
      }
      //println("end: " + millis());
      float[] tsA = ts.array();  // see TODO above

      // Draw the fill part
      pushStyle();
      noStroke();
      ellipseMode(CORNER);  // all correct vars are already calculated, so why not use them...? :)
      arc(x, y, w, h, start, stop);  
      popStyle();

      // Draw dashes
      pushStyle();
      noFill();
      ellipseMode(CORNER);
      for (int i = 0; i < tsA.length; i += 2) {
        if (i == tsA.length - 1) {
          arc(x, y, w, h, tsA[i], stop);  // TODO: does this account for 2+ dash/gaps?
        } else {
          arc(x, y, w, h, tsA[i], tsA[i+1]);
        }
      }
      popStyle();
    }
  }
}


// Create a dashed arc using Processing same function signature,
// however using start/stop as POLAR ANGLES, not THETA parameters.
// This is not consistent with Processing's implementation, 
// but just feels right geometrically... ;)
void dashArcPolar(float a, float b, float c, float d, float start, float stop, int mode) {

  int ellipseMode = getGraphics().ellipseMode;
  float w = c;
  float h = d;
  if (ellipseMode == CORNERS) {
    w = c - a;
    h = d - b;
  } else if (ellipseMode == RADIUS) {
    w = c * 2;
    h = d * 2;
  } 
  if (w < 0) {  // undo negative width
    w = -w;
  }
  if (h < 0) {  // undo negative height
    h = -h;
  }
  float w2 = 0.5 * w;
  float h2 = 0.5 * h;
  
  float thetaStart = ellipsePolarToTheta(w2, h2, start);
  float thetaStop = ellipsePolarToTheta(w2, h2, stop);
  dashArc(a, b, c, d, thetaStart, thetaStop, mode);
}