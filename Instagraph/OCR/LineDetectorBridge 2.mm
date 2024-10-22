//
//  LineDetectorBridge.mm
//  Instagraph
//
//  Created by Madison Gipson on 6/20/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//


//The extra m tells Xcode that this an Objective-C++ file & it's now allowed to use C++ from within.
//Converts UIImages into OpenCV image representation. Then it runs line detection which returns an image with lane overlayed on top of it. And finally converts the OpenCV image representation back to UIImage.
#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "LineDetectorBridge.h"
#include "LineDetector.hpp"

@implementation LineDetectorBridge : NSObject

- (UIImage *) detectLineIn: (UIImage *) image {
    
    // convert uiimage to mat
    cv::Mat opencvImage;
    UIImageToMat(image, opencvImage, true);
    
    // convert colorspace to the one expected by the line detector algorithm (RGB)
    cv::Mat convertedColorSpaceImage;
    cv::cvtColor(opencvImage, convertedColorSpaceImage, COLOR_RGBA2RGB);
    
    // Run line detection
    // Sends it to LineDetector.cpp
    LineDetector lineDetector;
    cv::Mat imageWithLineDetected = lineDetector.detect_line(convertedColorSpaceImage);
    
    // convert mat to uiimage and return it to the caller (LineDetectorBridge.h)
    return MatToUIImage(imageWithLineDetected);
}

@end
