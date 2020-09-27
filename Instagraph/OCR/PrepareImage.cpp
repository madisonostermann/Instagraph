//
//  PrepareImage.cpp
//  Instagraph
//
//  Created by Madison Gipson on 6/20/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

#include "PrepareImage.hpp"
#include <vector>

using namespace cv;
using namespace std;

Scalar white = CV_RGB(255, 255, 255);
Scalar black = CV_RGB(0, 0, 0);
Scalar color = CV_RGB(0, 200, 150);
Mat original_image;
Mat deskewed_image;
vector<Point2f> contourCenters;

Mat PrepareImage::deskew(Mat image) {
    //create a copy of the image passed in and use as starting_image
    image.copyTo(original_image);
    //Binarize image
    cvtColor(image, image, COLOR_BGR2GRAY);
    //Threshold and invert image
    threshold(image, image, 0, 255, THRESH_BINARY_INV+THRESH_OTSU);
    
    //DESKEW
    vector<vector<Point> > table_outline_contours;
    vector<Vec4i> hierarchy;
    Mat first_pass(image.rows,image.cols,CV_8UC1,Scalar::all(0));
    Mat second_pass(image.rows,image.cols,CV_8UC1,Scalar::all(0));
    
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
        return image;
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
    warpPerspective(image, image, transform_matrix, image.size());
    
    //back to black on white
    threshold(image, deskewed_image, 0, 255, THRESH_BINARY_INV+THRESH_OTSU);
    
    return deskewed_image;
}

vector<Mat> PrepareImage::splice_cells() {
    if (deskewed_image.empty() == false) {
        //back to white on black
        threshold(deskewed_image, deskewed_image, 0, 255, THRESH_BINARY_INV+THRESH_OTSU);
        //Remove lines
        Mat lineless_image = remove_lines(deskewed_image);
        //detect remaining text and divide image into cells
        return detect_divide_contours(lineless_image);
    } else {
        //TODO: HAVE THIS DO SOMETHING ON THE APP END
        cout<<"DO NOT HAVE THE APPROPRIATE IMAGE TO CONTINUE"<<endl;
        return deskewed_image;
    }
}

Mat PrepareImage::remove_lines(Mat image) {
    //get all horizontal lines
    Mat horizontal_kernel = getStructuringElement(MORPH_RECT, Size(image.cols/10, 1));
    Mat horizontal_image;
    erode(image, horizontal_image, horizontal_kernel, Point(-1, -1));
    dilate(horizontal_image, horizontal_image, horizontal_kernel, Point(-1, -1));
    vector<vector<Point> > horizontal_contours;
    vector<Vec4i> horizontal_hierarchy;
    findContours(horizontal_image, horizontal_contours, horizontal_hierarchy, RETR_CCOMP, CHAIN_APPROX_SIMPLE);
    //draw over contours with black
    for(int i = 0; i< horizontal_contours.size(); i++) {
        drawContours(image, horizontal_contours, i, black, 5);
    }
    //get all vertical lines
    Mat vertical_kernel = getStructuringElement(MORPH_RECT, Size(1, image.rows/10));
    Mat vertical_image;
    erode(image, vertical_image, vertical_kernel, Point(-1, -1));
    dilate(vertical_image, vertical_image, vertical_kernel, Point(-1, -1));
    vector<vector<Point> > vertical_contours;
    vector<Vec4i> vertical_hierarchy;
    findContours(vertical_image, vertical_contours, vertical_hierarchy, RETR_CCOMP, CHAIN_APPROX_SIMPLE);
    //draw over contours with black
    for(int i = 0; i< vertical_contours.size(); i++) {
        drawContours(image, vertical_contours, i, black, 5);
    }
    
    return image;
}

