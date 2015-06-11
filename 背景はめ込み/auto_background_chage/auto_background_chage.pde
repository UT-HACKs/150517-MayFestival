import processing.video.*;
PImage background;
// Variable for capture device
Capture video;

// A variable for the color we are searching for.
void setup() {
  size(640,360);
  String[] cameras = Capture.list();
  video = new Capture(this,640,360,15);
  video.start();
  colorMode(HSB,360,100,100);
  // Start off tracking for green
}

void draw() {
  int black_bright_threshold = 4;
  int black_saturate_threshold = 4;  
  int color_threshold = 200;
  //change three params above
  
  // Capture and display the video
  if (video.available()) {
    video.read();
  }
  video.loadPixels();
  PImage img = loadImage("test.jpg");
  img.resize(video.width,video.height);
  // Before we begin searching, the "world record" for closest color is set to a high number that is easy for the first pixel to beat.
  // XY coordinate of closest color
  
  // Begin loop to walk through every pixel
  float worldrecord = 0;
  if(background != null){
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      int loc = x + y*video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      color backColor = background.get(x,y);
      float b1 = brightness(currentColor);
      float b2 = brightness(backColor);
      float s1 = saturation(currentColor);
      float s2 = saturation(backColor);
      if(b1<black_bright_threshold && b2<black_bright_threshold
      && s1<black_saturate_threshold && s2<black_saturate_threshold) continue;
      
      
      float h1 = hue(currentColor);
      float h2 = hue(backColor);
      float d = s1*s1 + s2*s2-2*s1*s2*cos(radians(abs(h1-h2)));
      if(d>color_threshold){
        img.set(x,y,currentColor);
      }
      // Using euclidean distance to compare colors
    }
  }
  println(worldrecord);
  }
  pushMatrix();
  scale(-1,1);
  if(background == null){
    image(video,-video.width,0);
  }else{
    image(img,-img.width,0);
  }
  popMatrix();
  
}



void mousePressed() {
  if (video.available()) {
    video.read();
  }
  background = new PImage(640,360);
  video.loadPixels();
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      int loc = x + y*video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      color backColor = background.get(x,y);
      background.set(x,y,currentColor);
    }
  }
}

void keyPressed() {
  if ( key == ' ' ) {
    save( "hoge.png" );
  }
}
