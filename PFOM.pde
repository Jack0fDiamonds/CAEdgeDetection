class PFOM {
  //width and height of images
  int w, h;
  //ground truth image
  PImage gt;
  int[] trueEdgePoints;
  //image to compare
  PImage img;
  int[] actualEdgePoints;

  //load the ground truth image and store the coordinates of its edge points
  void loadGTImg(String path) {
    gt = loadImage(path);
    w = gt.width;
    h = gt.height;

    IntList points = new IntList();
    for (int i = 0; i < gt.pixels.length; i++)
      if (brightness(gt.pixels[i]) == 255)
        points.append(i);

    trueEdgePoints = points.array();
  }

  //load an image to be validated and store the coordinates of its edge points
  void loadImg(String path) {
    img = loadImage(path);
    IntList points = new IntList();
    for (int i = 0; i < img.pixels.length; i++)
      if (brightness(img.pixels[i]) == 255)
        points.append(i);
    actualEdgePoints = points.array();
  }

  float validate() {
    float r = 0;

    //number of ideal edge points
    int Ii = trueEdgePoints.length;
    //number of actual edge points
    int Ia = actualEdgePoints.length;
    int In = Ii > Ia ? Ii : Ia;
    float a = 1./9;

    float sum = 0;    

    for (int i = 0; i < actualEdgePoints.length; i++) {
      float d = Float.MAX_VALUE;
      int x1 = actualEdgePoints[i] % w;
      int y1 = actualEdgePoints[i] / w;

      for (int j = 0; j < trueEdgePoints.length; j++) {
        int x2 = trueEdgePoints[j] % w;
        int y2 = trueEdgePoints[j] / w;
        float dist = sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
        if (dist < d)
          d = dist;
        //if already found a pixel in the right spot, no need to keep checking the rest
        if (d == 0)
          continue;
      }

      sum += 1.0 / (1.0 + a*d*d);
    }

    r = sum / In;
    return r;
  }
}