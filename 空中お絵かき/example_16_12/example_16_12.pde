import processing.video.*;

// Variable for capture device
Capture video;

// A variable for the color we are searching for.
float trackColor_s;
float trackColor_h;
float trackColor_b;
color trackColor;
int old_closest_X = -1;
int old_closest_Y = -1;
int closest_X = -1;
int closest_Y = -1;
int w_ratio;
int h_ratio;
  
PGraphics g;

void setup() {
  size(1280,720);
  //String[] cameras = Capture.list();
  video = new Capture(this,640,360,15);
  video.start();
  // Start off tracking for green
  trackColor_s = -1;
  trackColor_h = -1;
  trackColor_b = -1;
  colorMode(HSB,360,100,100);
  g = createGraphics(width,height);
  g.beginDraw();
  g.colorMode(HSB,360,100,100);
  g.endDraw();
  w_ratio = width/video.width;
  h_ratio = height/video.height;
}

void track_color(){
  float worldRecord = 50; 
  //the threshold for "same color"
  //smaller worldRecord means more accurate tracking,
  //but less robust to noise.
  
  float d2_worldRecord =  50;//do not change it
  int count = 0;
  old_closest_X = closest_X;
  old_closest_Y = closest_Y;
  closest_X = -1;
  closest_Y = -1;
  // XY coordinate of closest color
  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      int loc = x + y*video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      float h = hue(currentColor);
      float s = saturation(currentColor);
      float b = brightness(currentColor);
      
      // Using euclidean distance to compare colors
      float d = s*s + trackColor_s*trackColor_s-2*s*trackColor_s*cos(radians(abs(h-trackColor_h)));
      float d2 = 0;
      if(old_closest_X>0){
          d2 = dist(old_closest_X,old_closest_Y,x,y);
          if(d2>d2_worldRecord) continue;
      }
      // If current color is more similar to tracked color than
      // closest color, save current location and current difference
      if (d <= worldRecord) {
        //worldRecord = d;
        closest_X += x;
        closest_Y += y;
        count++;
      }
    }
  }
  if(count>0){
    closest_X = (closest_X+1)/count;
    closest_Y = (closest_Y+1)/count;
  }
}

void draw() {
  // Capture and display the video
  if (video.available()) {
    video.read();
  }
  video.loadPixels();
  if(trackColor_h>0) track_color();
  if(closest_X>0 && old_closest_X>0){
    g.beginDraw();
    g.stroke(trackColor_h,100,100);
    g.strokeWeight(10);
    g.line(old_closest_X*w_ratio,old_closest_Y*h_ratio,closest_X*w_ratio,closest_Y*h_ratio);
    g.endDraw();
  }
  pushMatrix();
  scale(-1,1);
  image(video,-width,0,width,height);
  image(g,-width,0);
  popMatrix();
  
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = -mouseX/w_ratio + mouseY/h_ratio*video.width;
  trackColor = video.pixels[loc];
  trackColor_h = hue(trackColor);
  trackColor_s = saturation(trackColor);
  trackColor_b = brightness(trackColor);
  println("clicked");
  println(trackColor_h,trackColor_s,trackColor_b);
  old_closest_X = -1;
  old_closest_Y = -1;
  closest_X = -1;
  closest_Y = -1;
}

void keyPressed(){
  g.beginDraw();
  g.clear();
  g.endDraw();
  trackColor_s = -1;
  trackColor_h = -1;
  trackColor_b = -1;
  save( "hoge.png" );
}
