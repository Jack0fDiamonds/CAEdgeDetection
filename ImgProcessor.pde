void toGreyscale(PImage in, PImage out) {
  out.loadPixels();
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++ ) {
      int loc = x + y*in.width;
      out.pixels[loc] = color(brightness(in.pixels[loc]));
    }
  }
  out.updatePixels();
}

void toBinary(PImage in, PImage out, int treshold) {
  out.loadPixels();
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++ ) {
      int loc = x + y*in.width;
      if (brightness(in.pixels[loc]) < treshold) {
        out.pixels[loc] = color(0);
      } else {
        out.pixels[loc] = color(255);
      }
    }
  }
  out.updatePixels();
}

void treshold(PImage in, PImage out) {
  //set initial treshold to be mean of the entire image
  double t = 0;
  double treshold;
  for (int i = 0; i < in.pixels.length; i++) {
    t += brightness(in.pixels[i]);
  }
  treshold = t/in.pixels.length;
  
  double prevTreshold = -1;

  //separate background and foreground and find new treshold to be average of their means. Repeat until treshold value stops changing
  double backgroundMean = 0;
  double foregroundMean = 0;
  do {
    double back = 0;
    int backCount = 0;
    double front = 0;
    int frontCount = 0;
    for (int i = 0; i < in.pixels.length; i++) {
      if (brightness(in.pixels[i]) > treshold) {
        front += brightness(in.pixels[i]);
        frontCount++;
      } else {
        back += brightness(in.pixels[i]);
        backCount++;
      }
    }
    backgroundMean = back/backCount;
    foregroundMean = front/frontCount;
    prevTreshold = treshold;
    treshold = (backgroundMean + foregroundMean)/2;
  } while (treshold != prevTreshold);
  
  //treshold the output image with found treshold value
  out.loadPixels();
  for (int i = 0; i < in.pixels.length; i++) {
    if (brightness(in.pixels[i]) > treshold)
      out.pixels[i] = color(255);
    else
      out.pixels[i] = color(0);
  }
  out.updatePixels();
}

//sum of Moore Neighbourhood excluding the central cell
int binaryMooreNeighborSumEx(PImage in, int x, int y) {
  int sum = 0;
  sum += brightness(in.pixels[x-1 + y*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x+1 + y*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x + (y-1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x + (y+1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x-1 + (y-1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x+1 + (y-1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x-1 + (y+1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x+1 + (y+1)*in.width]) == 0 ? 0 : 1;
  return sum;
}

//sum of Moore Neighbourhood including the central cell
int binaryMooreNeighborSumIn(PImage in, int x, int y) {
  int sum = 0;
  sum += brightness(in.pixels[x + y*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x-1 + y*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x+1 + y*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x + (y-1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x + (y+1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x-1 + (y-1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x+1 + (y-1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x-1 + (y+1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x+1 + (y+1)*in.width]) == 0 ? 0 : 1;
  return sum;
}

int binaryNeumanNeighborSum(PImage in, int x, int y) {
  int sum = 0;
  sum += brightness(in.pixels[x-1 + y*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x+1 + y*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x + (y+1)*in.width]) == 0 ? 0 : 1;
  sum += brightness(in.pixels[x + (y+1)*in.width]) == 0 ? 0 : 1;
  return sum;
}