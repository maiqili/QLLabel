//
//  QLLabel.m
//  QLLabel
//
//  Created by maiqili on 16/2/19.
//  Copyright (c) 2016年 Petr Pavlik. All rights reserved.
//

#import "QLLabel.h"

#define QLHeadLineTailOffSet 3
#define QLRangeNotFound NSMakeRange(0, 0)
#define QLRangeContain(rangeA, rangeB) (rangeA.length >= rangeB.length && ((rangeA.location <= rangeB.location) && (NSMaxRange(rangeA) >= NSMaxRange(rangeB))))?YES:NO
static NSString* const kEllipsesCharacter = @"\u2026";// 省略号

@implementation QLLabelAttributeItem
-(instancetype)init
{
    self = [super init];
    if (self) {
        _textColor = [UIColor blackColor];  // default is nil (text draws black)
        _highLigthColor = nil;  // default is nil
        _font = [UIFont systemFontOfSize:17]; //default is nil (system font 17 plain)
        _underline = @0; //default is 0
        _text = nil;   //default is nil
        _attributeRange = NSMakeRange(0, 0); //default is NSRange(0,0)
    }
    return self;
}
@end
@interface QLLabel()
@property (nonatomic, assign) CGRect textRect;
@property (nonatomic, assign) BOOL hasDisPlayed; //defluat is NO 当已经绘制了一遍时，改变部分属性，需重新绘制
@property (nonatomic, assign) NSRange selectAttributeItemRange;
@property (nonatomic, strong) NSMutableAttributedString *displayAttributeString; //真正绘制的atttributeString，经过长度修改的atttributeString，增加长度判断和拼接省略号等操作
@property (nonatomic, strong) NSMutableAttributedString *selectAttributeString; //选择状态下的displayAttributeString，相当于displayAttributeString的替身，用于，点击时改变点击文字的颜色
//@property (nonatomic, assign) CTFrameRef coretextRef;//绘制的缓存矩形框参数
@end

//CFAttributedStringRef ：属性字符串，用于存储需要绘制的文字字符和字符属性
//CTFramesetterRef：通过CFAttributedStringRef进行初始化，作为CTFrame对象的生产工厂，负责根据path创建对应的CTFrame
//CTFrame是指整个该UIView子控件的绘制区域
//CTLine则是指每一行
//CTRun则是每一段具有一样属性的字符串
@implementation QLLabel

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _font = [UIFont systemFontOfSize:17];
        _textColor = [UIColor blackColor];
        _textAlignment = NSTextAlignmentLeft;
        _lineBreakMode = NSLineBreakByWordWrapping;
        _lineSpace = 1;
        _numberOfLines = 1;
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

-(void)sizeToFit
{
    [super sizeToFit];
    
    _numberOfLines = 0;
    [self setParameterToAttributeText];
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, _attributedText.length), NULL, CGSizeMake(CGRectGetWidth(self.bounds), MAXFLOAT), NULL);
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), suggestSize.width, suggestSize.height);
//    self.bounds = CGRectMake(0, 0, suggestSize.width, suggestSize.height);
    
    CFRelease(framesetterRef);
}

-(void)setText:(NSString *)text
{
    _text = text;
    _attributeItemArray = nil;
    if (_hasDisPlayed) {
        [self setNeedsDisplay];
    }
}

-(void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    if (_hasDisPlayed) {
        [self setNeedsDisplay];
    }
}

-(void)setFont:(UIFont *)font
{
    _font = font;
    if (_hasDisPlayed) {
        [self setNeedsDisplay];
    }
}

-(void)setLineSpace:(CGFloat)lineSpace
{
    lineSpace = lineSpace>=1?lineSpace:1;
    lineSpace = lineSpace<=20?lineSpace:20;
    _lineSpace = lineSpace;
    if (_hasDisPlayed) {
        [self setNeedsDisplay];
    }
}