vector<Mat> PrepareImage::detect_divide_contours(Mat image) {
    //dilate text
    Mat text_kernel = getStructuringElement(MORPH_RECT, Size(5, 5));
    Mat dilated_text_image;
    dilate(image, dilated_text_image, text_kernel, Point(-1, -1));
    //find external contours & their x,y,w,h
    vector<vector<Point> > text_contours;
    vector<Vec4i> hierarchy;
    findContours(dilated_text_image, text_contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    
    //get text contours and check for overlaps, merge contours with overlaps
    vector<vector<Point>> contours_poly(text_contours.size());
    vector<Rect> boundRect(text_contours.size());
    int boundingRectIndex = 0; //use separate index for boundingRects since there will be less of these than contours
    for(int i = 0; i< text_contours.size(); i++) {
        approxPolyDP(text_contours[i], contours_poly[i], 3, true);
        //create tempRect and add "buffers" to help OCR (doesn't fit text so tightly)
        Rect tempRect = boundingRect(contours_poly[i]);
        int tempybuffer = tempRect.height/2;
        int tempxbuffer = tempRect.width/2;
        tempRect.x = tempRect.x-(tempxbuffer/4);
        tempRect.y = tempRect.y-(tempybuffer/2);
        tempRect.width = tempRect.width+tempxbuffer;
        tempRect.height = tempRect.height+tempybuffer;
        bool overlap = false; //used to see if contours need to be merged or not
        
        //create a boundingRect for first contour for sure
        if (boundingRectIndex == 0) {
            boundRect[boundingRectIndex] = tempRect;
            boundingRectIndex += 1;
        } else {
            //check for overlapping contours
            for(int j = 0; j<boundingRectIndex; j++) {
                if((tempRect.y >= boundRect[j].y) && (tempRect.y <= (boundRect[j].y+boundRect[j].height))){ //if this y is within height of another
                    if((tempRect.x >= boundRect[j].x) && (tempRect.x <= (boundRect[j].x+boundRect[j].width))) { //if this x is within width of another
                        overlap = true;
                        boundRect[j].width = (tempRect.x+tempRect.width)-boundRect[j].x;
                        boundRect[j].height = (tempRect.y+tempRect.height)-boundRect[j].y;
                    }
                    if ((boundRect[j].x >= tempRect.x) && (boundRect[j].x <= (tempRect.x+tempRect.width))) { //if other x is within width of this
                        overlap = true;
                        boundRect[j].width = (boundRect[j].x+boundRect[j].width)-tempRect.x;
                        boundRect[j].x = tempRect.x;
                        boundRect[j].height = (tempRect.y+tempRect.height)-boundRect[j].y;
                    }
                }
                if ((boundRect[j].y >= tempRect.y) && (boundRect[j].y <= (tempRect.y+tempRect.height))){ //if other y is within height of this
                    if((tempRect.x >= boundRect[j].x) && (tempRect.x <= (boundRect[j].x+boundRect[j].width))) { //if this x is within width of another
                        overlap = true;
                        boundRect[j].width = (tempRect.x+tempRect.width)-boundRect[j].x;
                        boundRect[j].height = (boundRect[j].y+boundRect[j].height)-tempRect.y;
                        boundRect[j].y = tempRect.y;
                    }
                    if ((boundRect[j].x >= tempRect.x) && (boundRect[j].x <= (tempRect.x+tempRect.width))) { //if other x is within width of this
                        overlap = true;
                        boundRect[j].width = (boundRect[j].x+boundRect[j].width)-tempRect.x;
                        boundRect[j].x = tempRect.x;
                        boundRect[j].height = (boundRect[j].y+boundRect[j].height)-tempRect.y;
                        boundRect[j].y = tempRect.y;
                    }
                }
            }
            // if this new boundingRect doesn't overlap any existing ones, create a new boundRect at i
            if (overlap == false) {
                boundRect[boundingRectIndex] = tempRect;
                boundingRectIndex += 1;
            }
        }
        
    }
    //compute centers of merged contours and crop images around the rectangles
    contourCenters.resize(boundingRectIndex);
    vector<Mat> croppedImages(boundingRectIndex);
    for(int i = 0; i< boundingRectIndex; i++) {
        contourCenters[i] = Point((boundRect[i].width/2)+boundRect[i].x, (boundRect[i].height/2)+boundRect[i].y);
        Rect roi(boundRect[i].x, boundRect[i].y, boundRect[i].width, boundRect[i].height);
        if (0 <= roi.x
            && 0 <= roi.width
            //&& roi.x + roi.width <= m.cols
            && 0 <= roi.y
            && 0 <= roi.height) {
            //&& roi.y + roi.height <= m.rows){
            cout << "EVERYTHING IS FINE" << endl;
        } else {
            cout << i << endl;
            cout << "ISSUE" << endl;
        }
        croppedImages[i] = image(roi);
    }
    return croppedImages;
}

vector<Point2f> PrepareImage::locate_cells() {
    if (contourCenters.empty() == false) {
        return contourCenters;
    } else {
        //TODO: HAVE THIS DO SOMETHING ON THE APP END
        cout<<"NO CELL CENTERS SPECIFIED"<<endl;
        return contourCenters;
    }
}


// NOT USED //
//Mat PrepareImage::adjust_brightness_and_contrast(Mat image) {
//
//    // establish number of bins & set range
//    int histSize = 256;
//    float range[] = {0, 256};
//    const float* histRange = {range};
//
//    // create matrix for histogram
//    Mat hist;
//    calcHist(&image, 1, 0, Mat(), hist, 1, &histSize, &histRange, true/*uniform*/, false/*accumulate*/);
//    minMaxLoc(hist, 0, 0/*max_val*/);
//
//    // calculate cumulative distribution from the histogram
//    vector<float> accumulator(histSize);
//    accumulator[0] = hist.at<float>(0);
//    for (int i = 1; i < histSize; i++) {
//        accumulator[i] = accumulator[i - 1] + hist.at<float>(i);
//    }
//
//    // locate points that cuts at required value
//    float max = accumulator.back();
//    float clipHistPercent = 0;
//    clipHistPercent *= (max / 100.0); //make percent as absolute
//    clipHistPercent /= 2.0; // left and right wings
//
//    // locate left and right cuts
//    double minGray = 0;
//    while (accumulator[minGray] < clipHistPercent)
//        minGray++;
//
//    double maxGray = histSize - 1;
//    while (accumulator[maxGray] >= (max - clipHistPercent))
//        maxGray--;
//
//    // calculate optimal contrast and brightness from maxGray & minGray
//    double alpha = 255 / (maxGray - minGray); //contrast
//    double beta = -minGray * alpha; //brightness
//
//    // apply contrast and brightness to image
//    convertScaleAbs(image, image, alpha, beta);
//
//    return image;
//}
