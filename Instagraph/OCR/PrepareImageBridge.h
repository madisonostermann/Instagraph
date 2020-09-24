//
//  PrepareImageBridge.h
//  Instagraph
//
//  Created by Madison Gipson on 6/20/20.
//  Copyright © 2020 Madison Gipson. All rights reserved.
//

//take an UIImage instance and return a UIImage instance with the line overlayed
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SwiftUI/SwiftUI.h>

@interface PrepareImageBridge : NSObject

- (UIImage *) deskew: (UIImage *) image;

- (NSMutableArray<UIImage*> *) splice_cells;

- (NSMutableArray *) locate_cells;

@end
