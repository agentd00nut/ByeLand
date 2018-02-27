

class BitScreen {
  float w;
  float h;
  float s;
  
  int[][] screen;
  int[][] tmpScreen;
  
  ArrayList<int[][]> frames;
  
  BitScreen(int w, int h, int scale){
    this.w = floor(w/scale);
    this.h = floor(h/scale);
    this.s = scale;
    this.screen = new int[w][h];
    this.tmpScreen = new int[w][h];
    println("Init:");
    println(" width: ", this.w);
    println(" height: ", this.h);
    println(" scale: ", this.s);
    this.frames = new ArrayList<int[][]>();
    this.clear();
  }
  
  void fill(int c){
    println("Fill, ",c);
    for(int y=0; y<height; y++){
      for(int x=0; x<width; x++){
        img.pixels[x+(y*width)]=c;
      }
    }
  }
  
  void clear(){
    println("Clear");
    for(int y=0; y < this.h; y++){
      for(int x=0; x< this.w; x++){
          this.screen[x][y]=color(0,0,0,255);
          this.tmpScreen[x][y]=color(0,0,0,255);
      }
    }
  }
  
  void noise(float fillRate, int fill ){
    println("Noise,",fillRate,",",fill);
    for(int y=1; y < this.h-1; y++){
      for(int x=1; x< this.w-1; x++){
        if( random(0, 1) < fillRate){
          this.screen[x][y]=fill;
        }
      }
    }    
  }
  
  void display(){
    img.loadPixels();
    for(int y=0; y < this.h; y++){
      for(int x=0; x < this.w; x++){
        for( int tY=0; tY<this.s; tY++){
          for( int tX=0; tX<this.s; tX++){

            //println(tX+(x*this.s), tY+(y*this.s), "/", x, y, "/", ((tY+y)*(this.w*this.s)) + (x+tX) );
            img.pixels[((int)(this.s*x)+tX)+(int)((tY+(y*this.s))*(this.w*this.s))]=this.screen[x][y];
          }
        }
      }
    }
    img.updatePixels();
    image(img,0,0);
  }
  
  void smooth(int iterations, int threshold){
    println("Smooth, ",iterations,",",threshold);
    int n=0;
    while(n < iterations){
      for(int y=1; y < this.h-1; y++){
        for(int x=1; x < this.w-1; x++){
          if( this.countNeighbors(x,y) >= threshold){
            this.tmpScreen[x][y]=color(255);
          }else{
            this.tmpScreen[x][y]=color(0,0,0); 
          }
        }
      }      
      n++;
      flushTmpScreen();
    }
  }
  
  void flushTmpScreen(){
     for(int y=1; y < this.h-1; y++){
        for(int x=1; x < this.w-1; x++){
          this.screen[x][y] = this.tmpScreen[x][y];
          this.tmpScreen[x][y] = color(0);
        }
     }
  }
  
  void nudgeY(float dY){
    println("NudgeY, ", dY);
    if(dY == 1 ){

     for(int y=0; y < this.h-dY; y++){
        for(int x=0; x < this.w; x++){
          this.screen[x][y]=this.screen[x][y+1];
        }
     }
     for(int x=0; x<this.w; x++){
       this.screen[x][(int)this.h-1]= color(0);
     }
    }else{

      for(int y=(int)this.h; y > 0; y--){
        for(int x=0; x < this.w; x++){
          this.screen[x][y]=this.screen[x][y-1];
        }
      }
      for(int x=0; x<this.w; x++){
        this.screen[x][0] = color(0);
      }
    }
  }
  
  int countNeighbors(int x, int y){
    // TODO: Check if x and y are within bounds.
    int c=0;
    if(this.screen[x-1][y-1] > color(0)){ c++; }
    if(this.screen[x-1][y]   > color(0)){ c++; }
    if(this.screen[x-1][y+1] > color(0)){ c++; }
    
    if(this.screen[x][y-1] > color(0)){ c++; }
    if(this.screen[x][y+1] > color(0)){ c++; }
    
    if(this.screen[x+1][y-1] > color(0)){ c++; }
    if(this.screen[x+1][y]   > color(0)){ c++; }
    if(this.screen[x+1][y+1] > color(0)){ c++; }

    return c;
  }
  
