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
    vector<Rect> boundRect(text_contours.size());
    vector<vector<Point>> contours_poly(text_contours.size());
    contourCenters.resize(text_contours.size());
    vector<Mat> croppedImages(text_contours.size());
    for(int i = 0; i< text_contours.size(); i++) {
        approxPolyDP(text_contours[i], contours_poly[i], 3, true);
        boundRect[i] = boundingRect(contours_poly[i]);
        contourCenters[i] = boundRect[i].tl() + (boundRect[i].br() - boundRect[i].tl())/2; //only uses ints for points, rounding should be fine
        cout << "center " << contourCenters[i] << endl;
        drawContours(dilated_text_image, contours_poly, (int)i, color);
        rectangle(dilated_text_image, boundRect[i].tl(), boundRect[i].br(), color, 2);
        // Use rectangle to define region of interest & crop image to be contained in ROI
        int ybuffer = boundRect[i].height/2;
        int xbuffer = boundRect[i].width/2;
        Rect roi(boundRect[i].x-(xbuffer/4), boundRect[i].y-(ybuffer/2), boundRect[i].width+xbuffer, boundRect[i].height+ybuffer); //buffer helps OCR
        croppedImages[i] = image(roi);
//        //help OCR
//        Mat cell_text_kernel = getStructuringElement(MORPH_RECT, Size(1, 1));
//        dilate(croppedImages[i], croppedImages[i], cell_text_kernel, Point(-1, -1));
//        GaussianBlur(croppedImages[i], croppedImages[i], Size(3, 3), 0); //needed to smooth words for OCR
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
