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
        //back to black on white
        threshold(image, deskewed_image, 0, 255, THRESH_BINARY_INV+THRESH_OTSU);
        return deskewed_image;
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
    
    //if place where point will end up is way far away, don't move it (perspective correction might be totally off of trying to rotate table)
    if ((boundedRect.x > appx_table_contours[0][0].x+(appx_table_contours[0][0].x/2)) || (boundedRect.x < appx_table_contours[0][0].x/2) ||
        (boundedRect.y > appx_table_contours[0][0].y+(appx_table_contours[0][0].y/2)) || (boundedRect.y < appx_table_contours[0][0].y/2)) {
        cout<<"PERSPECTIVE CORRECTION TOO DRAMATIC, PROCEDING WITH ORIGINAL IMAGE"<<endl;
        //back to black on white
        threshold(image, deskewed_image, 0, 255, THRESH_BINARY_INV+THRESH_OTSU);
        return deskewed_image;
    }
    
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
    Mat horizontal_kernel = getStructuringElement(MORPH_RECT, Size(image.cols/20, 1));
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
    Mat vertical_kernel = getStructuringElement(MORPH_RECT, Size(1, image.rows/20));
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

void thinningGuoHallIteration(cv::Mat& im, int iter)
{
    cv::Mat marker = cv::Mat::zeros(im.size(), CV_8UC1);

    for (int i = 1; i < im.rows; i++)
    {
        for (int j = 1; j < im.cols; j++)
        {
            uchar p2 = im.at<uchar>(i-1, j);
            uchar p3 = im.at<uchar>(i-1, j+1);
            uchar p4 = im.at<uchar>(i, j+1);
            uchar p5 = im.at<uchar>(i+1, j+1);
            uchar p6 = im.at<uchar>(i+1, j);
            uchar p7 = im.at<uchar>(i+1, j-1);
            uchar p8 = im.at<uchar>(i, j-1);
            uchar p9 = im.at<uchar>(i-1, j-1);

            int C  = (!p2 & (p3 | p4)) + (!p4 & (p5 | p6)) +
                     (!p6 & (p7 | p8)) + (!p8 & (p9 | p2));
            int N1 = (p9 | p2) + (p3 | p4) + (p5 | p6) + (p7 | p8);
            int N2 = (p2 | p3) + (p4 | p5) + (p6 | p7) + (p8 | p9);
            int N  = N1 < N2 ? N1 : N2;
            int m  = iter == 0 ? ((p6 | p7 | !p9) & p8) : ((p2 | p3 | !p5) & p4);

            if (C == 1 && (N >= 2 && N <= 3) & m == 0)
                marker.at<uchar>(i,j) = 1;
        }
    }

    im &= ~marker;
}

void thinningGuoHall(cv::Mat& im)
{
    im /= 255;

    cv::Mat prev = cv::Mat::zeros(im.size(), CV_8UC1);
    cv::Mat diff;

    do {
        thinningGuoHallIteration(im, 0);
        thinningGuoHallIteration(im, 1);
        cv::absdiff(im, prev, diff);
        im.copyTo(prev);
    }
    while (cv::countNonZero(diff) > 0);

    im *= 255;
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
        Rect tempRect = boundingRect(contours_poly[i]);
        
        //add buffers for identifying overlap
        int buffer = 0;
        if (tempRect.height >= tempRect.width) {
            buffer = tempRect.width;
        } else {
            buffer = tempRect.height;
        }
        tempRect.x -= buffer/2;
        tempRect.y -= buffer/2;
        tempRect.width += buffer;
        tempRect.height += buffer;
        //make sure that adding the buffers didn't make the rectangle outside of the actual image dimensions
        if (tempRect.x < 0) { tempRect.x = 0; }
        if (tempRect.width < 0) { tempRect.width = 0; }
        if (tempRect.y < 0) { tempRect.y = 0; }
        if (tempRect.height < 0) { tempRect.height = 0; }
        if (tempRect.x + tempRect.width > image.cols) {
            tempRect.x = 0;
            tempRect.width = image.cols;
        }
        if (tempRect.y + tempRect.height > image.rows) {
            tempRect.y = 0;
            tempRect.height = image.rows;
        }

        bool overlap = false; //used to see if contours need to be merged or not

        //create a boundingRect for first contour for sure
        if (boundingRectIndex == 0) {
            if(tempRect.height < image.size().height && tempRect.width < image.size().width) {
                boundRect[boundingRectIndex] = tempRect;
                boundingRectIndex += 1;
            }
        } else {
            //check for overlapping contours
            for(int j = 0; j<boundingRectIndex; j++) {
                overlap = false;
                int left_1 = boundRect[j].x;
                int right_1 = boundRect[j].x+boundRect[j].width;
                int top_1 = boundRect[j].y;
                int bottom_1 = boundRect[j].y+boundRect[j].height;
                int midY_1 = (bottom_1+top_1)/2;
                int left_2 = tempRect.x;
                int right_2 = tempRect.x+tempRect.width;
                int top_2 = tempRect.y;
                int bottom_2 = tempRect.y+tempRect.height;
                int midY_2 = (bottom_2+top_2)/2;
                if(((right_2 > left_1 && right_2 < right_1) || (left_2 > left_1 && left_2 < right_1)) &&
                    ((midY_1 > top_2 && midY_1 < bottom_2) || (midY_2 > top_1 && midY_2 < bottom_1))){
                    overlap = true;
                    if(boundRect[j].y > tempRect.y) {
                        boundRect[j].height = boundRect[j].y-tempRect.y+boundRect[j].height;
                        boundRect[j].y = tempRect.y;
                    } else {
                        boundRect[j].height = tempRect.y-boundRect[j].y+tempRect.height;
                    }
                    if(boundRect[j].x > tempRect.x) {
                        boundRect[j].width = boundRect[j].x-tempRect.x+boundRect[j].width;
                        boundRect[j].x = tempRect.x;
                    } else {
                        boundRect[j].width = tempRect.x-boundRect[j].x+tempRect.width;
                    }
                    break;
                }
            }
            // if this new boundingRect doesn't overlap any existing ones, create a new boundRect at i
            if (overlap == false) {
                if(tempRect.height < image.size().height && tempRect.width < image.size().width) {
                    boundRect[boundingRectIndex] = tempRect;
                    boundingRectIndex += 1;
                }
            }
        }
        
    }
    
    //compute centers of merged contours and crop images around the rectangles
    contourCenters.resize(boundingRectIndex);
    vector<Mat> croppedImages(boundingRectIndex);
    vector<Rect> existingROI(boundingRectIndex);
    for(int i = 0; i<boundingRectIndex; i++) {
        contourCenters[i] = Point((boundRect[i].width/2)+boundRect[i].x, (boundRect[i].height/2)+boundRect[i].y);
        Rect roi(boundRect[i].x, boundRect[i].y, boundRect[i].width, boundRect[i].height);
//        Mat src = image(roi);
//        cv::Mat dest(src.rows*2, src.cols*2, CV_8UC1, black);
//        src.copyTo(dest(cv::Rect(src.cols/2, src.rows/2, src.cols, src.rows)));

//        thinningGuoHall(dest);
//        Mat text_kernel = getStructuringElement(MORPH_RECT, Size(2, 2));
//        Mat new_image;
//        dilate(dest, new_image, text_kernel, Point(-1, -1));

        croppedImages[i] = image(roi); //dest; //new_image;
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
