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
    
    Mat prepared_image = prepare_image(image); //after graysclae, threshold and inversion
    Mat lined_image = isolate_lines(prepared_image); //with just table lines
    //pass in lined image for contour finding
    //pass in prepared image so the image you're cropping has text
    Mat table_cell_image = find_contours(lined_image, prepared_image);
    
    return table_cell_image;
}

Mat LineDetector::prepare_image(Mat image) {
    //Convert to grayscale
    cvtColor(image, grayscale_image, COLOR_BGR2GRAY);
    //Threshold image
    //Original, resulting, threshold value (0), max binary value, threshold type (https://docs.opencv.org/2.4/doc/tutorials/imgproc/threshold/threshold.html)
    threshold(grayscale_image, threshold_image, 128, 255, THRESH_BINARY);
    //Invert image
    bitwise_not(grayscale_image, inverted_image);
    return inverted_image;
}

Mat LineDetector::isolate_lines(Mat image) {
    //Vertical kernel of (1 X kernel_length) and horizontal kernel of (kernel_length X 1), which will help to detect all vertical/horizontal lines from the image.
    Mat vertical_kernel = getStructuringElement(MORPH_RECT, Size(1, image.rows/20));
    Mat horizontal_kernel = getStructuringElement(MORPH_RECT, Size(image.cols/20, 1));
    Mat kernel = getStructuringElement(MORPH_RECT, Size(3, 3));
    
    //Morphological operation to detect vertical & horiztonal lines from an image
    Mat vertical_image;
    erode(inverted_image, vertical_image, vertical_kernel, Point(-1, -1));
    dilate(vertical_image, vertical_image, vertical_kernel, Point(-1, -1));
    Mat horizontal_image;
    erode(inverted_image, horizontal_image, horizontal_kernel, Point(-1, -1));
    dilate(horizontal_image, horizontal_image, horizontal_kernel, Point(-1, -1));
    
    //Add two image with specific weight parameter to get a third image as summation of two image.
    Mat lined_image;
    addWeighted(horizontal_image, 0.5, vertical_image, 0.5, 0.0, lined_image);
    //erode(final_image, final_image, kernel); lines turned out too light
    //Threshold again to convert back to black on white
    threshold(lined_image, threshold_image, 128, 255, THRESH_BINARY);
    
    return lined_image;
}

struct left_to_right_contour_sorter
{
    bool operator ()( const vector<Point>& a, const vector<Point> & b )
    {
        Rect ra(boundingRect(a));
        Rect rb(boundingRect(b));
        //return (ra.x > rb.x); //right to left
        return ((ra.x + 1000*ra.y) < (rb.x + 1000*rb.y));
    }
};

Mat LineDetector::find_contours(Mat lined_image, Mat original_image) {
    //Find contours for image, which will detect all the cells
    vector<vector<Point> > contours;
    vector<Vec4i> hierarchy;
    Canny(lined_image, lined_image, 100, 200, 3);
    findContours(lined_image, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );
    Mat contoured_image = Mat::zeros(lined_image.size(), CV_8UC3);
    for( int i = 0; i< contours.size(); i++ ) {
        drawContours(contoured_image, contours, i, CV_RGB(255,0,0));
        rectangle(contoured_image, boundingRect(contours[i]), CV_RGB(0,255,0), 2);
    }
    //Sort all the contours by top to bottom.
    sort(contours.begin(), contours.end(), left_to_right_contour_sorter());
    //Translate all contours to bounding rectangles, then crop prepared image into those bounds
    Mat image_array[contours.size()];
    int counter = 0;
    for(int i=0; i<contours.size(); i++) {
        if(boundingRect(contours[i]).width>20 && boundingRect(contours[i]).height>20) {
            Rect bounds(boundingRect(contours[i]).x, boundingRect(contours[i]).y, boundingRect(contours[i]).width, boundingRect(contours[i]).height);
            if(!original_image(bounds).empty()) {
                image_array[counter] = original_image(bounds);
                counter++;
            }
        }
    }
    return image_array[0];
}
