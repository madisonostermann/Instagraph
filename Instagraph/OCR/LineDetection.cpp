//
//  LineDetector.cpp
//  Instagraph
//
//  Created by Madison Gipson on 6/20/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

//LINE DETECTION ALGORITHM
#include "LineDetector.hpp"

using namespace cv;
using namespace std;

Mat grayscale_image;
Mat threshold_image;
Mat inverted_image;

Mat LineDetector::detect_line(Mat image) {
    
    Mat prepared_image = prepare_image(image);
    Mat final_image = isolate_lines(prepared_image);
    //Find all boxes and sort
    
    return final_image;
}

Mat LineDetector::prepare_image(Mat image) {
    //Convert to grayscale
    cvtColor(image, grayscale_image, COLOR_BGR2GRAY);
    //Threshold image
    //Original, resulting, threshold value (0), max binary value, threshold type (https://docs.opencv.org/2.4/doc/tutorials/imgproc/threshold/threshold.html)
    threshold(grayscale_image, threshold_image, 128, 255, cv::THRESH_BINARY);
    //Invert image
    bitwise_not(grayscale_image, inverted_image);
    return inverted_image;
}

Mat LineDetector::isolate_lines(Mat image) {
    cout << "width: " << image.cols << endl;
    
    //A verticle kernel of (1 X kernel_length), which will detect all the verticle lines from the image.
    //A horizontal kernel of (kernel_length X 1), which will help to detect all the horizontal line from the image.
    //A kernel of (3 X 3) ones.
    Mat vertical_kernel = cv::getStructuringElement(cv::MORPH_RECT, Size(1, image.rows/20));
    Mat horizontal_kernel = cv::getStructuringElement(cv::MORPH_RECT, Size(image.cols/20, 1));
    Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, Size(3, 3));

    //Morphological operation to detect vertical & horiztonal lines from an image
    Mat vertical_image;
    cv::erode(inverted_image, vertical_image, vertical_kernel, Point(-1, -1));
    cv::dilate(vertical_image, vertical_image, vertical_kernel, Point(-1, -1));
    Mat horizontal_image;
    cv::erode(inverted_image, horizontal_image, horizontal_kernel, Point(-1, -1));
    cv::dilate(horizontal_image, horizontal_image, horizontal_kernel, Point(-1, -1));
    
    
    //Add two image with specific weight parameter to get a third image as summation of two image.
    Mat final_image;
    cv::addWeighted(horizontal_image, 0.5, vertical_image, 0.5, 0.0, final_image);
    //cv::erode(final_image, final_image, kernel); lines turned out too light
    //Threshold again to convert back to black on white
    threshold(final_image, threshold_image, 128, 255, cv::THRESH_BINARY);
    
    return final_image;
}
