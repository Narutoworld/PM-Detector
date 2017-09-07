//
//  OpenCVWrapper.m
//  Project
//
//  Created by Billy Cai on 2017-07-11.
//  Copyright © 2017 Billy Cai. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"
#import <cmath>

#define PI 3.1415926535897

using namespace std;
using namespace cv;

@implementation OpenCVWrapper
//global variable declare
vector<vector<cv::Point>> contours;
vector<cv::Rect> rect;

    ///////////////////////////////////////////////////LINE///////////////////////////////////////////////////
+(double) edgeDetection:(UIImage *)image
{
    Mat imageMat, greyMat, binaryMat;
    vector<Vec4i> hierarchy;
    
    //process image to get contours
    UIImageToMat(image, imageMat);
    cvtColor(imageMat, greyMat, CV_RGB2GRAY);
    GaussianBlur(greyMat, greyMat, cv::Size(3,3), 0);
    adaptiveThreshold(greyMat, binaryMat, 255, ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 155, 1);
    morphologyEx(binaryMat, binaryMat, MORPH_OPEN, getStructuringElement(MORPH_ELLIPSE, cv::Size(3,3)));
    findContours(binaryMat, contours, hierarchy, RETR_CCOMP, CHAIN_APPROX_SIMPLE);
    
    sort( contours.begin( ), contours.end( ), [ ]( const vector<cv::Point>& lhs, const vector<cv::Point>& rhs )
    {
        return contourArea(lhs) > contourArea(rhs);
    });
    return computerRadiusRatio(contours[0]);
}

    ///////////////////////////////////////////////////LINE///////////////////////////////////////////////////
+(UIImage *) showDetectedEdges:(UIImage *)image : (float) value{
    Mat imageMat;
    UIImageToMat(image, imageMat);
    
    for (int i = 0; i < contours.size(); i++){
        if (computerRadiusRatio(contours[i]) > double(value)){
            drawContours(imageMat, contours, i, Scalar(255,0,0,255));
            rect = locateRectangle(boundingRect(contours[i]));
            rectangle(imageMat, rect[0], Scalar(255,0,0,255));
            rectangle(imageMat, rect[1], Scalar(255,0,0,255));
            rectangle(imageMat, rect[2], Scalar(255,0,0,255));
            return MatToUIImage(imageMat);
        }
    }
    return MatToUIImage(imageMat);
}

        ///////////////////////////////////////////////////LINE///////////////////////////////////////////////////
+(NSArray *) averageRGB:(UIImage *)image
{
    Mat imageMat;
    Mat topRoi, middleRoi, bottomRoi;
    NSMutableArray *rgb = [NSMutableArray arrayWithCapacity:3];
    
    UIImageToMat(image, imageMat);
    topRoi = imageMat(rect[0]);
    middleRoi = imageMat(rect[1]);
    bottomRoi = imageMat(rect[2]);
    
    Scalar topColor = mean(topRoi);
    Scalar middleColor = mean(middleRoi);
    Scalar bottomColor = mean(bottomRoi);
    
    double averageRedC = (topColor.val[0] + middleColor.val[0] + bottomColor.val[0])/3;
    double averageGreenC = (topColor.val[1] + middleColor.val[1] + bottomColor.val[1])/3;
    double averageBlueC = (topColor.val[2] + middleColor.val[2] + bottomColor.val[2])/3;
    
    NSNumber* averageRed = [NSNumber numberWithDouble:averageRedC];
    NSNumber* averageGreen = [NSNumber numberWithDouble:averageGreenC];
    NSNumber* averageBlue = [NSNumber numberWithDouble:averageBlueC];

    [rgb addObject:averageRed];
    [rgb addObject:averageGreen];
    [rgb addObject:averageBlue];
    
    return rgb;
}
    //helper function: compute the comparision parameter for selecting aera
