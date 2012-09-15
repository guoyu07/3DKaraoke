/*
cc tom schofield 2012
Processing Karakoke class - given a list of lyrics and timings will subtitle songs and scroll at appropriate speeds. Lyrics and timings should be in seperate txt files. Times should be in millis.

 This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 
 The above copyleft notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 DEALINGS IN THE SOFTWARE.
 */

class Song {
  protected String filename;
  protected String songName;
  protected float [] timings;
  protected String [] lines;
  protected long ellapsedTime;
  //where in the list of texts and timings we are.
  protected int index=-1;
  //the start position of the text
  protected int x;
  protected int y;
  //this is the variable with which we will scroll the text left
  protected int scrollAmt=0;
  protected AudioSnippet player;
  protected boolean playing=false;

  Song(String _filename, String _songName, String lyricsFileName, String timingsFileName, int _x, int _y) {
    filename=_filename;
    songName=_songName;

    String [] times=loadStrings(timingsFileName);
    timings=new float[times.length];
    for (int i=0;i<times.length;i++) {
      timings[i]=float(times[i]);
    }
    lines=loadStrings(lyricsFileName);

    if (timings.length!=lines.length) {
      println("warning! length of lyrics is: "+lines.length+" but length of timings is : "+timings.length);
    }
    else {
      println("GREAT! THE TIMES MATCH length of lyrics is: "+lines.length+" AND length of timings is : "+timings.length);
    }
    x=_x;
    y=_y;
  } 
  void start() {
    index=-1;
    scrollAmt=0;
    //load clip inside song
    player = minim.loadSnippet(filename);
    //start playing clip
    player.play();
    //the time we start in milllis
    ellapsedTime = millis();
    playing=true;
  }
  void check() {
    //check to see if we have reached the next threshold point yet
    if (index<timings.length-2) {
      if (millis()-ellapsedTime> timings[index+1]) {
        index++;
        scrollAmt=0;
      }
    }
    if (playing) {
      //if we've finished the song, then clear out the player
      if (player.position()  >= player.length()  ) {
        //  player.close();
        println("end of clip");
      }
    }
  }
  void display() {
    pushMatrix();
    fill(255);
    if (index>=0) {
      translate( x - scrollAmt, y, textZ);

      //change this to scroll across screen
      float timeToNextInterval = (timings[index+1]-timings[index])/1000;
      //the number of frames till the next interval
      float framesToNextInterval= timeToNextInterval*frameRate;
      int distanceToMove = width/2;
      //float speed = distanceToMove/framesToNextInterval;
      //the scrolling speed - bigger is faster!  
      float speed=_speed;
      scrollAmt+=speed;
      text(lines[index], 0, 0 );
      //  text(lines[index], x - scrollAmt, y );
      // text("time since song started: "+str((millis()-ellapsedTime)/1000)+" index is "+str(index), 10, 50+(height/2));
      //text("next interval: "+str(timings[index+1]/1000), 10, 100+(height/2));
    }
    else {
      translate( x - (width-10), y, textZ);
      //text("GET READY!", x-(width-10), y );
      text("GET READY!", 0, 0, 0 );
    }
    popMatrix();
  }
  void pause() {
    player.pause();
  }
  boolean getIsPlaying() {
   // println(songName +" is playing : "+player.isPlaying());
   // return player.isPlaying();
   return playing;
  }
  void close() {
    playing = false;
    try {
      player.close();
    }
    catch (Exception e) {
    }
  }
}

