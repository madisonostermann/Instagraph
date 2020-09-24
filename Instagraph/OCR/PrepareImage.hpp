//
//  PrepareImage.hpp
//  Instagraph
//
//  Created by Madison Gipson on 6/20/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

//DECLARATIONS FOR PrepareImage.cpp
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

class PrepareImage {
    
public:
    Mat deskew(Mat image); //deskew image aka correct perspective
    vector<Mat> splice_cells();
    vector<Point2f> locate_cells();
    
private:
    Mat remove_lines(Mat image); //remove table lines
    vector<Mat> detect_divide_contours(Mat image); //detect remaining text and divide image into cells
    //Mat adjust_brightness_and_contrast(Mat image); //auto adjust brightness and contrast
};
