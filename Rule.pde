//rule for a totalistic CA
class Rule {
  int number;
  int[] bin;

  //creates an array of values that each cell will get on the next generation for the current rule number going left to right
  //first rule is 0..0, last rule is 255..255
  //values are multiplied by 255 in order to represent white color which is 255 and not 1
  Rule(int number, int maxlen) {
    this.number = number;
    String[] str = binary(number, maxlen).split("");
    bin = new int[maxlen];
    for (int i = 0; i < maxlen; i++)
      bin[i] = Integer.valueOf(str[i])*255;
  }

  void step(PImage img) {
    PImage buffer = img.copy();
    img.loadPixels();

    for (int x = 1; x < img.width-1; x++) {
      for (int y = 1; y < img.height-1; y++ ) {
        int loc = x + y*img.width;
        int sum = binaryMooreNeighborSumIn(buffer, x, y);
        img.pixels[loc] = color(bin[9-sum]);
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
    } while (++generations < 200 && !arraysIdentical(previous.pixels, img.pixels));
    boolean validated = validate(img);
    println("Rule " + number + " done. Generations: " + generations + ". Validated: " + validated);
    //if (validated)
      img.save("output/" + number);
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