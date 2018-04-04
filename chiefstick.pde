// Import syphon library 
import codeanticode.syphon.*; 
// import UDP library
import hypermedia.net.*;

// Defining UDP and Syphon object
SyphonServer server;
UDP udp; 

// Empty arrays for reading
float[] list;
float[] inbox; 

// Final datatype for incoming data (BNO055 sensor: pitch, yaw and roll)
float a, b,c; 

// Wave graphics
int xspacing = 8;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave
int maxwaves = 6;   // total # of waves to add together
float theta = 0.0;
float[] amplitude = new float[maxwaves];   // Height of wave
float[] dx = new float[maxwaves];          // Value for incrementing X, to be calculated as a function of period and xspacing
float[] yvalues;                           // Using an array to store height values for the wave (not entirely necessary)

void settings() {
  size(400,400, P3D);
  PJOGL.profile=1;
}
 
void setup() {
  
  // Create syphon server to write frames to
  server = new SyphonServer(this, "Processing Syphon");
  background(255); 
  
  // Create a new datagram connection on port 6000
  // And wait for incomming message
  udp = new UDP(this,6000, "192.168.4.2");
  udp.log(true);      // <-- printout the connection activity
  udp.listen(true);
  
  frameRate(30);
  colorMode(RGB, 255, 255, 255, 100);
  w = width + 16;

  for (int i = 0; i < maxwaves; i++) {
    amplitude[i] = random(10,30);
    float period = random(100,300)+c; // How many pixels before the wave repeats
    dx[i] = (TWO_PI / period) * xspacing;
  }
  yvalues = new float[w/xspacing];
}

void draw() {
  calcWave();
  renderWave();
  server.sendScreen();
}

/**
 * To perform any action on datagram reception, you need to implement this 
 * handler in your code. This method will be automatically called by the UDP 
 * object each time he receive a nonnull message.
 * By default, this method have just one argument (the received message as 
 * byte[] array), but in addition, two arguments (representing in order the 
 * sender IP address and his port) can be set like below.
 */
// void receive( byte[] data ) {            // <-- default handler
void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);
  String message = new String( data );
  String[] inbox = split(message,','); 
  float [] list = float(inbox); 
  
  println("List[0]" + list[0]); 
  println("list[1]" + list[1]); 
  println("list[2]" + list[2]); 
  println("list.length" + list.length); 

// Now we have pitch, yaw and roll from Arduino represented in 3 floats
 a = list [0];
 b = list [1];
 c = list [2]; 

  // print the result
  println( "receive: \""+message+"\" from "+ip+" on port "+port );
}
void calcWave() {
  // Increment theta (try different values for 'angular velocity' here
  theta += 0.02;

  // Set all height values to zero
  for (int i = 0; i < yvalues.length; i++) {
    yvalues[i] = 0;
  }
 
  // Accumulate wave height values
  for (int j = 0; j < maxwaves; j++) {
    float x = theta;
    for (int i = 0; i < yvalues.length; i++) {
      // Every other wave is cosine instead of sine
      if (j % 2 == 0)  yvalues[i] += sin(x)*amplitude[j];
      else yvalues[i] += cos(x)*amplitude[j];
      x+=dx[j];
    }
  }
}

void renderWave() {
  noStroke();
  fill(random(255),random(255),random(255));
  ellipseMode(CENTER);
  for (int x = 0; x < yvalues.length; x++) {
    fill(random(25)+b+a, random(25)*b+a,random(25)* c); 
    ellipse(x*xspacing,height/2+yvalues[x],random(15),random(16)+a+b);
    ellipse(x*xspacing,height/2+yvalues[x],random(30),random(32)+b);
  }
}
