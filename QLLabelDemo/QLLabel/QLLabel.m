//
//  QLLabel.m
//  QLLabel
//
//  Created by maiqili on 16/2/19.
//  Copyright (c) 2016年 Petr Pavlik. All rights reserved.
//

#import "QLLabel.h"

#define qlHeadLineTailOffSet 3
#define qlRangeNotFound NSMakeRange(0, 0)
#define qlRangeContain(rangeA, rangeB) (rangeA.length >= rangeB.length && ((rangeA.location <= rangeB.location) && (NSMaxRange(rangeA) >= NSMaxRange(rangeB))))?YES:NO
static NSString* const kEllipsesCharacter = @"\u2026";// 省略号

@implementation QLLabelImageItem
-(instancetype)init
{
    self = [super init];
    if (self) {
        _index = 0;
    }
    return self;
}
@end

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
@property (nonatomic, strong) NSMutableArray *imageSizeArray; //Object:NSDictionart
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
        _imageSizeArray = [NSMutableArray array];
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
    
    CFRelease(framesetterRef);
}

-(void)setText:(NSString *)text
{
    if (_text != text) {
        _text = text;
        _attributeItemArray = nil;
        if (_hasDisPlayed) {
            [self setNeedsDisplay];
        }
    }
}

-(void)setTextColor:(UIColor *)textColor
{
    if (_textColor != textColor) {
        _textColor = textColor;
        if (_hasDisPlayed) {
            [self setNeedsDisplay];
        }
    }
}

-(void)setFont:(UIFont *)font
{
    if (_font != font) {
        _font = font;
        if (_hasDisPlayed) {
            [self setNeedsDisplay];
        }
    }
}

-(void)setLineSpace:(CGFloat)lineSpace
{
    if (_lineSpace != lineSpace) {
        lineSpace = lineSpace>=1?lineSpace:1;
        lineSpace = lineSpace<=20?lineSpace:20;
        _lineSpace = lineSpace;
        if (_hasDisPlayed) {
            [self setNeedsDisplay];
        }
    }
}

-(void)setTextAlignment:(NSTextAlignment)textAlignment
{
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
        if (_hasDisPlayed) {
            [self setNeedsDisplay];
        }
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
    if (_lineBreakMode != lineBreakMode) {
        _lineBreakMode = lineBreakMode;
        if (_hasDisPlayed) {
            [self setNeedsDisplay];
        }
    }
}

-(void)setNumberOfLines:(NSInteger)numberOfLines
{
    if (_numberOfLines != numberOfLines) {
        _numberOfLines = numberOfLines;
        if (_hasDisPlayed) {
            [self setNeedsDisplay];
        }
    }
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    if (_attributedText != attributedText) {
        _attributedText = attributedText;
        if (_hasDisPlayed) {
            [self setNeedsDisplay];
        }
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
    [self setImageArrayWithAttributeText:mutableAttributedString];
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
    
    _textRect = [self textRectWithNumberOfLines:_numberOfLines withAttributeString:[_attributedText mutableCopy]];
    _displayAttributeString = [self lineCutAttributeStringWithTextRect:_textRect andAttributeString:[_attributedText mutableCopy]];
    
    if (_displayAttributeString.length == 0) {
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
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_displayAttributeString);
    CTFrameRef frame =
    CTFramesetterCreateFrame(framesetter,
                             CFRangeMake(0, [_displayAttributeString length]), path, NULL);
    
    // 步骤 6 进行绘制
    CTFrameDraw(frame, context);
    
    // 步骤10：绘制图片
    UIImage *image = [UIImage imageNamed:@"coretext-img-1.png"];
    CGContextDrawImage(context, [self calculateImagePositionInCTFrame:frame], image.CGImage);
    
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
        
        textHeigth = MIN(suggestSize.height + qlHeadLineTailOffSet, CGRectGetHeight(self.bounds));
        
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
- (void)setImageArrayWithAttributeText:(NSMutableAttributedString *)attributeString
{
    //如果已经绘制过一遍，说明已经插入过图片，无需重新插入
    if (!_hasDisPlayed) {
        for (QLLabelImageItem *image in _imageItemArray) {
            
            // 步骤9：图文混排部分
            // CTRunDelegateCallbacks：一个用于保存指针的结构体，由CTRun delegate进行回调
            CTRunDelegateCallbacks callbacks;
            memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
            callbacks.version = kCTRunDelegateVersion1;
            callbacks.getAscent = ascentCallback;
            callbacks.getDescent = descentCallback;
            callbacks.getWidth = widthCallback;
            
            // 图片信息字典
            NSDictionary *imgInfoDic = @{@"width":image.imageWidth,@"height":image.imageHeigth};
            [_imageSizeArray addObject:imgInfoDic];
            
            // 设置CTRun的代理
            CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)imgInfoDic);
            
            // 使用0xFFFC作为空白的占位符
            unichar objectReplacementChar = 0xFFFC;
            NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
            NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content];
            CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
            CFRelease(delegate);
            
            // 将创建的空白AttributedString插入进当前的attrString中，位置可以随便指定，不能越界
            [attributeString insertAttributedString:space atIndex:image.index];
            
        }
    }
}

#pragma mark - CTRun delegate 回调方法
static CGFloat ascentCallback(void *ref) {
    
    //防止crash
    BOOL isDict = [(__bridge id)ref isKindOfClass:[NSDictionary class]];
    if (isDict) {
        NSNumber *ascent = (NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"height"];
        if (ascent) {
            return [ascent floatValue];
        }
    }
    return 0;
}