-(void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    if (_hasDisPlayed) {
        [self setNeedsDisplay];
    }
}

-(void)setAttributeItemArray:(NSArray *)attributeItemArray
{
    _attributeItemArray = [attributeItemArray copy];
    if (_hasDisPlayed) {
        [self setNeedsDisplay];
    }
}

-(void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    _lineBreakMode = lineBreakMode;
    if (_hasDisPlayed) {
        [self setNeedsDisplay];
    }
}

-(void)setNumberOfLines:(NSInteger)numberOfLines
{
    _numberOfLines = numberOfLines;
    if (_hasDisPlayed) {
        [self setNeedsDisplay];
    }
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    _attributedText = attributedText;
    if (_hasDisPlayed) {
        [self setNeedsDisplay];
    }
}

-(NSAttributedString *)getEllipsesAttributeString
{
    NSDictionary *dict = @{
                           NSFontAttributeName:_font,
                           NSForegroundColorAttributeName:_textColor,
                           //                           NSKernAttributeName:@(2)
                           };
    return [[NSAttributedString alloc] initWithString:kEllipsesCharacter attributes:dict];
}

//初始化attributeText
- (void)setParameterToAttributeText
{
    NSMutableAttributedString *mutableAttributedString;
    if (_attributedText) {
        mutableAttributedString = [_attributedText mutableCopy];
    }else {
        if (_text.length != 0) {
            mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:_text];
        }
    }
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, mutableAttributedString.length)];
    [mutableAttributedString addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, mutableAttributedString.length)];
    // 设置行距等样式
    CGFloat lineSpace = _lineSpace;
    CGFloat lineSpaceMax = 20;
    CGFloat lineSpaceMin = 1;
    const CFIndex kNumberOfSettings = 4;
    
    //创建文本对齐方式
    CTTextAlignment alignment = [self getValueWithTextAlignment:_textAlignment] ;//kCTNaturalTextAlignment;
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
    alignmentStyle.valueSize=sizeof(alignment);
    alignmentStyle.value=&alignment;
    
    // 结构体数组
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&lineSpaceMax},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&lineSpaceMin},
        {kCTParagraphStyleSpecifierAlignment,sizeof(alignment),&alignment}
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    // 将设置的行距应用于整段文字
    [mutableAttributedString addAttribute:NSParagraphStyleAttributeName value:(__bridge id)(theParagraphRef) range:NSMakeRange(0, mutableAttributedString.length)];
    
    CFRelease(theParagraphRef);
    for (QLLabelAttributeItem *attributeItem in _attributeItemArray) {
        NSDictionary *attributeDict = @{
                                        NSForegroundColorAttributeName:(id)attributeItem.textColor,
                                        NSFontAttributeName:(id)attributeItem.font,
                                        NSUnderlineStyleAttributeName:(id)attributeItem.underline
                                        };
        [mutableAttributedString addAttributes:attributeDict range:attributeItem.attributeRange];
    }
    self.attributedText = mutableAttributedString;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self setParameterToAttributeText];
    
    if (!_selectAttributeString) {
        _textRect = [self textRectWithNumberOfLines:_numberOfLines withAttributeString:[_attributedText mutableCopy]];
        _displayAttributeString = [self lineCutAttributeStringWithTextRect:_textRect andAttributeString:[_attributedText mutableCopy]];
    }
   
    
    NSMutableAttributedString *drawAttribute = _selectAttributeString?_selectAttributeString:_displayAttributeString;
    
    if (drawAttribute.length == 0) {
        return;
    }
    
    // 步骤 1 得到当前用于绘制画布的上下文，用于后续将内容绘制在画布上
    // 因为Core Text要配合Core Graphic 配合使用的，如Core Graphic一样，绘图的时候需要获得当前的上下文进行绘制
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 步骤 2 翻转当前的坐标系（因为对于底层绘制引擎来说，屏幕坐下角为（0，0））
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 步骤 3 创建绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, _textRect);
    
    // 步骤4：根据AttributedString生成CTFramesetterRef
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)drawAttribute);
    CTFrameRef frame =
    CTFramesetterCreateFrame(framesetter,
                             CFRangeMake(0, [drawAttribute length]), path, NULL);
    
    // 步骤 6 进行绘制
    CTFrameDraw(frame, context);
    
    _hasDisPlayed = YES;
    // 步骤 7 内存释放管理
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

