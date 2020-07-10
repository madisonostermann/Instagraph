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

Scalar white = CV_RGB(255, 255, 255);
Scalar black = CV_RGB(0, 0, 0);
Mat original_image;

Mat ClearLines::clear_line(Mat image) {
    //preserve original_image
    image.copyTo(original_image);
    //Convert to grayscale
    cvtColor(image, image, COLOR_BGR2GRAY);
    //Threshold and invert image
    threshold(image, image, 0, 255, THRESH_BINARY_INV+THRESH_OTSU);
    //Correct perspective (unskew)
    correct_perspective(image);
    //Clean up image for easier OCR
    
    //Remove lines
    return remove_lines(image);
}

Mat ClearLines::correct_perspective(Mat image) {
    vector<vector<Point> > table_outline_contours;
    vector<Vec4i> hierarchy;
    Mat first_pass(image.rows,image.cols,CV_8UC1,Scalar::all(0));
    Mat second_pass(image.rows,image.cols,CV_8UC1,Scalar::all(0));
    Mat transformed_image = Mat::zeros(image.rows, image.cols, CV_8UC3);
    
    //detect & draw external lines- may pick up lines inside the table this time
    findContours(image, table_outline_contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    for(int i = 0; i< table_outline_contours.size(); i++) {
        drawContours(first_pass, table_outline_contours, i, white, 5);
    }
    //detect external lines a second time- will only pick up table outline- and fill the shape
    findContours(first_pass, table_outline_contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    drawContours(second_pass, table_outline_contours, 0, white, FILLED);
    
    //approximate the contour to get corners
    vector<vector<Point> > appx_table_contours(1);
    approxPolyDP(Mat(table_outline_contours[0]), appx_table_contours[0], 25, true);
    //get the bounding rectangle of the approximate contour- this is where the image will be transformed to
    Rect boundedRect = boundingRect(table_outline_contours[0]);
    //only correct perspective if there's 4 corners detected, otherwise give an error
    if(appx_table_contours[0].size() != 4) {
        //TODO: HAVE THIS DO SOMETHING ON THE APP END
        cout<<"DID NOT DETECT 4 CORNERS OF TABLE, ABORTING PERSPECTIVE CORRECTION"<<endl;
        return original_image;
    }
    
    //each appx_table_contour point is a corner of the table
    std::vector<Point2f> table_corners;
    table_corners.push_back(Point2f(appx_table_contours[0][0].x,appx_table_contours[0][0].y));
    table_corners.push_back(Point2f(appx_table_contours[0][1].x,appx_table_contours[0][1].y));
    table_corners.push_back(Point2f(appx_table_contours[0][3].x,appx_table_contours[0][3].y));
    table_corners.push_back(Point2f(appx_table_contours[0][2].x,appx_table_contours[0][2].y));
    //each coordinate in boundedRect is a corner of the area image is being transformed to
    std::vector<Point2f> dest_corners;
    dest_corners.push_back(Point2f(boundedRect.x,boundedRect.y));
    dest_corners.push_back(Point2f(boundedRect.x,boundedRect.y+boundedRect.height));
    dest_corners.push_back(Point2f(boundedRect.x+boundedRect.width,boundedRect.y));
    dest_corners.push_back(Point2f(boundedRect.x+boundedRect.width,boundedRect.y+boundedRect.height));
    
    //calculate perspective transform from four pairs of corresponding points
    Mat transform_matrix = getPerspectiveTransform(table_corners, dest_corners);
    //tranforms image to transformed_image by mapping points in transform_matrix
    warpPerspective(image, transformed_image, transform_matrix, image.size());
    return transformed_image;
}

Mat ClearLines::remove_lines(Mat image) {
    vector<vector<Point> > all_contours;
    vector<Vec4i> hierarchy;
    //get all horizontal lines
    Mat horizontal_kernel = getStructuringElement(MORPH_RECT, Size(image.cols/10, 1));
    Mat horizontal_image;
    erode(image, horizontal_image, horizontal_kernel, Point(-1, -1));
    dilate(horizontal_image, horizontal_image, horizontal_kernel, Point(-1, -1));
    //get all vertical lines
    Mat vertical_kernel = getStructuringElement(MORPH_RECT, Size(1, image.rows/10));
    Mat vertical_image;
    erode(image, vertical_image, vertical_kernel, Point(-1, -1));
    dilate(vertical_image, vertical_image, vertical_kernel, Point(-1, -1));
    //combine the two
    Mat lined_image;
    addWeighted(horizontal_image, 0.5, vertical_image, 0.5, 0.0, lined_image);
    //find those lines and put into contours
    //findContours(lined_image, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE); //perspective correction- outside edges
    findContours(lined_image, all_contours, hierarchy, RETR_CCOMP, CHAIN_APPROX_SIMPLE);
    //draw over contours with white
    for(int i = 0; i< all_contours.size(); i++) {
        drawContours(original_image, all_contours, i, white, 5);
    }
    //==============================================================
    //prepared image is white on black image with table lines + text
    //horizontal and vertical images are white on black images with lines only
    //lined image has both horizontal and vertical lines
    //contours are drawn over the original image, so return the original image
    return original_image;
}