static CGFloat descentCallback(void *ref) {
    
    return 0;
}

static CGFloat widthCallback(void *ref) {
    
    //防止crash
    BOOL isDict = [(__bridge id)ref isKindOfClass:[NSDictionary class]];
    if (isDict) {
        NSNumber *ascent = (NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"width"];
        if (ascent) {
            return [ascent floatValue];
        }
    }
    return 0;
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
        //截到最后一行
        CTLineRef line = CFArrayGetValueAtIndex(lines, count-1);
        CFRange lastLineRange = CTLineGetStringRange(line);
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length;
        NSMutableAttributedString *cutAttributedString = [[attributeString attributedSubstringFromRange:NSMakeRange(0, truncationAttributePosition)] mutableCopy];
        NSMutableAttributedString *lastLineAttributeString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
        [lastLineAttributeString appendAttributedString:[self getEllipsesAttributeString]];
        
        //对最后一行做处理
        lastLineAttributeString = [self cutLastLineAttributeString:lastLineAttributeString andWidth:CGRectGetWidth(_textRect)];
        
        //替换最后一行
        cutAttributedString = [[cutAttributedString attributedSubstringFromRange:NSMakeRange(0, lastLineRange.location)] mutableCopy];
        [cutAttributedString appendAttributedString:lastLineAttributeString];
        attributeString = cutAttributedString;
        
        CFRelease(path);
        CFRelease(textFrame);
        CFRelease(framesetter);
    }
    _textRect = [self textRectWithNumberOfLines:_numberOfLines withAttributeString:[attributeString mutableCopy]];//最后对textRect微调
    CFRelease(framesetterRef);
    return attributeString;
}

//单独拿出最后一行进行处理
- (NSMutableAttributedString *)cutLastLineAttributeString:(NSMutableAttributedString *)attributeString andWidth:(CGFloat)width
{
    CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CGFloat lastLineWidth = (CGFloat)CTLineGetTypographicBounds(truncationToken, nil, nil,nil);
    CFRelease(truncationToken);
    if (lastLineWidth>width) {
        NSLog(@"不够宽");
        //Emoji表情占两个字符，因此需要判断
        NSString *lastString = [[attributeString attributedSubstringFromRange:NSMakeRange(attributeString.length - 3, 2)] string];
        BOOL isEmoji = [self stringContainsEmoji:lastString];
        [attributeString deleteCharactersInRange:NSMakeRange(attributeString.length - (isEmoji?3:2), isEmoji?2:1)]; //减去省略号前一个符号；
        return [self cutLastLineAttributeString:attributeString andWidth:width];
    }else{
        NSLog(@"够宽");
        return attributeString;
    }
}

- (NSRange)ctRunRangeAtPoint:(CGPoint)point{
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_displayAttributeString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CTFrameRef textFrame;
    textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_displayAttributeString length]), path, NULL);
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        CFRelease(framesetter);
        CFRelease(textFrame);
        CFRelease(path);
        return qlRangeNotFound;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
    
    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    NSRange runRange = qlRangeNotFound;
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        // 获得每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if (point.y < CGRectGetMinY(rect)) {
            break;
        }
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            
            // 遍历每一个CTRun
            CGFloat runAscent,runDescent,lineSpace;
            CTRunRef run = CFArrayGetValueAtIndex(runs, j); // 获取当前的CTRun
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, &lineSpace);
            
            runRect = CGRectMake(linePoint.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), linePoint.y - runDescent - CGRectGetMinY(_textRect), runRect.size.width, runAscent + runDescent + lineSpace);
            runRect = CGRectApplyAffineTransform(runRect, transform);
            
            CFRange ctRunRange = CTRunGetStringRange(run);
            
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSRange touchBeginRange = [self ctRunRangeAtPoint:[touch locationInView:self]];
    [self selectAttributeItem:touchBeginRange];
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    NSRange touchEndRange = [self ctRunRangeAtPoint:[touch locationInView:self]];
    [self selectAttributeItem:touchEndRange];
    self.selectAttributeItemRange = NSMakeRange(0, 0);
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
    if (NSEqualRanges(range, qlRangeNotFound)) {
        NSLog(@"RangeNotFound");
        return;
    }
    
    //compute the positions of space characters next to the charIndex
    for (QLLabelAttributeItem *attributedItem in self.attributeItemArray) {
        if (qlRangeContain(attributedItem.attributeRange, range)) {
            
            if (!attributedItem.text) {
                attributedItem.text = [self.attributedText attributedSubstringFromRange:attributedItem.attributeRange].string;
            }
            if (NSEqualRanges(self.selectAttributeItemRange, attributedItem.attributeRange)) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(qlLabel:didClickQLLabelAttributeString:)]) {
                    [self.delegate qlLabel:self didClickQLLabelAttributeString:attributedItem];
                }
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
/**
 *  根据CTFrameRef获得绘制图片的区域
 *
 *  @param ctFrame CTFrameRef对象
 *
 *  @return 绘制图片的区域
 */
- (CGRect)calculateImagePositionInCTFrame:(CTFrameRef)ctFrame {
    
    // 获得CTLine数组
    NSArray *lines = (NSArray *)CTFrameGetLines(ctFrame);
    NSInteger lineCount = [lines count];
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    // 遍历每个CTLine
    for (NSInteger i = 0 ; i < lineCount; i++) {
        
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        
        // 遍历每个CTLine中的CTRun
        for (id runObj in runObjArray) {
            
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }
            
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(ctFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            return delegateBounds;
        }
    }
    return CGRectZero;
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