- (CGRect)textRectWithNumberOfLines:(NSInteger)lineNumber withAttributeString:(NSMutableAttributedString *)attributeString
{
    CGFloat textHeigth = 0;
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, attributeString.length), NULL, CGSizeMake(CGRectGetWidth(self.bounds), MAXFLOAT), NULL);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributeString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    CTFrameRef textFrame;
    textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributeString length]), path, NULL);
    
    //获得显示行数的高度
    CFArrayRef lines = CTFrameGetLines(textFrame);
    CFIndex count = CFArrayGetCount(lines);
    
    if (lineNumber > 0) {
        if (count == 0) {
            CFRelease(framesetterRef);
            CFRelease(framesetter);
            CFRelease(textFrame);
            CFRelease(path);
            return self.bounds;
        }
        NSInteger numberOfLines = MIN(lineNumber, count);
        CTLineRef line = CFArrayGetValueAtIndex(lines, numberOfLines-1);
        CFRange lastLineRange = CTLineGetStringRange(line);
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
        NSMutableAttributedString *maxAttributedString = [[attributeString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
        
        CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)maxAttributedString);
        CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, maxAttributedString.length), NULL, CGSizeMake(CGRectGetWidth(self.bounds), MAXFLOAT), NULL);
        
        textHeigth = MIN(suggestSize.height + QLHeadLineTailOffSet, CGRectGetHeight(self.bounds));
        
        CFRelease(framesetterRef);
    }else{
        textHeigth = MIN(suggestSize.height, CGRectGetHeight(self.bounds));
    }
    CFRelease(framesetterRef);
    CFRelease(framesetter);
    CFRelease(textFrame);
    CFRelease(path);
    return CGRectMake(0, (CGRectGetHeight(self.bounds)-textHeigth)/2, CGRectGetWidth(self.bounds), textHeigth);
}

//计算将要绘制的内容是否超过绘制区域，超过则裁剪--行裁剪（以行为单位）
- (NSMutableAttributedString *)lineCutAttributeStringWithTextRect:(CGRect)textRect andAttributeString:(NSMutableAttributedString *)attributeString
{
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, attributeString.length), NULL, CGSizeMake(CGRectGetWidth(textRect), MAXFLOAT), NULL);
    
    if (suggestSize.height > CGRectGetHeight(textRect)) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributeString);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textRect);
        CTFrameRef textFrame;
        textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributeString length]), path, NULL);
        
        //获得显示行数的高度
        CFArrayRef lines = CTFrameGetLines(textFrame);
        CFIndex count = CFArrayGetCount(lines);
        if (count == 0) {
            CFRelease(path);
            CFRelease(textFrame);
            CFRelease(framesetterRef);
            CFRelease(framesetter);
            return nil;
        }
        CTLineRef line = CFArrayGetValueAtIndex(lines, count-1);
        CFRange lastLineRange = CTLineGetStringRange(line);
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
        NSMutableAttributedString *cutAttributedString = [[attributeString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
        
        //Emoji表情占两个字符，因此需要判断
        NSString *lastString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(cutAttributedString.length - 2, 2)] string];
        BOOL isEmoji = [self stringContainsEmoji:lastString];
        cutAttributedString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(0, cutAttributedString.length - (isEmoji?2:1))] mutableCopy];
        [cutAttributedString appendAttributedString:[self getEllipsesAttributeString]];
        
        CFRelease(framesetter);
        CFRelease(path);
        CFRelease(textFrame);
        //剪切后递归判断一下
        attributeString = [self charCutAttributeStringWithTextRect:textRect andAttributeString:cutAttributedString];
    }else{
        _textRect = [self textRectWithNumberOfLines:_numberOfLines withAttributeString:[attributeString mutableCopy]];//最后对textRect微调
    }
    
    CFRelease(framesetterRef);
    return attributeString;
}

