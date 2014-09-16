/**
  * This sketch demonstrates how to monitor the currently active audio input 
  * of the computer using an AudioInput. What you will actually 
  * be monitoring depends on the current settings of the machine the sketch is running on. 
  * Typically, you will be monitoring the built-in microphone, but if running on a desktop
  * it's feasible that the user may have the actual audio output of the computer 
  * as the active audio input, or something else entirely.
  * <p>
  * Press 'm' to toggle monitoring on and off.
  * <p>
  * When you run your sketch as an applet you will need to sign it in order to get an input.
  * <p>
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
  *
  * code adapted from http://www.pfesto.com/how-to-make-an-audio-visualizer-with-processing/ 
  */

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;
FFT fft;
//AudioPlayer song;
BeatDetect beat_freq;
BeatDetect beat_sound;
BeatListener listener;
float eRadius;
float kickSize, snareSize, hatSize;

class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioSource source;
  
  BeatListener(BeatDetect beat, AudioSource source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }
  
  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }
  
  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}

void setup()
{
  size(1200, 600, P3D);

  minim = new Minim(this);
  
  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn();  
  
  println("BufferSize: " + in.bufferSize());
  println("SampleRate: " + in.sampleRate());

  //song = minim.loadFile("song.mp3", 2048);
  //song.play();  
  
  fft = new FFT(in.bufferSize(), in.sampleRate());
  beat_sound = new BeatDetect();
  beat_freq = new BeatDetect(in.bufferSize(), in.sampleRate());
  beat_freq.setSensitivity(100); 
  kickSize = snareSize = hatSize = 16;
  listener = new BeatListener(beat_freq, in);
  
  ellipseMode(RADIUS);
  eRadius = 20;
}

void draw() {

  //it's important to put the background in the draw loop
  //to make it animate rather than draw over itself 
    background(#222222);
 
    fft.forward(in.mix);
    
    beat_sound.detect(in.mix);
    float a = map(eRadius, 20, 80, 60, 255);
    fill(0, 0, 0, a);
    if ( beat_sound.isOnset() ) eRadius = 80;
    ellipse(250, 550, eRadius, eRadius);
    eRadius *= 0.95;
    if ( eRadius < 20 ) eRadius = 20;
 
  //line characteristics
    strokeWeight(1.3);
    stroke(#FFF700);
  
  //processing's transform tool
    pushMatrix();
    translate(200, 0); 
  
  //draw the frequency spectrum as a series of vertical lines
  //I multiple the value of getBand by 4 
  //so that we can see the lines better
    for(int i = 0; i < 0+fft.specSize(); i++)
    {
      line(i, 450, i, 450 - fft.getBand(i)*4);
    }
  
  //closing the transform tool
    popMatrix();
 
  //changing the line color
    stroke(#FF0000);
  
  //the waveform is drawn by connecting neighbor values with a line. 
  //The values in the buffers are between -1 and 1. 
  //If we don't scale them up our waveform will look like a straight line.
  //Thus each of the values is multiplied by 50
    int scale = 50; 
    for(int i = 200; i < in.left.size() - 1; i++)
    {
      line(i, 50 + in.left.get(i)*scale, i+1, 50 + in.left.get(i+1)*scale);
      line(i, 150 + in.right.get(i)*scale, i+1, 150 + in.right.get(i+1)*scale);
      line(i, 250 + in.mix.get(i)*scale, i+1, 250 + in.mix.get(i+1)*scale);
    }
  
  //blue rectangle on the left
    noStroke();
    fill(#0024FF);
    rect(0, 0, 200, height);
  
  //text
    textSize(24);
    fill(255);
    text("left amplitude", 0, 50); 
    text("right amplitude", 0, 150); 
    text("mixed amplitude", 0, 250); 
    text("frequency", 0, 450);
    text("beat detect", 0, 550); 

    if ( beat_freq.isKick() ) kickSize = 32;
    if ( beat_freq.isSnare() ) snareSize = 32;
    if ( beat_freq.isHat() ) hatSize = 32;
    textSize(kickSize);
    text("KICK", width/4, height/2);
    textSize(snareSize);
    text("SNARE", width/2, height/2);
    textSize(hatSize);
    text("HAT", 3*width/4, height/2);
    kickSize = constrain(kickSize * 0.95, 16, 32);
    snareSize = constrain(snareSize * 0.95, 16, 32);
    hatSize = constrain(hatSize * 0.95, 16, 32);
}

void stop()
{
  //close the AudioInput you got from Minim.getLineIn()
    in.close();
  
    minim.stop();
 
  //this calls the stop method that 
  //you are overriding by defining your own
  //it must be called so that your application 
  //can do all the cleanup it would normally do
    super.stop();
}

