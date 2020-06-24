//
//  ClearLines.cpp
//  Instagraph
//
//  Created by Madison Gipson on 6/20/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

//LINE DETECTION ALGORITHM
#include "ClearLines.hpp"

using namespace cv;
using namespace std;

Mat original_image;

Mat ClearLines::clear_line(Mat image) {
    image.copyTo(original_image);
    //Convert to grayscale
    cvtColor(image, image, COLOR_BGR2GRAY);
    //Threshold and invert image
    threshold(image, image, 0, 255, THRESH_BINARY_INV+THRESH_OTSU);
    return remove_lines(image);
}

Mat ClearLines::remove_lines(Mat prepared_image) {
    vector<vector<Point> > contours;
    vector<Vec4i> hierarchy;
    //get all horizontal lines
    Mat horizontal_kernel = getStructuringElement(MORPH_RECT, Size(prepared_image.cols/20, 1));
    Mat horizontal_image;
    erode(prepared_image, horizontal_image, horizontal_kernel, Point(-1, -1));
    dilate(horizontal_image, horizontal_image, horizontal_kernel, Point(-1, -1));
    //get all vertical lines
    Mat vertical_kernel = getStructuringElement(MORPH_RECT, Size(1, prepared_image.rows/20));
    Mat vertical_image;
    erode(prepared_image, vertical_image, vertical_kernel, Point(-1, -1));
    dilate(vertical_image, vertical_image, vertical_kernel, Point(-1, -1));
    //combine the two
    Mat lined_image;
    addWeighted(horizontal_image, 0.5, vertical_image, 0.5, 0.0, lined_image);
    //find those lines and put into contours
    findContours(lined_image, contours, hierarchy, RETR_CCOMP, CHAIN_APPROX_SIMPLE);
    //draw over contours with white
    for(int i = 0; i< contours.size(); i++) {
        drawContours(original_image, contours, i, CV_RGB(255,255,255), 5);
    }
    //==============================================================
    //prepared image is white on black image with table lines + text
    //horizontal and vertical images are white on black images with lines only
    //lined image has both horizontal and vertical lines
    //contours are drawn over the original image, so return the original image
    return original_image;
}
