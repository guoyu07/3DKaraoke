//THERE ARE 3 PLACES IN THE CODE YOU NEED TO LOOK WHEN YOU ADD A SONG THEY ARE LABELLED SONG_PLACE SO YOU CAN USE FIND


import kinectOrbit.*;
import controlP5.*;
//variable declaration

import processing.opengl.*;
import SimpleOpenNI.*;
import KinectOrbit.*;
import ddf.minim.*;
Minim minim;

//our song object instance
Song song;
Song song1;
Song song2;
Song song3;
Song song4;


boolean useOpenNI=true;

//initialize orbit and camera
KinectOrbit myOrbit;
SimpleOpenNI kinect1;
SimpleOpenNI kinect2;

String turnTableAngle = "0";

//initialize arraylists for the point cloud
ArrayList<PVector> scanPoints = new ArrayList<PVector>();
ArrayList<PVector> scanColors = new ArrayList<PVector>();
ArrayList<PVector> objectPoints = new ArrayList<PVector> ();
ArrayList<PVector> objectColors = new ArrayList<PVector> ();

//variable for selecting current song
int songChooser=10;
//vars for gui
boolean drawGui=true;
float transX = 212.12;
float transY = -3000;
float transZ = 2212.12;
float transX1 = 272.72;
float transY1 = -3000;
float transZ1 = 1000;
float textZ = 570;
float angle1 = PI;
float angle2 = 0;
float _speed = 4;
PFont font;
float rotCentreX;
float rotCentreY;
float rotCentreZ;

boolean rotateScene=true;

DropdownList p1;
//a rotation variable
float degrs=0;

ControlP5 cp5 = null;

//scanning space variables (in millimeters) 
float baseHeight = -1701;
float modelWidth = 3048;
float modelHeight = 2438;
PVector axis = new PVector(0, baseHeight, 1701 );
//scan parameters in pixels
int scanLines = 400;
//this is the variable which controls how many pixels we draw 3 draws every 3rd pixel e
int scanRes = 2;
boolean scanning;
int numCameras = 2;
int currentShot = 0;
int enabled = 0;

public void setup()
{

  size(1280, 1024, OPENGL);
  cp5 = new ControlP5(this);

  //setup GUI sliders etc
  cp5.addTab("Display");
  cp5.addSlider("transX", -3000, 3000).setValue(212.12).linebreak().moveTo("Display");
  cp5.addSlider("transY", -3000, 3000).setValue(-3000).linebreak().moveTo("Display");
  cp5.addSlider("transZ", -3000, 3000).setValue(2212.12).linebreak().moveTo("Display");
  cp5.addSlider("transX1", -3000, 3000).setValue(272.72).linebreak().moveTo("Display");
  cp5.addSlider("transY1", -3000, 3000).setValue(-3000).linebreak().moveTo("Display");
  cp5.addSlider("transZ1", -3000, 3000).setValue(1000).linebreak().moveTo("Display");
  cp5.addSlider("angle1", 0, TWO_PI).setValue(PI).linebreak().moveTo("Display");
  cp5.addSlider("angle2", 0, TWO_PI).setValue(0).linebreak().moveTo("Display");
  cp5.addSlider("textZ", -3000, 3000).setValue(570).linebreak().moveTo("Display");
  cp5.addSlider("_speed", 1, 15).setValue(4).linebreak().moveTo("Display");
  cp5.addSlider("rotCentreX", -3000, 3000).setValue(30).linebreak().moveTo("Display");
  cp5.addSlider("rotCentreY", -3000, 3000).setValue(1000).linebreak().moveTo("Display");
  cp5.addSlider("rotCentreZ", -3000, 3000).setValue(575).linebreak().moveTo("Display");
  cp5.addToggle("rotateScene").setPosition(10, 50);

  p1 = cp5.addDropdownList("songs", 10, 100, 100, 120);

  // SONG_PLACE HERE IS WHERE WE ADD SONGS TO THE GUI
  p1.addItem("Beat It", 0);
  p1.addItem("Magic Moments", 1);
  p1.addItem("Here Comes The Sun", 2);
  p1.addItem("Born To Be Wild", 3);
  p1.addItem("Space Oddity", 4);

  //orbit
  myOrbit = new KinectOrbit(this, 0, "kinect");
  myOrbit.drawCS(true);
  myOrbit.drawGizmo(true);
  myOrbit.setCSScale(200);
  myOrbit.drawGround(true);
  if (useOpenNI) {
    //simple open ni
    kinect1 = new SimpleOpenNI(0, this);
    kinect1.setMirror(false);
    kinect1.enableDepth();
    kinect1.enableRGB();
    kinect1.alternativeViewPointDepthToImage();

    println("camera 1 enabled");
    //1 is the device index
    kinect2 = new SimpleOpenNI(0, this);
    kinect2.setMirror(true);
    kinect2.enableDepth();
    kinect2.enableRGB();
    kinect2.alternativeViewPointDepthToImage();
  }
  println("camera 2 enabled");

  font = loadFont("Serif-48.vlw");
  textFont(font, 48);

  // SONG_PLACE HERE IS WHERE WE MAKE THE SONG OBJECTS 
  song= new Song("beat_inst.mp3", "Beat It", "lyrics.txt", "timings.txt", width/2, height/2);
  song1= new Song("magic_moments.mp3", "Magic Moments", "magic_text.txt", "magic_time.txt", width/2, height/2);
  song2= new Song("sun.mp3", "Here Comes The Sun", "sun.txt", "sun_times.txt", width/2, height/2);
  song3= new Song("born.mp3", "Born To Be Wild", "born.txt", "born_times.txt", width/2, height/2);
  song4= new Song("space.mp3", "Space Oddity", "space.txt", "space_time.txt", width/2, height/2);

  minim = new Minim(this);
  //START THE FIRST SONG
/*  song.start();

  song1.start();
  song2.start();
  song3.start();
  song4.start();

  song1.pause();
  song2.pause();
  song3.pause();
  song4.pause();*/
}

