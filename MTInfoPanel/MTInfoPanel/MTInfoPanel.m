//
//  MTInfoPanel.m
//  MTInfoPanel
//
//  Created by Tretter Matthias on 14.12.11.
//  Copyright (c) 2011 @myell0w. All rights reserved.
//

#import "MTInfoPanel.h"
#import <QuartzCore/QuartzCore.h>

#define MT_RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

// Private Methods

@interface MTInfoPanel ()

@property (nonatomic, unsafe_unretained) IBOutlet UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *detailLabel;
@property (nonatomic, unsafe_unretained) IBOutlet UIImageView *thumbImage;
@property (nonatomic, unsafe_unretained) IBOutlet UIImageView *backgroundGradient;

+ (MTInfoPanel *)infoPanel;

- (void)setup;

- (void)setBackgroundGradientFrom:(UIColor *)fromColor to:(UIColor *)toColor;
- (UIColor *)changeColor:(UIColor *)sourceColor withFactor:(CGFloat)factor;

@end


@implementation MTInfoPanel

@synthesize titleLabel = titleLabel_;
@synthesize detailLabel = detailLabel_;
@synthesize thumbImage = thumbImage_;
@synthesize backgroundGradient = backgroundGradient_;
@synthesize onTouched = onTouched_;
@synthesize delegate = delegate_;
@synthesize onFinished = onFinished_;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (MTInfoPanel *)showPanelInView:(UIView *)view 
                            type:(MTInfoPanelType)type 
                           title:(NSString *)title
                        subtitle:(NSString *)subtitle {
    return [self showPanelInView:view type:type title:title subtitle:subtitle hideAfter:-1];
}

+(MTInfoPanel *)showPanelInView:(UIView *)view
                           type:(MTInfoPanelType)type
                          title:(NSString *)title 
                       subtitle:(NSString *)subtitle
                      hideAfter:(NSTimeInterval)interval {    
    return [self showPanelInView:view type:type title:title subtitle:subtitle image:nil hideAfter:interval];
}

+ (MTInfoPanel *)showPanelInView:(UIView *)view 
                            type:(MTInfoPanelType)type
                           title:(NSString *)title 
                        subtitle:(NSString *)subtitle 
                           image:(UIImage *)image {
    return [self showPanelInView:view type:type title:title subtitle:subtitle image:image hideAfter:-1.];
}

+ (MTInfoPanel *)showPanelInView:(UIView*)view 
                            type:(MTInfoPanelType)type 
                           title:(NSString *)title
                        subtitle:(NSString *)subtitle
                           image:(UIImage *)image
                       hideAfter:(NSTimeInterval)interval {
    UIColor *startColor = nil;
    UIColor *endColor = nil;
    UIFont *titleFont = [UIFont boldSystemFontOfSize:15];
    UIFont *detailFont = [UIFont systemFontOfSize:13];
    UIColor *titleColor = [UIColor whiteColor];
    UIColor *detailColor = nil;
    
    switch (type) {
        case MTInfoPanelTypeInfo: {
            startColor = MT_RGBA(91, 134, 206, 1.0);
            endColor = MT_RGBA(69, 106, 177, 1.0);
            detailColor = MT_RGBA(210, 210, 235, 1.0);
            
            if (image == nil) {
                image = [UIImage imageNamed:@"Tick"];
            }
            break;
        }
            
        case MTInfoPanelTypeNotice: {
            startColor = MT_RGBA(118, 119, 120, 1.f);
            endColor = MT_RGBA(63, 65, 67, 1.f);
            detailColor = MT_RGBA(210, 210, 235, 1.0);
            
            if (image == nil) {
                image = [UIImage imageNamed:@"Notice"];
            }
            break;
        }
            
        case MTInfoPanelTypeSuccess: {
            startColor = MT_RGBA(127, 191, 34, 1.0000);
            endColor = MT_RGBA(136, 159, 86, 1.0000);
            detailColor = MT_RGBA(59, 69, 39, 1.0000);
            
            if (image == nil) {
                image = [UIImage imageNamed:@"Tick"];
            }
            break;
        }
            
            
        case MTInfoPanelTypeWarning: {
            startColor = MT_RGBA(253, 178, 77, 1.0);
            endColor = MT_RGBA(196, 123, 20, 1.0);
            detailColor = MT_RGBA(97, 61, 24, 1.0000);
            
            if (image == nil) {
                image = [UIImage imageNamed:@"Warning"];
            }
            break;
        }
            
        case MTInfoPanelTypeError:
        default: {
            startColor = MT_RGBA(200, 36, 0, 1.0);
            endColor = MT_RGBA(150, 24, 0, 1.0);
            detailColor = MT_RGBA(255, 166, 166, 1.0);
            
            if (image == nil) {
                image = [UIImage imageNamed:@"Warning"];
            }            
            break;
        }
    }
    
    return [self showPanelInView:view
                           title:title
                        subtitle:subtitle
                           image:image
                      startColor:startColor
                        endColor:endColor
                      titleColor:titleColor
                 detailTextColor:detailColor
                       titleFont:titleFont
                  detailTextFont:detailFont
                       hideAfter:interval];
}