  void saveFrame(){
    println("Save Frame");
    int[][] tmp = new int[(int)this.w][(int)this.h];
    for(int y=0; y<this.h; y++){
      for(int x=0; x<this.w; x++){
        tmp[x][y] = this.screen[x][y];
      }
    }
    
    this.frames.add(tmp);
    //int[][] z=this.frames.get(this.frames.size()-1);
    //float sum=0;
    // for(int y=0; y < this.h; y++){
    //  for(int x=0; x < this.w; x++){
    //    sum+=z[x][y];
    //  }
    // }
    // println(sum);
  }
  
  void displayFrame(int[][] frame, color c)
  {
    int p=0;
    for(int y=0; y < this.h; y++){
      for(int x=0; x < this.w; x++){
        for( int tY=0; tY<this.s; tY++){
          for( int tX=0; tX<this.s; tX++){

            if(frame[x][y]==-1){ // white
              p++;
              img.pixels[((int)(this.s*x)+tX)+(int)((tY+(y*this.s))*(this.w*this.s))]=c;//frame[x][y];
            }
          }
        }
      }
    }
    println("PIXELS DRAWN:",p);
  }
  
  void displayFrames(){
    println("Displaying ",this.frames.size()," frames");
    img.loadPixels();
    fill(colors.get(0));
    int ci=1;
    for(int i = 0; i<this.frames.size(); i++){
      this.displayFrame(this.frames.get(i), colors.get(ci));
      ci++;
    }
    img.updatePixels();
    image(img,0,0);
  }
  
  void displayFrames(int sleep){
    println("Displaying ",this.frames.size()," frames");
    img.loadPixels();
    fill(colors.get(0));
    img.updatePixels();
    image(img,0,0);
    delay(sleep);
    
    int ci=1;
    for(int i = 0; i<this.frames.size(); i++){
      img.loadPixels();
      this.displayFrame(this.frames.get(i), colors.get(ci));
      ci++;
      delay(sleep);
      img.updatePixels();
      image(img,0,0);
    }
    
  }
  
  int countPixels(){
    int n=0;
    for(int y=0; y < this.h; y++){
      for(int x=0; x < this.w; x++){
        if( this.screen[x][y] == -1 ){
          n++;
        }
      }
    }
    return n;
  }
}

void keyPressed() {
  if(key=='n'){
    bs.noise(.7, color(255));
    bs.display();
  }
  if(key=='N'){
    bs.noise(.3, color(0));
    bs.display();
  }
  if(key=='c'){
    bs.clear();
    bs.display();
  }
  if(key=='s'){
    bs.smooth(1, 5);
    bs.display();
  }
  if(key=='d'){
    bs.display();
  }
  if(key=='i'){
    bs.nudgeY(1);
    bs.display();
  }
  if(key=='k'){
    bs.nudgeY(-1);
    bs.display();
  }
  if(key=='S'){
    bs.saveFrame();
  }
  if(key=='D'){
    bs.displayFrames();
  }
  if(key=='R'){
    img.loadPixels();
    bs.displayFrame(bs.frames.get( bs.frames.size()-1 ), color(255,255,255,100));
    img.updatePixels();
    image(img,0,0);
  }

}