public void draw()
{
  background(0);
  //kinect1.update();
  if (useOpenNI) {
    pushMatrix();

    // update all the cameras
    SimpleOpenNI.updateAll();
    //refresh background
    

    myOrbit.pushOrbit(this); 
    //translate matrix to rotation centre
    translate( rotCentreX, rotCentreY, rotCentreZ);
    //rotate
    rotateY(degrs);
    //no rotate back aagain
    translate(-rotCentreX, -rotCentreY, -rotCentreZ);


    updateObject(scanLines, scanRes);

    if (scanning) 
    {
      scan();
    }

    drawObjects();
    drawBoundingBox();

    if (enabled == 0); 
    {
      kinect1.drawCamFrustum(); 
      kinect2.drawCamFrustum();
    }
    myOrbit.popOrbit(this);
    popMatrix();
  }
  cp5.draw();
  // SONG_PLACE HERE IS WHERE WE PLAY AND DISPLAY THE SONGS
  if (songChooser==0) {
    song.check();
    song.display();
  }
  else if (songChooser==1) {
    song1.check();
    song1.display();
  }
  else if (songChooser==2) {
    song2.check();
    song2.display();
  }
  else if (songChooser==3) {
    song3.check();
    song3.display();
  }
  else if (songChooser==4) {
    song4.check();
    song4.display();
  }
  if (rotateScene) {
    degrs+=0.1;
  }
}

void drawObjects()
{
  pushStyle();
  strokeWeight(4);
  float angle = map(Integer.valueOf(turnTableAngle), 0, 360, 0, 2*PI);

  pushMatrix();


  for (int i=1; i < objectPoints.size(); i++)
  {
    stroke(objectColors.get(i).x, objectColors.get(i).y, objectColors.get(i).z);
    point(objectPoints.get(i).x, objectPoints.get(i).y, objectPoints.get(i).z);
  }

  for (int i=1; i < scanPoints.size(); i++)
  {
    // if(i>scanPoints.size()/2&&i<(scanPoints.size()/2)+20) println( scanPoints.get(i));
    stroke(scanColors.get(i).x, scanColors.get(i).y, scanColors.get(i).z);
    point(scanPoints.get(i).x, scanPoints.get(i).y, scanPoints.get(i).z);
  }
  popMatrix();
  popStyle();
}