double computerRadiusRatio (vector<cv::Point> contour){
    double radiusByArea = sqrt(contourArea(contour)/PI);
    double radiusByPrimeter = arcLength(contour, true)/2/PI;
    
    return radiusByArea/radiusByPrimeter;
}
    //identify the where are the three boxes
vector<cv::Rect> locateRectangle (cv::Rect rect){
    
    cv::Point centerPoint, centerPointTopLeft,centerPointBotRight;
    cv::Point topCenter, topCenterTopLeft, topCenterBotRight;
    cv::Point bottomCenter, bottomCenterTopLeft, bottomCenterBotRight;
    
    centerPoint.x = (rect.x + rect.x + rect.width)/2;
    centerPoint.y = (rect.y + rect.y + rect.height)/2;
    
    centerPointTopLeft.x = centerPoint.x - rect.width/4;
    centerPointTopLeft.y = centerPoint.y - rect.height/16;
    
    centerPointBotRight.x = centerPoint.x + rect.width/4;
    centerPointBotRight.y = centerPoint.y + rect.height/16;
    
    topCenter.x = centerPoint.x;
    topCenter.y = centerPoint.y - rect.height/3.5;
    
    topCenterTopLeft.x = topCenter.x - rect.width/4;
    topCenterTopLeft.y = topCenter.y - rect.height/16;
    
    topCenterBotRight.x = topCenter.x + rect.width/4;
    topCenterBotRight.y = topCenter.y + rect.height/16;
    
    bottomCenter.x = centerPoint.x;
    bottomCenter.y = centerPoint.y + rect.height/3.5;
    
    bottomCenterTopLeft.x = bottomCenter.x - rect.width/4;
    bottomCenterTopLeft.y = bottomCenter.y - rect.height/16;
    
    bottomCenterBotRight.x = bottomCenter.x + rect.width/4;
    bottomCenterBotRight.y = bottomCenter.y + rect.height/16;
    
    cv::Rect middle (centerPointTopLeft,centerPointBotRight);
    cv::Rect top (topCenterTopLeft, topCenterBotRight);
    cv::Rect bottom (bottomCenterTopLeft, bottomCenterBotRight);
    
    vector<cv::Rect>boundRect{top, middle, bottom};
    return boundRect;
}
    // the grey world white balance is not implemented right now, and will be improved in furture
    cv::Mat greyWorldWhiteBalance(cv::Mat frame){
        //////////////进行自动白平衡//////////////
        //分离通道
        cv::Mat srcImage, dstImage;//白平衡前、后
        vector<cv::Mat> g_vChannels;
        frame.copyTo(srcImage);
        split(srcImage, g_vChannels);
        //检测一下
        cv::Mat imageBlueChannel = g_vChannels.at(0);
        cv::Mat imageGreenChannel = g_vChannels.at(1);
        cv::Mat imageRedChannel = g_vChannels.at(2);
        
        double imageBlueChannelAvg = 0;
        double imageGreenChannelAvg = 0;
        double imageRedChannelAvg = 0;
        
        //求各通道的平均值
        imageBlueChannelAvg = mean(imageBlueChannel)[0];
        imageGreenChannelAvg = mean(imageGreenChannel)[0];
        imageRedChannelAvg = mean(imageRedChannel)[0];
        
        //求出个通道所占增益
        double K = (imageRedChannelAvg + imageGreenChannelAvg + imageBlueChannelAvg) / 3;
        double Kb = K / imageBlueChannelAvg;
        double Kg = K / imageGreenChannelAvg;
        double Kr = K / imageRedChannelAvg;
        
        //更新白平衡后的各通道BGR值
        addWeighted(imageBlueChannel, Kb, 0, 0, 0, imageBlueChannel);
        addWeighted(imageGreenChannel, Kg, 0, 0, 0, imageGreenChannel);
        addWeighted(imageRedChannel, Kr, 0, 0, 0, imageRedChannel);
        
        merge(g_vChannels, dstImage);//图像各通道合并
        dstImage.copyTo(frame);
        
        return frame;
    }

@end
