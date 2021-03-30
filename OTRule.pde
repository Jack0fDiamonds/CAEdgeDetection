//rule for an outer totalistic CA
class OTRule {
  int number;
  int[] bin;

  //creates an array of values that each cell will get on the next generation for the current rule number going left to right
  //first rule is 0..0, last rule is 255..255
  //even indexes are for white central cell, odd indexes are for balck central cell [8/1, 8/0, 7/1, 7/0, ..., 0/1, 0/0]
  //values are multiplied by 255 in order to represent white color which is 255 and not 1
  OTRule(int number, int maxlen) {
    String[] str = binary(number, maxlen - edgePixels*2).split("");
    bin = new int[maxlen];
    for (int i = edgePixels; i < maxlen - edgePixels; i++)
      bin[i] = Integer.valueOf(str[i - edgePixels])*255;

    //calculating the actual rule number (equal to transforming binary to decimal)
    int n = 0;
    for (int i = 0; i < bin.length; i++)
      if(bin[i] != 0)
      n += pow(2, bin.length-i-1);
    this.number = n;
  }

  void step(PImage img) {
    PImage buffer = img.copy();
    img.loadPixels();

    for (int x = 1; x < img.width-1; x++) {
      for (int y = 1; y < img.height-1; y++ ) {
        int loc = x + y*img.width;
        int sum = binaryMooreNeighborSumEx(buffer, x, y);

        //if the central pixel is black, then offset the index by 1
        int offset = brightness(buffer.pixels[loc]) == 0 ? 1 : 0;
        img.pixels[loc] = color(bin[(8-sum)*2 + offset]);
      }
    }

    img.updatePixels();
  }

  void apply(PImage img) {
    int generations = 0;
    PImage previous;
    do {
      previous = img.copy();
      step(img);
    } while (++generations < 100 && !arraysIdentical(previous.pixels, img.pixels));
    //boolean validated = validate(img);
    //println("Rule " + number + " done. Generations: " + generations + ". Validated: " + validated);
    //if (validated)
    //  img.save("output/" + number);

    println("Rule " + number + " done. Generations: " + generations);
    img.save("Test/" + number);
  }

  //checks if the output image is worth saving
  //if the number of white pixels is below 5% of all the pixels, then no need to save
  //if the number of white pixels is over 40% of all the pixels, then no need to save
  boolean validate(PImage img) {
    double white = 0;
    for (int i = 0; i < img.pixels.length; i++) {
      if (brightness(img.pixels[i]) == 255)
        white++;
    }
    if (white <= 0.05 * img.pixels.length)
      return false;

    if (white >= 0.4  * img.pixels.length)
      return false;

    return true;
  }
}