//一行中微调，从最后一个字符开始减，减到完全合适为止
- (NSMutableAttributedString *)charCutAttributeStringWithTextRect:(CGRect)textRect andAttributeString:(NSMutableAttributedString *)attributeString
{
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, attributeString.length), NULL, CGSizeMake(CGRectGetWidth(textRect), MAXFLOAT), NULL);
    
    if (suggestSize.height > CGRectGetHeight(textRect)) {
        NSMutableAttributedString *cutAttributedString = [[attributeString attributedSubstringFromRange:NSMakeRange(0, attributeString.length - 1)] mutableCopy];//传到这里的attributeString一定是以...结尾的，先截掉再判断
        
        //Emoji表情占两个字符，因此需要判断
        NSString *lastString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(cutAttributedString.length - 2, 2)] string];
        BOOL isEmoji = [self stringContainsEmoji:lastString];
        cutAttributedString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(0, cutAttributedString.length - (isEmoji?2:1))] mutableCopy];
        [cutAttributedString appendAttributedString:[self getEllipsesAttributeString]];
        
        //剪切后递归判断一下
        attributeString = [self charCutAttributeStringWithTextRect:textRect andAttributeString:cutAttributedString];
    }else{
        _textRect = [self textRectWithNumberOfLines:_numberOfLines withAttributeString:[attributeString mutableCopy]];//最后对textRect微调
        
    }
    CFRelease(framesetterRef);
    return attributeString;
}

- (NSRange)ctRunRangeAtPoint:(CGPoint)point{
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_displayAttributeString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    //    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributedText length]), path, NULL);
    
    CTFrameRef textFrame;
    textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_displayAttributeString length]), path, NULL);
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        CFRelease(framesetter);
        CFRelease(textFrame);
        CFRelease(path);
        return QLRangeNotFound;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
    
    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    NSRange runRange = QLRangeNotFound;
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        // 获得每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if (point.y < CGRectGetMinY(rect)) {
            break;
        }
        
        //        CALayer *rectLayer = [[CALayer alloc] init];
        //        rectLayer.frame = rect;
        //        rectLayer.backgroundColor = [self randomColor].CGColor;
        //        rectLayer.opacity = 0.5;
        //        [self.layer addSublayer:rectLayer];
        
        CALayer *lineLayer = [[CALayer alloc] init];
        CGRect lineLayerFrame = CGRectApplyAffineTransform(CGRectMake((CGRectGetWidth(self.bounds) - CGRectGetWidth(_textRect))/2, linePoint.y - CGRectGetMinY(_textRect), CGRectGetWidth(_textRect), 1), transform);
        lineLayer.frame = lineLayerFrame;
        lineLayer.backgroundColor = [UIColor redColor].CGColor;
        //        lineLayer.opacity = 0.5;
        [self.layer addSublayer:lineLayer];
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            // 遍历每一个CTRun
            CGFloat runAscent,runDescent,lineSpace;
            //            CGPoint lineOrigin = lineOrigins[i]; // 获取该行的初始坐标
            CTRunRef run = CFArrayGetValueAtIndex(runs, j); // 获取当前的CTRun
            //            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, &lineSpace);
            
            // 这一段可参考Nimbus的NIAttributedLabel
            runRect = CGRectMake(linePoint.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), linePoint.y - runDescent - CGRectGetMinY(_textRect), runRect.size.width, runAscent + runDescent + lineSpace);
            runRect = CGRectApplyAffineTransform(runRect, transform);
            
