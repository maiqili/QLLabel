//
//  ViewController.m
//  QLLabelDemo
//
//  Created by maiqili on 16/2/25.
//  Copyright © 2016年 maiqili. All rights reserved.
//

#import "ViewController.h"
#import "QLLabel.h"
@interface ViewController ()
@property (nonatomic, strong) QLLabel *textLabel;
@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textLabel = [[QLLabel alloc] initWithFrame:CGRectMake(50, 150, 250, 180)];
    self.textLabel.text = @"目需要所以简单www.baidu.com的研究了下protobuf。我也是参照网上的博客，所以大部分内容我也就不重复造轮子了。首先protobuf介绍点击这里，使用介绍点击这里，使用demo看 这里 。我个人s的第一个例子也是参照这个 demo 来的，不过其中我有遇到一www.baidu.com的研究了下protobuf。我也是参照网上的博客，所以大部分内容我也就不重复造轮子了。首先protobuf介绍点击这里，使用介绍点击这里，使用demo看 这里 。我个人s的第一个例子也是参照这个 demo 来的，不过其中我有遇到一www.baidu.com的研究了下protobuf。我也是参照网上的博客，所以大部分内容我也就不重复造轮子了。首先protobuf介绍点击这里，使用介绍点击这里，使用demo看 这里 。我个人s的第一个例子也是参照这个 demo 来的，不过其中我有遇到一www.baidu.com的研究了下protobuf。我也是参照网上的博客，所以大部分内容我也就不重复造轮子了。首先protobuf介绍点击这里，使用介绍点击这里，使用demo看 这里 。我个人s的第一个例子也是参照这个 demo 来的，不过其中我有遇到一www.baidu.com的研究了下protobuf。我也是参照网上的博客，所以大部分内容我也就不重复造轮子了。首先protobuf介绍点击这里，使用介绍点击这里，使用demo看 这里 。我个人s的第一个例子也是参照这个 demo 来的，不过其中我有遇到一😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊”、“😂”“😊”、“😂”“😊”、“😂”“😊”、“😂”“😊”、“😂”目需要所以简单www.baidu.com的研究了下protobuf。我也是参照网上的博客，所以大部分内容我也就不重复造轮子了。首先protobuf介绍点击这里，使用介绍点击这里，使用demo看 这里 。我个人s的第一个例子也是参照这个 demo 来的，不过其中我有遇到一www.baidu.com的研究了下protobuf。我也是参照网上的博客，所以大部分内容我也就不重复造轮子了。首先protobuf介绍点击这里，使用介绍点击这里，使用demo看 这里 。我个人s的第一个例子也是参照这个 demo 来的，不过其中我有遇到一www.baidu.com的研究了下protobuf。我也是参照网上的博客，所以大部分内容我也就不重复造轮子了。首先protobuf介绍点击这里，使用介绍点击这里，使用demo看 这里 。我个人s的第一个例子也是参照这个 demo 来的，不过其中我有遇到一www.baidu.com的研究了下protobuf。我也是参照网上的博客，所以大部分内容我也就不重复造轮子了。首先protobuf介绍点击这里，使用介绍点击这里，使用demo看 这里 。我个人s的第一个例子也是参照这个 demo 来的，不过其中我有遇到一www.baidu.com的研究了下protobuf。我也是参照网上的博客，所以大部分内容我也就不重复造轮子了。首先protobuf介绍点击这里，使用介绍点击这里，使用demo看 这里 。我个人s的第一个例子也是参照这个 demo 来的，不过其中我有遇到一";
    QLLabelAttributeItem *attributeItem = [[QLLabelAttributeItem alloc] init];
    attributeItem.textColor = [UIColor blueColor];
    attributeItem.attributeRange = NSMakeRange(6, 3);
    attributeItem.highLigthColor = [UIColor blackColor];
    attributeItem.underline = @1;
    attributeItem.font = [UIFont systemFontOfSize:17];
    QLLabelAttributeItem *attributeItem2 = [[QLLabelAttributeItem alloc] init];
    attributeItem2.textColor = [UIColor yellowColor];
    attributeItem2.attributeRange = NSMakeRange(64, 7);
    attributeItem2.highLigthColor = [UIColor redColor];
    attributeItem2.font = [UIFont systemFontOfSize:28];
    QLLabelAttributeItem *attributeItem3 = [[QLLabelAttributeItem alloc] init];
    attributeItem3.textColor = [UIColor yellowColor];
    attributeItem3.attributeRange = NSMakeRange(38, 2);
    attributeItem3.highLigthColor = [UIColor redColor];
    attributeItem3.font = [UIFont systemFontOfSize:30];
    //    self.coreTextView.lineSpace = 1;
    self.textLabel.numberOfLines = 7;
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    self.textLabel.attributeItemArray = [NSArray arrayWithObjects:attributeItem,attributeItem2,attributeItem3,nil];
    QLLabelImageItem *image = [[QLLabelImageItem alloc] init];
    image.image = [UIImage imageNamed:@"coretext-img-1"];
    image.imageHeigth = @30;
    image.imageWidth = @30;
    image.index = 5;
    QLLabelImageItem *image2 = [[QLLabelImageItem alloc] init];
    image2.image = [UIImage imageNamed:@"coretext-img-1"];
    image2.imageHeigth = @20;
    image2.imageWidth = @30;
    image2.index = 28;
    self.textLabel.imageItemArray = [NSArray arrayWithObjects:image,image2,nil];
    //    [self.coreTextView sizeToFit];
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
    self.textLabel.delegate = self;
    //    [textLabel sizeToFit];
    [self.view addSubview:self.textLabel];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)qlLabel:(QLLabel *)label didClickQLLabelAttributeString:(QLLabelAttributeItem *)attributeString
{
    NSLog(@"点击了:%@",attributeString.text);
}
@end
