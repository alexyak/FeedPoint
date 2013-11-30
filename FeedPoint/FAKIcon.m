#import "FAKIcon.h"
#import <CoreText/CoreText.h>

@interface FAKIcon ()

@property (strong, nonatomic) NSMutableAttributedString *mutableAttributedString;

@end

@implementation FAKIcon

+ (void)registerIconFontWithURL:(NSURL *)url
{
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Font file doesn't exist");
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)url);
    CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CFErrorRef error;
    CTFontManagerRegisterGraphicsFont(newFont, &error);
    CGFontRelease(newFont);
}

+ (NSDictionary *)allIcons
{
    @throw @"You need to implement this method in subclass.";
}



+ (UIFont *)iconFontWithSize:(CGFloat)size
{
    @throw @"You need to implement this method in subclass.";
}

+ (instancetype)iconWithCode:(NSString *)code size:(CGFloat)size
{
    FAKIcon *icon = [[self alloc] init];
    icon.mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:code attributes:@{NSFontAttributeName: [self iconFontWithSize:size]}];
    return icon;
}

- (NSAttributedString *)attributedString
{ 
    return [self.mutableAttributedString copy];
}

- (NSString *)characterCode
{
    return [self.mutableAttributedString string];
}

- (NSString *)iconName
{
    return [[self class] allIcons][[self characterCode]];
}

- (CGFloat)iconFontSize
{
    return [self iconFont].pointSize;
}

- (void)setIconFontSize:(CGFloat)iconSize
{
    [self addAttribute:NSFontAttributeName value:[[self iconFont] fontWithSize:iconSize]];
}

#pragma mark - Setting and Getting Attributes

- (void)setAttributes:(NSDictionary *)attrs;
{
    if (!attrs[NSFontAttributeName]) {
        NSMutableDictionary *mutableAttrs = [attrs mutableCopy];
        mutableAttrs[NSFontAttributeName] = self.iconFont;
        attrs = [mutableAttrs copy];
    }
    [self.mutableAttributedString setAttributes:attrs range:[self rangeForMutableAttributedText]] ;
}

- (void)addAttribute:(NSString *)name value:(id)value
{
    [self.mutableAttributedString addAttribute:name value:value range:[self rangeForMutableAttributedText]];
}

- (void)addAttributes:(NSDictionary *)attrs
{
    [self.mutableAttributedString addAttributes:attrs range:[self rangeForMutableAttributedText]];
}

- (void)removeAttribute:(NSString *)name
{
    [self.mutableAttributedString removeAttribute:name range:[self rangeForMutableAttributedText]];
}

- (NSDictionary *)attributes
{
    return [self.mutableAttributedString attributesAtIndex:0 effectiveRange:NULL];
}

- (id)attribute:(NSString *)attrName
{
    return [self.mutableAttributedString attribute:attrName atIndex:0 effectiveRange:NULL];
}

- (NSRange)rangeForMutableAttributedText
{
    return NSMakeRange(0, [self.mutableAttributedString length]);
}

- (UIFont *)iconFont
{
    return [self attribute:NSFontAttributeName];
}

#pragma mark - Image Drawing


- (UILabel*)labelWithIcon:(CGFloat)size
                    color:(UIColor*)color
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [self  iconFont];
    label.text = [self characterCode];
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    // NOTE: ionicons will be silent through VoiceOver, but the Label is still selectable through VoiceOver. This can cause a usability issue because a visually impaired user might navigate to the label but get no audible feedback that the navigation happened. So hide the label for VoiceOver by default - if your label should be descriptive, un-hide it explicitly after creating it, and then set its accessibiltyLabel.
    label.accessibilityElementsHidden = YES;
    return label;
}

- (UIImage *)imageWithSize: (CGPoint) point size: (CGSize)imageSize
{
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
	
	// ---------- begin context ----------
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = self.drawingBackgroundColor;
	if (backgroundColor) {
		[backgroundColor setFill];
		CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
	}
    
    [self.mutableAttributedString drawInRect:[self drawingRectWithImageSize: point size:imageSize]];
    //[self.mutableAttributedString drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
	UIImage *iconImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// ---------- end context ----------
	UIGraphicsEndImageContext();
	
	return iconImage;
}


- (UIImage *)imageWithSize:(CGSize)imageSize
{
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
	
	// ---------- begin context ----------
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor = self.drawingBackgroundColor;
	if (backgroundColor) {
		[backgroundColor setFill];
		CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
	}
    
    [self.mutableAttributedString drawInRect:[self drawingRectWithImageSize:imageSize]];
    //[self.mutableAttributedString drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
	UIImage *iconImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// ---------- end context ----------
	UIGraphicsEndImageContext();
	
	return iconImage;
}

// Calculate the correct drawing position
- (CGRect)drawingRectWithImageSize:(CGSize)imageSize
{
    CGSize iconSize = [self.mutableAttributedString size];
    CGFloat xOffset = (imageSize.width - iconSize.width) / 2.0;
    xOffset += self.drawingPositionAdjustment.horizontal;
    CGFloat yOffset = (imageSize.height - iconSize.height) / 2.0;
    yOffset += self.drawingPositionAdjustment.vertical;
    return CGRectMake(xOffset, -7, iconSize.width, iconSize.height);
}

// Calculate the correct drawing position
- (CGRect)drawingRectWithImageSize: (CGPoint) point size:(CGSize)imageSize
{
    CGSize iconSize = [self.mutableAttributedString size];
    return CGRectMake(point.x, point.y, iconSize.width, iconSize.height);
}

@end
