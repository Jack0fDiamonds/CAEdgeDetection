int w = 512;
int h = 512;
PImage input;
PImage output;
PImage binary;
PImage greyScale;
int treshold = 50;
boolean tresholdIncreasing = true;
boolean temp = true;
int counter = 0;

int ruleLen = 10;
Rule[] rules;

int OTRuleLen = 18;
//number of pixels on each edge of the rule that can be disregarded. For example, if a pixel has 0 or 8 neighbours, then it's not an edge and result will always be 0
int edgePixels = 2;
OTRule[] OTRules;

void setup() {
  //size(512, 512);
  
  
  binary = loadImage("Binary/Photographer.jpeg");
  
  
  //createAllTRules(binary);
  
  
  //createAllOTRules(binary);


  //String path = "C:/Processing-3.3.6/Sketches/CellularAutomata/EdgeDetectionCA2/LenaValidated";  
  //applyPFOM(path, "GroundTruths/LenaCannyGT.jpeg", "PhotographerPrewittSortedPFOM.txt");
  

  //validateImages("C:/Processing-3.3.6/Sketches/CellularAutomata/EdgeDetectionCA2/PhotographerUnvalidated", 
  //               "C:/Processing-3.3.6/Sketches/CellularAutomata/EdgeDetectionCA2/PhotographerValidated(15-35)", 
  //                0.001, 0.15);


  //applyPFOM("C:/Processing-3.3.6/Sketches/CellularAutomata/EdgeDetectionCA2/LenaAutoValidated",
  //          "C:/Processing-3.3.6/Sketches/CellularAutomata/EdgeDetectionCA2/GroundTruths/LenaSobelGT.png",
  //          "LenaSobelAutoPFOM.txt");


  //applyBestRules();


  //findTheBestRule();


  noLoop();
}


void applyBestRules() {
  String[] bestRules = bestRules();

  OTRules = new OTRule[bestRules.length];
  for (int i = 0; i < bestRules.length; i++) {
    OTRules[i] = new OTRule(int(bestRules[i]), OTRuleLen);
  }

  for (int i = 0; i < bestRules.length; i++) {
    print(i + "/" + bestRules.length + ": ");
    PImage bin = binary.copy();
    OTRules[i].apply(bin);
  }
}

//selects best rules from all available
String[] bestRules() {
  String[] files = {"LenaCannyPFOM.txt", "LenaSobelPFOM.txt", "PhotographerCannyPFOM.txt", "PhotographerSobelPFOM.txt"};
  //number of top rules to keep
  int n = 100;

  ArrayList<String> rulesList = new ArrayList<String>();

  for (int j = 0; j < files.length; j++) {
    String str = loadStrings(files[j])[0].substring(1);
    String[] rules = str.split(",");

    for (int i = 0; i < n; i++) {
      String rule = rules[i].substring(2);
      String ruleNum = rule.substring(0, rule.indexOf("\""));
      //float ruleVal = float(rule.substring(rule.indexOf(":")+1));

      if (!rulesList.contains(ruleNum))
        rulesList.add(ruleNum);
    }
  }

  return rulesList.toArray(new String[0]);
}

//creates all possible rules for a totalistic CA and applies each of them to the input image @in
void createAllTRules(PImage in){
  rules = new Rule[(int)pow(2, ruleLen)];
  for(int i = 0; i < pow(2, ruleLen); i++){
    rules[i] = new Rule(i, ruleLen);
  }

  for(int i = 0; i < rules.length; i++){
    PImage bin = in.copy();
    rules[i].apply(bin);
  }
}

//creates all possible rules for an outer totalistic CA and applies each of them to the input image @in
void createAllOTRules(PImage in){
  //maximum number of possible rules
  int maxRules = (int)pow(2, OTRuleLen - edgePixels*2);

  OTRules = new OTRule[maxRules];
  for (int i = 0; i < maxRules; i++) {
    OTRules[i] = new OTRule(i, OTRuleLen);
  }

  for (int i = 0; i < maxRules; i++) {
    print(i + "/" + maxRules + ": ");
    PImage bin = in.copy();
    OTRules[i].apply(bin);
  }
}