void sparseIslands(){
    bs = new BitScreen(islandX, islandY, islandS );

    int i=0;
    bs.noise(.66, color(255));
    bs.smooth(12, 5);
    bs.saveFrame();
    bs.nudgeY(1);
    
    bs.noise(.1, color(0));
    bs.smooth(4, 5);
    bs.saveFrame();
    bs.nudgeY(1);
    
    while(bs.countPixels() > 0){
      i++;
      bs.noise(.17, color(0));
      if(i <= 3){
        bs.smooth(2, 5);
      }else{
        bs.smooth(1, 5);
      }
      bs.saveFrame();
      bs.nudgeY(1);
   }
}
void smallIsland(){
    bs = new BitScreen(islandX, islandY, islandS );

    int i=0;
    bs.noise(.66, color(255));
    bs.smooth(12, 5);
    bs.saveFrame();
    bs.nudgeY(1);
    
    bs.noise(.1, color(0));
    bs.smooth(4, 5);
    bs.saveFrame();
    bs.nudgeY(1);
    
    while(bs.countPixels() > 0){
      i++;
      bs.noise(.17, color(0));
      if(i <= 3){
        bs.smooth(2, 5);
      }else{
        bs.smooth(1, 5);
      }
      bs.saveFrame();
      bs.nudgeY(1);
   }
}
void clouds(){
  bs.noise(.7, color(255));
  bs.smooth(4,5);
  bs.noise(.3, color(0));
  bs.smooth(1,5);
  bs.noise(.3, color(0));
  bs.smooth(2,5);
  bs.saveFrame();
}

void clearImage(){
  img.loadPixels();
  bs.fill(colors.get(0));
  img.updatePixels();
  image(img,0,0);
}

void writeImage(String name){
  if( saveImages == 1 ){
    save(imagesPath+island+"/"+name+".png");
    images++;
  }
}

void currentIsland(){
  sparseIslands();
}

BitScreen bs;
ArrayList<Integer> colors = new ArrayList<Integer>();
ArrayList<Integer> clouds = new ArrayList<Integer>();




int session=(int)random(0,10000000);
int island=0;
int images=0;
//String imagesPath="/Users/abrothers/Desktop/islands/"+str(session)+"/";
imagesPath="";

int saveImages=0;
int auto=1;

int islandX=600;
int islandY=600;
int islandS=12;
PImage img = createImage(islandX,islandY,ARGB);

void setup(){
  size(600,600);
  
  
  colors.add(color(#436adb));
  colors.add(color(#c7dffc));
  colors.add(color(#feecc3));
  colors.add(color(#fdd183));
  colors.add(color(#00c44b));
  colors.add(color(#40eb5c));
  colors.add(color(#9a682e));
  colors.add(color(#5a544b));
  colors.add(color(#9d9a8d));
  colors.add(color(#cbe0e0));
  colors.add(color(#eef7ff));
  colors.add(color(#FBFDFF));
  
  clouds.add(color(#f2f2f2));

  
  if(auto==1){
    currentIsland();
    clouds();   
    clearImage();
  }
}


int f=0;
void draw(){
   
  if(f==-1){
    println("Session, ",session,",",island);
    delay(400);
    clearImage();
    island++;
    currentIsland();
    clouds();   
  clearImage();
    f=0;
  }
  
  if(auto==1){
    img.loadPixels();

    if(f+1 > colors.size()-1){
      bs.displayFrame(bs.frames.get(f), colors.get(colors.size()-1));
      f=bs.frames.size()-2;
    }else{
      bs.displayFrame(bs.frames.get(f), colors.get(f+1));
    }
    //if(f==bs.frames.size()-1){
      //println("WOWFUCK");
    //  bs.displayFrame(bs.frames.get( bs.frames.size()-1 ), color(255,255,255,200));
    //}
    
    //delay(10);
    img.updatePixels();
    image(img,0,0);
    writeImage(str(f));
    //delay(125);
    
    f++;
  //bs.displayFrame(bs.frames.get( bs.frames.size()-1 ), color(255,255,255,4));
    if( f == bs.frames.size()-1 ){
      writeImage("0_noClouds");
      img.loadPixels();
      bs.displayFrame(bs.frames.get( f ), color(255,255,255,110));
      img.updatePixels();
      image(img,0,0);
      writeImage("0_Clouds");
      f=-1;
    }
  }
}