//            CALayer *ctRunLayer = [[CALayer alloc] init];
//            ctRunLayer.frame = runRect;
//            ctRunLayer.backgroundColor = [self randomColor].CGColor;
//            ctRunLayer.opacity = 0.5;
//            [self.layer addSublayer:ctRunLayer];
            
            CFRange ctRunRange = CTRunGetStringRange(run);
            //            NSLog(@"ctRunRange:%@",NSStringFromRange(NSMakeRange(ctRunRange.location, ctRunRange.length)));
            
            if (CGRectContainsPoint(runRect, point)) {
                // 获得当前点击坐标对应的点击范围
                runRange = NSMakeRange(ctRunRange.location, ctRunRange.length);
                break;
            }
        }
    }
    CFRelease(framesetter);
    CFRelease(textFrame);
    CFRelease(path);
    return runRange;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    NSRange touchBeginRange = [self ctRunRangeAtPoint:[touch locationInView:self]];
    [self selectAttributeItem:touchBeginRange];
    //    NSLog(@"touchBeginRange:%@",NSStringFromRange(touchBeginRange));
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSRange touchEndRange = [self ctRunRangeAtPoint:[touch locationInView:self]];
    [self selectAttributeItem:touchEndRange];
    self.selectAttributeItemRange = NSMakeRange(0, 0);
//    [self setNeedsDisplay];
    self.selectAttributeString = nil;
    //    NSLog(@"touchEndRange:%@",NSStringFromRange(touchEndRange));
    [super touchesBegan:touches withEvent:event];
    
}

- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

- (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

- (void)selectAttributeItem:(NSRange)range
{
    //    NSLog(@"--------index:%ld",index);
    if (NSEqualRanges(range, QLRangeNotFound)) {
        NSLog(@"RangeNotFound");
        return;
    }
    
    //compute the positions of space characters next to the charIndex
    for (QLLabelAttributeItem *attributedItem in self.attributeItemArray) {
        if (QLRangeContain(attributedItem.attributeRange, range)) {
            
            if (!attributedItem.text) {
                attributedItem.text = [self.text substringWithRange:attributedItem.attributeRange];
            }
            //            NSLog(@"++++++++++++%@",attributedItem.text);
//            if (attributedItem.highLigthColor) {
//                NSMutableAttributedString* attributedString = [_displayAttributeString mutableCopy];
//                [attributedString addAttribute:NSForegroundColorAttributeName value:attributedItem.highLigthColor range:attributedItem.attributeRange];
//                self.selectAttributeString = attributedString;
//                [self setNeedsDisplay];
//            }
            
            if (NSEqualRanges(self.selectAttributeItemRange, attributedItem.attributeRange)) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(QLLabel:didClickQLLabelAttributeString:)]) {
                    [self.delegate QLLabel:self didClickQLLabelAttributeString:attributedItem];
                }
//                                NSLog(@"点击了%@",attributedItem.text);
            }
            self.selectAttributeItemRange = attributedItem.attributeRange;
        }
    }
}

- (CTTextAlignment)getValueWithTextAlignment:(NSTextAlignment)alignment
{
    
    CTTextAlignment textAlignment = kCTTextAlignmentLeft;
    switch (alignment) {
        case NSTextAlignmentLeft:
            textAlignment = kCTTextAlignmentLeft;
            break;
        case NSTextAlignmentCenter:
            textAlignment = kCTTextAlignmentCenter;
            break;
        case NSTextAlignmentRight:
            textAlignment = kCTTextAlignmentRight;
            break;
        case NSTextAlignmentJustified:
            textAlignment = kCTTextAlignmentJustified;
            break;
        case NSTextAlignmentNatural:
            textAlignment = kCTTextAlignmentNatural;
            break;
        default:
            break;
    }
    return textAlignment;
}

- (UIColor *)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.3];
}

-(void)dealloc
{
    NSLog(@"QLLabel-delloc:%@",self);
}
@end
