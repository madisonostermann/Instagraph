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
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    if  (image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight) {
        cols = image.size.height;
        rows = image.size.width;
    }

    cv::Mat opencvImage(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)

    CGContextRef contextRef = CGBitmapContextCreate(opencvImage.data, cols, rows, 8, opencvImage.step[0], colorSpace,  kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault); // Bitmap info flags

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);

    //--swap channels -- //
    std::vector<Mat> ch;
    cv::split(opencvImage,ch);
    std::swap(ch[0],ch[2]);
    cv::merge(ch,opencvImage);
    
    // convert colorspace to RGB
    cv::Mat convertedColorSpaceImage;
    cv::cvtColor(opencvImage, convertedColorSpaceImage, COLOR_RGBA2RGB);
    
    // Sends it to PrepareImage.cpp
    PrepareImage prepareImage;
    Mat deskewed_image = prepareImage.deskew(convertedColorSpaceImage);
    
    //Convert from Mat to UIImage
    NSData *data = [NSData dataWithBytes:deskewed_image.data length:deskewed_image.elemSize()*deskewed_image.total()];

    CGColorSpaceRef colorSpace2;
    CGBitmapInfo bitmapInfo;

    if (deskewed_image.elemSize() == 1) {
        colorSpace2 = CGColorSpaceCreateDeviceGray();
        bitmapInfo = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    } else {
        colorSpace2 = CGColorSpaceCreateDeviceRGB();
        bitmapInfo = kCGBitmapByteOrder32Little | (deskewed_image.elemSize() == 3? kCGImageAlphaNone : kCGImageAlphaNoneSkipFirst);
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(deskewed_image.cols, deskewed_image.rows, 8, 8 * deskewed_image.elemSize(),
                                        deskewed_image.step[0], colorSpace2, bitmapInfo, provider, NULL, false, kCGRenderingIntentDefault);

    // Getting UIImage from CGImage

    UIImage *deskewed_uiimage = [UIImage imageWithCGImage:imageRef scale:1 orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace2);
    
    return deskewed_uiimage;
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