//goes through all the images in @path and compares them to the ground truth image GTPath. Outputs to a file @out all the rules with their PFOM values sorted from best to worst
void applyPFOM(String path, String GTPath, String out) {
  String[] files = new File(path).list();

  FloatDict RulesPFOM = new FloatDict();

  PFOM pfom = new PFOM();
  pfom.loadGTImg(GTPath);

  for (int i = 0; i < files.length; i++) {
    println(i + "/" + files.length);
    pfom.loadImg(path + "/" + files[i]);
    RulesPFOM.set(files[i].substring(0, files[i].length()-4), pfom.validate());
  }

  PrintWriter pw = createWriter(out);
  RulesPFOM.sortValuesReverse();
  println(RulesPFOM.toJSON());
  pw.println(RulesPFOM.toJSON());
  pw.flush();
  pw.close();
}

//Checks all images from @in and saves the ones which have between @lowTreshold and @hiTreshold percentage of white pixels to @out
void validateImages(String in, String out, float lowTreshold, float hiTreshold) {
  String[] files = new File(in).list();
  for (int i = 0; i < files.length; i++) {
    println(i + "/" + files.length);
    PImage img = loadImage(in + "/" + files[i]);

    float white = countWhitePixels(img);

    if (white < lowTreshold || white > hiTreshold)
      continue;

    img.save(out + "/" + files[i]);
  }
}

//returns the percentage [0..1] of white pixels in image @img
float countWhitePixels(PImage img) {
  float white = 0.;
  for (int j = 0; j < img.pixels.length; j++)
    if (brightness(img.pixels[j]) == 255)
      white++;

  return white / img.pixels.length;
}

//evaluates the overall merit of each rule based on all gathered PFOM values and outputs in descending order to file BestRules.txt
void findTheBestRule() {
  String[] PFOMs = {"BaboonCannyPFOM.txt", "BaboonPrewittPFOM.txt", "BaboonSobelPFOM.txt", 
    "PeppersCannyPFOM.txt", "PeppersPrewittPFOM.txt", "PeppersSobelPFOM.txt", 
    "TankCannyPFOM.txt", "TankPrewittPFOM.txt", "TankSobelPFOM.txt", 
    "LenaCannyAutoPFOM.txt", "LenaPrewittAutoPFOM.txt", "LenaSobelAutoPFOM.txt", 
    "PhotographerCannyPFOM.txt", "PhotographerPrewittPFOM.txt", "PhotographerSobelPFOM.txt"};

  FloatDict fd = new FloatDict();

  for (int i = 0; i < PFOMs.length; i++) {
    String str = loadStrings(PFOMs[i])[0].substring(1);
    String[] rules = str.split(",");
    
    float maxVal = 0;

    for (int j = 0; j < rules.length; j++) {
      String rule = rules[j].substring(2);
      String ruleNum = rule.substring(0, rule.indexOf("\""));
      float ruleVal = float(rule.substring(rule.indexOf(":")+1));
      
      if(j == 0)
        maxVal = ruleVal;
      
      //to make sure each PFOM has the same weight
      ruleVal = ruleVal / maxVal;

      if (fd.hasKey(ruleNum))
        ruleVal += fd.get(ruleNum);
      
      fd.set(ruleNum, ruleVal);
    }
  }
  
  String[] keys = fd.keyArray();
  for(int i = 0; i < keys.length; i++){
    fd.set(keys[i], fd.get(keys[i]) / PFOMs.length);
  }
  
  PrintWriter pw = createWriter("BestRules.txt");
  fd.sortValuesReverse();
  println(fd.toJSON());
  pw.println(fd.toJSON());
  pw.flush();
  pw.close();
}
