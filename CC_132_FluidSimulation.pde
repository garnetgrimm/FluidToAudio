// Fluid Simulation
// Daniel Shiffman
// https://thecodingtrain.com/CodingChallenges/132-fluid-simulation.html
// https://youtu.be/alhpH6ECFvQ

// This would not be possible without:
// Real-Time Fluid Dynamics for Games by Jos Stam
// http://www.dgp.toronto.edu/people/stam/reality/Research/pdf/GDC03.pdf
// Fluid Simulation for Dummies by Mike Ash
// https://mikeash.com/pyblog/fluid-simulation-for-dummies.html
import processing.sound.*;

final int N = 128;
final int iter = 16;
final int SCALE = 5;

int cx = 0;
int cy = 0;

float t = 0;

int jitter = 100;
int minR = 50;
int maxR = 75;

Fluid bfluid;
Fluid rfluid;

color red;
color blue;

float d = 0.001;
float maxD = 0.0005;
float time = 0;

int numOsc = 10;
float maxFreq = 1000.0;
float minFreq = 800.0;
SinOsc[] sine;

void settings() {
  size(N*SCALE, N*SCALE);
}

void setup() {
  red = color(255, 0, 0);
  blue = color(0, 0, 255);
  
  rfluid = new Fluid(0.002, 0.0, 0.001, red);
  bfluid = new Fluid(0.002, 0.0, 0.001, blue);
  cx = int(0.5*width/SCALE);
  cy = int(0.5*height/SCALE);
  

  sine = new SinOsc[numOsc];
  for(int i = 0; i < numOsc; i++) {
    sine[i] = new SinOsc(this);
    float iPerc = float(i)/float(numOsc);
    float fPerc = (iPerc * (maxFreq - minFreq)) + minFreq;
    sine[i].freq(200 + 50*float(i));
    sine[i].amp(0);
    sine[i].play();
  }
  
  
  frameRate(24);
}

//void mouseDragged() {
//}

void draw() {
  background(0);
  
  time += 0.05;

  bfluid.step();
  rfluid.step();
  
  //blendMode(ADD);
  bfluid.renderD();
  rfluid.renderD();
  //fluid.renderV();
 
  colorMode(RGB, 255);
  stroke(255, 0, 0, 5);
  fill(255, 0, 0);
  
  float stren = 0.01;
  
  float rsum = 0;
  
  for(int r = minR; r < maxR; r+= 1) { 
    int outerR = r;
    int innerR = r - 10;
    for(int t = 0; t < 360; t++) {
        int sx = int(outerR*cos(radians(t))) + cx + int(random(-jitter, jitter));
        int sy = int(outerR*sin(radians(t))) + cy + int(random(-jitter, jitter));
        int ex = int(innerR*cos(radians(t-60))) + cx + int(random(-jitter, jitter));
        int ey = int(innerR*sin(radians(t-60))) + cy + int(random(-jitter, jitter));

        d = noise(sx*SCALE, sy*SCALE, time)*maxD*2 - maxD*0.93;

        rsum += d;

        rfluid.addDensity(sx,  sy, d);
        rfluid.addVelocity(sx, sy, (ex - sx) * stren, (ey - sy) * stren);
        
        bfluid.addDensity(sx, sy, d);
        bfluid.addVelocity(sx, sy, (ex - sx) * stren * 0.5, (ey - sy) * stren * 0.5);
    }
  }
  
  for(int t = 0; t < 360; t++) {
      int sx = int(10*cos(radians(t))) + cx;
      int sy = int(10*sin(radians(t))) + cy;
      
      rfluid.addDensity(sx,  sy, -0.0001);
      bfluid.addDensity(sx,  sy, -0.0001);
  }
  
  colorMode(RGB);
  noStroke();
  for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        float x = i * SCALE;
        float y = j * SCALE;
        int r = abs(rfluid.px[i][j]);
        int g = abs(bfluid.px[i][j]);
        int b = abs(bfluid.px[i][j]);
        //r=g=b=255;
        float s1 = 3000 + time*100;
        float s2 = 500 + time*10;
        float rsqr = pow(float(cx-i), 2) + pow(float(cy-j), 2);
        //int a = int(255*pow(noise(rsqr/s1, rsqr/s2), 3));
        int a = 255;
        fill(r,g,b,a);
        square(x, y, SCALE);
      }
   }

   for(int i = 0; i < numOsc; i++) {
     float startX = float(cx);
     float endX = float(cx);
     float startY = mouseY/SCALE;
     float endY = float(cy);
     
     float len = sqrt(pow(endX - startX, 2) + pow(endY - startY, 2));
     
     float iPerc = float(numOsc - i - 1)/float(numOsc + 1);
     float iNPerc = float(numOsc - i)/float(numOsc + 1);
     
     int rPerc = int(iPerc * len  + cy);
     int rNPerc = int(iNPerc * len  + cy);
     
     float amp = 0.0;
     int ncnt = 0;
     for(int n = rPerc;  n < rNPerc; n++) {
       ncnt++;
       amp += float(rfluid.px[(N/2)-1][n])/255;
     }
     
     amp /= float(ncnt);
     amp *= 0.5;
     
     sine[i].amp(amp);
     
     fill(255);
     stroke(255);
     line(startX*SCALE, startY*SCALE, endX*SCALE, endY*SCALE);
     text(Float.toString(rPerc), 25, 25 + i * 10);
   }

  
  //fluid.renderV();
  //fluid.fadeD();
}
