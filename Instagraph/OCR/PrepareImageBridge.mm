//
//  PrepareImageBridge.mm
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
#import "PrepareImageBridge.h"
#include "PrepareImage.hpp"

@implementation PrepareImageBridge : NSObject

- (UIImage *) deskew: (UIImage *) image {
    // convert uiimage to mat
    cv::Mat opencvImage;
    UIImageToMat(image, opencvImage, true);
    
    // convert colorspace to RGB
    cv::Mat convertedColorSpaceImage;
    cv::cvtColor(opencvImage, convertedColorSpaceImage, COLOR_RGBA2RGB);
    
    // Sends it to PrepareImage.cpp
    PrepareImage prepareImage;
    Mat deskewed_image = prepareImage.deskew(convertedColorSpaceImage);
    
    return MatToUIImage(deskewed_image);
}

- (NSMutableArray<UIImage*> *) splice_cells {
    // Sends it to PrepareImage.cpp
    PrepareImage prepareImage;
    vector<Mat> croppedImages = prepareImage.splice_cells();
    
    // convert mat to uiimage and return it to the caller (PrepareImageBridge.h)
    NSMutableArray<UIImage*> *images = [NSMutableArray arrayWithCapacity:croppedImages.size()];
    for(int i=0; i<croppedImages.size(); i++){
        [images insertObject:(MatToUIImage(croppedImages[i])) atIndex:i];
    }
    return images;
}

- (NSMutableArray *) locate_cells {
    // Sends it to PrepareImage.cpp
    PrepareImage prepareImage;
    vector<Point2f> text_locations = prepareImage.locate_cells();

    NSMutableArray *locations = [NSMutableArray arrayWithCapacity:text_locations.size()];
    for(int i=0; i<text_locations.size(); i++){
        [locations insertObject: [NSValue valueWithCGPoint: CGPointMake(text_locations[i].x, text_locations[i].y)] atIndex:i];
    }

    return locations;
}

@end
