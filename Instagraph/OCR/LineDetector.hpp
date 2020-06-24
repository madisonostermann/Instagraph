//
//  LineDetector.hpp
//  Instagraph
//
//  Created by Madison Gipson on 6/20/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

//DECLARATIONS FOR LINEDETECTOR.CPP
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

class LineDetector {
    
public:
    
    //Returns image with line overlay
    Mat detect_line(Mat image);
    
private:
    
    //reads, thresholds and inverts image for processing
    Mat prepare_image(Mat image);
    
    //grabs vertical & horiztonal lines from image
    //takes out text to isolate cells
    Mat isolate_lines(Mat prepared_image);
    
    //find contours in image to isolate cells
    //then sorts
    Mat find_contours(Mat lined_image, Mat image);
};