void updateObject(int scanWidth, int step)
{
  //println("updating objects");

  int index;
  PVector realWorldPoint;
  scanPoints.clear();
  scanColors.clear();
  //reset rotation angle and translation axis
  float angle =angle1;//= map(Integer.valueOf(0), 0, 360, 0, 2*PI);
  // axis = new PVector(0, baseHeight, 1701 );

  axis = new PVector(transX, transY, transZ );
  // if (enabled == 0)
  // {

  int xMin = (int) (kinect1.depthWidth() / 2 - scanWidth/2);
  int xMax = (int) (kinect1.depthWidth() / 2 + scanWidth/2);

  for (int y = 0; y < kinect1.depthHeight(); y+= step)
  {
    for (int x = xMin; x < xMax; x+= step)
    {
      index = x + (y *kinect1.depthWidth());
      realWorldPoint = kinect1.depthMapRealWorld()[index];
      color pointCol = kinect1.rgbImage().pixels[index];

      if (realWorldPoint.y < modelHeight + baseHeight && realWorldPoint.y  > baseHeight)
      {
        if (abs(realWorldPoint.x - axis.x ) < modelWidth /2 )
        {
          //check x
          if (realWorldPoint.z < axis.z + modelWidth / 2 && realWorldPoint.z > axis.z - modelWidth/2)
          {
            //check z
            PVector rotatedPoint;

            realWorldPoint.z -= axis.z;
            realWorldPoint.x -= axis.x;
            rotatedPoint = vecRotY(realWorldPoint, angle1);

            scanPoints.add(rotatedPoint.get());
            scanColors.add(new PVector(red(pointCol), green(pointCol), blue(pointCol)));
          }
        }
      }
    }
  }
  //  }
  // else
  // {
  angle =angle2;// map(Integer.valueOf(180), 0, 360, 0, 2*PI);
  // axis = new PVector(0, baseHeight, 1050);
  axis = new PVector(transX1, transY1, transZ1 );

  int xMin2 = (int) (kinect2.depthWidth() / 2 - scanWidth/2);
  int xMax2 = (int) (kinect2.depthWidth() / 2 + scanWidth/2);

  for (int y = 0; y < kinect2.depthHeight(); y+= step)
  {
    for (int x = xMin2; x < xMax2; x+= step)
    {
      index = x + (y *kinect2.depthWidth());
      realWorldPoint = kinect2.depthMapRealWorld()[index];
      color pointCol = kinect2.rgbImage().pixels[index];

      if (realWorldPoint.y < modelHeight + baseHeight && realWorldPoint.y  > baseHeight)
      {
        if (abs(realWorldPoint.x - axis.x ) < modelWidth /2 )
        {
          //check x
          if (realWorldPoint.z < axis.z + modelWidth / 2 && realWorldPoint.z > axis.z - modelWidth/2)
          {
            //check z
            PVector rotatedPoint;

            realWorldPoint.z -= axis.z;
            realWorldPoint.x -= axis.x;
            rotatedPoint = vecRotY(realWorldPoint, angle2);

            scanPoints.add(rotatedPoint.get());
            scanColors.add(new PVector(red(pointCol), green(pointCol), blue(pointCol)));
          }
        }
      }
    }
  }
  //  }
}

void scan()
{
  println("scanning");
  println(currentShot);
  println("current angle: " + turnTableAngle);

  for (PVector v: scanPoints)
  {
    boolean newPoint = true;
    for (PVector w : objectPoints)
    {
      if (v.dist(w) < 1)
        newPoint = false;
    }

    if (newPoint)
    {
      objectPoints.add(v.get());
      int index = scanPoints.indexOf(v);
      println("point index: " + index);
      objectColors.add(scanColors.get(index).get());
    }
  }

  if (currentShot < numCameras-1)
  {
    println("switching to the next camera");
    currentShot++;
    //moveTable(shotNumber[currentShot]);
    switchCamera(currentShot);
    //println(currentShot);
    //println(shotNumber);
  }
  else {
    scanning = false;
    println("done scanning");

    println("export the .ply");
    // exportPly('0');
  }

  //arrived = false;
}

void drawBoundingBox()
{
  stroke(255, 0, 0);
  line(axis.x, axis.y, axis.z, axis.x, axis.y+100, axis.z);
  noFill();
  pushMatrix();
  translate(axis.x, axis.x+baseHeight+modelHeight/2, axis.z);
  box(modelWidth, modelHeight, modelWidth);
  popMatrix();
}

PVector vecRotY(PVector vecIn, float phi)
{
  //rotate the vector around the y-axis
  PVector rotatedVec = new PVector();
  rotatedVec.x = vecIn.x * cos(phi) - vecIn.z * sin(phi);
  rotatedVec.z = vecIn.x *sin(phi) + vecIn.z *cos(phi);
  rotatedVec.y = vecIn.y;

  return rotatedVec;
}

void moveTable(float angle)
{
  //choose the right camera
}

