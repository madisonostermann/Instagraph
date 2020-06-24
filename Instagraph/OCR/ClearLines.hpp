//
//  ClearLines.hpp
//  Instagraph
//
//  Created by Madison Gipson on 6/20/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

//DECLARATIONS FOR ClearLines.cpp
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

class ClearLines {
    
public:
    //Returns image with no lines
    Mat clear_line(Mat image);
    
private:
    //remove lines from image
    Mat remove_lines(Mat prepared_image);
};
