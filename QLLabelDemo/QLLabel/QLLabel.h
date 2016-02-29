//
//  QLLabel.h
//  QLLabel
//
//  Created by maiqili on 16/2/19.
//  Copyright (c) 2016年 Petr Pavlik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@class QLLabel,QLLabelAttributeItem;

@interface QLLabelImageItem : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSNumber *imageHeigth;
@property (nonatomic, strong) NSNumber *imageWidth;
// 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
@property (nonatomic) CGRect imagePosition;
@end


@interface QLLabelAttributeItem : NSObject

@property (nonatomic, strong) UIColor *textColor;  // default is nil (text draws black)
@property (nonatomic, strong) UIColor *highLigthColor;  // default is nil
@property (nonatomic, strong) UIFont *font; //default is nil (system font 17 plain)
@property (nonatomic, strong) NSNumber *underline; //default is 0
@property (nonatomic, strong) NSString *text;   //default is nil
@property (nonatomic, assign) NSRange attributeRange; //default is NSRange(0,0)

@end

@protocol QLLabelDelegate <NSObject>

- (void)qlLabel:(QLLabel *)label didClickQLLabelAttributeString:(QLLabelAttributeItem *)attributeString;

@end

@interface QLLabel : UIView

@property (nonatomic,copy)   NSString           *text;            // default is nil
@property (nonatomic,retain) UIFont             *font;            // default is nil (system font 17 plain)
@property (nonatomic,retain) UIColor            *textColor;       // default is nil (text draws black)
@property (nonatomic)        NSTextAlignment    textAlignment;   // default is NSTextAlignmentLeft
@property (nonatomic)        NSLineBreakMode    lineBreakMode;   // default is NSLineBreakByWordWrapping. used for single and multiple lines of text
@property (nonatomic)       CGFloat lineSpace;                   //default is 1. lineSpace must be >= 1 && <= 20 .Other Settings about Paragraph Style ,set it into attributeText
@property (nonatomic) NSInteger numberOfLines;

@property (nonatomic, strong) NSArray *attributeItemArray;
@property (nonatomic, strong) NSArray *imageItemArray;
@property (nonatomic, strong) NSAttributedString *attributedText;  // default is nil

@property (nonatomic, weak) id <QLLabelDelegate> delegate;

@end