void switchCamera(int cam)
{
  if (cam == 0 && enabled != 0)
  {
    enabled = 0;
    turnTableAngle = "0";
  }
  else if (cam == 1 && enabled != 1)
  {
    enabled = 1; 
    turnTableAngle = "180";
    axis = new PVector(0, baseHeight, 1050);
  }
}


public void keyPressed()
{
  switch(key)
  {
  case 'r': 
    switchCamera(0);
    println("switching camera to camera 1");
    scanning = false;
    break;
  case 'l': 
    switchCamera(1);
    println("switching camera to camera 2");
    scanning = false;
    break;
  case 's':
    println("clear the objectPoints arrayList for the scan");
    objectPoints.clear();
    objectColors.clear();
    currentShot = 0;
    scanning = true;
    //arrived = false;
    break;
  case 'e':
    println("export the .ply");
    // exportPly('0');
    break;

  case 'g':
    drawGui=!drawGui;
    // exportPly('0');
    break;
  }
}

void exportPly(char key) {
  PrintWriter output;
  String viewPointFileName;
  viewPointFileName = "MyOrbit" + key + ".ply";
  output = createWriter(dataPath(viewPointFileName));

  output.println("ply");
  output.println("format ascii 1.0");
  output.println("comment This is your Processing ply file");
  output.println("element vertex " + (objectPoints.size()-1));
  output.println("property float x");
  output.println("property float y");
  output.println("property float z");
  output.println("property uchar red");
  output.println("property uchar green");
  output.println("property uchar blue");
  output.println("end_header");

  for (int i = 0; i < objectPoints.size() - 1; i++) {
    output.println((objectPoints.get(i).x / 1000) + " "
      + (objectPoints.get(i).y / 1000) + " "
      + (objectPoints.get(i).z / 1000) + " "
      + (int) objectColors.get(i).x + " "
      + (int) objectColors.get(i).y + " "
      + (int) objectColors.get(i).z);
  }

  output.flush(); // Write the remaining data
  output.close(); // Finish the file
}

void drawPointCloud(int steps)
{
  //println("drawing point cloud");

  //draw the dpth map
  int index;
  PVector realWorldPoint;
  stroke(255);

  println("pointcliud "+kinect1.depthHeight());

  for (int y=0; y < kinect1.depthHeight(); y+=steps)
  {
    for (int x=0; x < kinect1.depthWidth(); x+=steps)
    {
      index = x + y * kinect1.depthWidth();
      realWorldPoint = kinect1.depthMapRealWorld()[index];
      println( kinect1.depthMapRealWorld()[index]);

      stroke(150);
      point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
    }
  }


  for (int y=0; y < kinect2.depthHeight(); y+=steps)
  {
    for (int x=0; x < kinect2.depthWidth(); x+=steps)
    {
      index = x + y * kinect2.depthWidth();
      realWorldPoint = kinect2.depthMapRealWorld()[index];
      stroke(150);
      point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
    }
  }
}

void controlEvent(ControlEvent theEvent) {
  // PulldownMenu is if type ControlGroup.
  // A controlEvent will be triggered from within the ControlGroup.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message from controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    if (theEvent.group().name().equals("songs")) {
      println("list "+theEvent.group().value()+" "+theEvent.group().name());
      int index= (int)theEvent.group().value();
      songChooser=index;
      println("songChooser is now "+songChooser);
      // SONG_PLACE HERE YOU NEED TO ADD SOME SONG STUFF - ITS WHERE THE MESSAGE COMES OUT OF THE GUI
      if (songChooser==0&&!song.getIsPlaying()) {
        //PAUSE ALL THE OTHER SONGS
        song1.close();
        song2.close();
        song3.close();
        song4.close();   
        //PLAY THE NEW ONE
        song.start();
        songChooser=0;
      }
      if (songChooser==1&&!song1.getIsPlaying()) {
        song.close();
        song2.close();
        song3.close();
        song4.close();  

        song1.start();
        songChooser=1;
      }
      if (songChooser==2&&!song2.getIsPlaying()) {
        song.close();
        song1.close();
        song3.close();
        song4.close();  

        song2.start();
        songChooser=2;
      }
      if (songChooser==3&&!song3.getIsPlaying()) {
        song.close();
        song1.close();
        song2.close();
        song4.close();  

        song3.start();
        songChooser=3;
      }
      if (songChooser==4&&!song4.getIsPlaying()) {
        song.close();
        song1.close();  
        song2.close();
        song3.close();

        song4.start();
        songChooser=4;
      }
    }
  }
}