+ (MTInfoPanel *)showPanelInView:(UIView *)view 
                           title:(NSString *)title
                        subtitle:(NSString *)subtitle 
                           image:(UIImage *)image
                      startColor:(UIColor *)startColor
                        endColor:(UIColor *)endColor
                      titleColor:(UIColor *)titleColor
                 detailTextColor:(UIColor *)detailColor
                       titleFont:(UIFont *)titleFont
                  detailTextFont:(UIFont *)detailFont
                       hideAfter:(NSTimeInterval)interval
{
    MTInfoPanel *panel = [MTInfoPanel infoPanel];
    // panel height when no subtitle set
    CGFloat panelHeight = 50.f;
    
    // update appearance of panel
    panel.titleLabel.textColor = titleColor;
    panel.titleLabel.font = titleFont;
    panel.detailLabel.textColor = detailColor;
    panel.detailLabel.font = detailFont;
    
    // set values of views
    panel.titleLabel.text = title;
    subtitle = [subtitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (subtitle.length > 0) {
        panel.detailLabel.text = subtitle;
        [panel.detailLabel sizeToFit];
        
        panelHeight = MAX(CGRectGetMaxY(panel.thumbImage.frame), CGRectGetMaxY(panel.detailLabel.frame));
        // padding at bottom
        panelHeight += 10.f;
    } else {
        panel.detailLabel.hidden = YES;
        panel.thumbImage.frame = CGRectMake(15, 5, 35, 35);
        panel.titleLabel.frame = CGRectMake(57, 12, 240, 21);
    }
    
    if (image != nil) {
        panel.thumbImage.image = image;
    }
    
    // update frame of panel
    panel.frame = CGRectMake(0, 0, view.bounds.size.width, panelHeight);
    [panel setBackgroundGradientFrom:startColor to:endColor];
    [view addSubview:panel];
    
    if (interval > 0) {
        [panel performSelector:@selector(hidePanel) withObject:view afterDelay:interval]; 
    }
    
    return panel;
}

+ (MTInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MTInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle {
    return [self showPanelInWindow:window type:type title:title subtitle:subtitle hideAfter:-1];
}

+(MTInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MTInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval {
    return [self showPanelInWindow:window type:type title:title subtitle:subtitle image:nil hideAfter:interval];
}

+ (MTInfoPanel *)showPanelInWindow:(UIWindow*)window type:(MTInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image {
    return [self showPanelInWindow:window type:type title:title subtitle:subtitle image:image hideAfter:-1.];
}
+ (MTInfoPanel *)showPanelInWindow:(UIWindow*)window type:(MTInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image hideAfter:(NSTimeInterval)interval {
    MTInfoPanel *panel = [self showPanelInView:window type:type title:title subtitle:subtitle image:image hideAfter:interval];
    
    if (![UIApplication sharedApplication].statusBarHidden) {
        CGRect frame = panel.frame;
        frame.origin.y += [UIApplication sharedApplication].statusBarFrame.size.height;
        panel.frame = frame;
    }
    
    return panel;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView
////////////////////////////////////////////////////////////////////////

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // update width of layers to allow rotation to landscape
    for (CALayer *layer in self.backgroundGradient.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            CGRect layerFrame = layer.frame;
            layerFrame.size.width = frame.size.width;
            layer.frame = layerFrame;
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

-(void)setBackgroundGradientFrom:(UIColor *)fromColor to:(UIColor *)toColor {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.backgroundGradient.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[fromColor CGColor], (id)[toColor CGColor], nil];
    
    CGFloat lineHeight = 3.0;
    // light startline
    CAGradientLayer *startLine = [CAGradientLayer layer];
    startLine.frame = CGRectMake(0, 0, self.backgroundGradient.bounds.size.width, lineHeight);
    UIColor *lightColor = [self changeColor:fromColor withFactor:1.1];
    startLine.colors = [NSArray arrayWithObjects:(id)[fromColor CGColor], (id)[lightColor CGColor], nil];
    
    // dark endline
    CAGradientLayer *endLine = [CAGradientLayer layer];
    CGFloat endPosition = self.backgroundGradient.bounds.size.height - lineHeight;
    endLine.frame = CGRectMake(0, endPosition, self.backgroundGradient.bounds.size.width, lineHeight);
    UIColor *darkColor = [self changeColor:toColor withFactor:0.7];
    endLine.colors = [NSArray arrayWithObjects:(id)[toColor CGColor], (id)[darkColor CGColor], nil];
    
    [self.backgroundGradient.layer insertSublayer:gradient atIndex:0];
    [self.backgroundGradient.layer insertSublayer:startLine atIndex:1];
    [self.backgroundGradient.layer insertSublayer:endLine atIndex:2];
}

- (UIColor *)changeColor:(UIColor *)sourceColor withFactor:(CGFloat)factor {
    // oldComponents is the array INSIDE the original color
    // changing these changes the original, so we copy it
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([sourceColor CGColor]);
    CGFloat newComponents[4];
    int numComponents = CGColorGetNumberOfComponents([sourceColor CGColor]);
    
    switch (numComponents) {
        case 2: {
            //grayscale
            newComponents[0] = oldComponents[0]*factor;
            newComponents[1] = oldComponents[0]*factor;
            newComponents[2] = oldComponents[0]*factor;
            newComponents[3] = oldComponents[1];
            break;
        }
            
        case 4: {
            //RGBA
            newComponents[0] = oldComponents[0]*factor;
            newComponents[1] = oldComponents[1]*factor;
            newComponents[2] = oldComponents[2]*factor;
            newComponents[3] = oldComponents[3];
            break;
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    
    return retColor;
}

-(void)hidePanel {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromTop;
	[self.layer addAnimation:transition forKey:nil];
    self.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height); 
    
    [self performSelector:@selector(finish)
               withObject:nil
               afterDelay:transition.duration];
}

- (void)finish {
    [self removeFromSuperview];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [delegate_ performSelector:onFinished_];
#pragma clang diagnostic pop
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Touch Recognition
////////////////////////////////////////////////////////////////////////

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:onTouched_];
#pragma clang diagnostic pop
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

+(MTInfoPanel *)infoPanel {
    MTInfoPanel *panel =  (MTInfoPanel *)[[[UINib nibWithNibName:@"MTInfoPanel" bundle:nil] 
                                           instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromBottom;
	[panel.layer addAnimation:transition forKey:nil];
    
    return panel;
}

- (void)setup {
    self.onTouched = @selector(hidePanel);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}


@end
