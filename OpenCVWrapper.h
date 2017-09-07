//
//  OpenCVWrapper.h
//  Project
//
//  Created by Billy Cai on 2017-07-11.
//  Copyright © 2017 Billy Cai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject
//this function procees the raw image and do prepare for the showDecectedEdges function
+(double) edgeDetection:(UIImage *)image;
    
//this function draw red line on the selected picture to show where is the selecting area
+(UIImage *) showDetectedEdges:(UIImage *)image :(float)value;
    
//this functino calculate the average rgb value of the select area
+(NSArray *) averageRGB:(UIImage *)image;
@end
