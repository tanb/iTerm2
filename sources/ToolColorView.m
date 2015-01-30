//
//  ToolColorView.m
//  iTerm2
//
//  Created by tanB on 1/31/15.
//
//

#import "ToolColorView.h"

@interface ToolColorView ()
@property (nonatomic) NSColorWell *colorWell;
@property (nonatomic) NSTextField *rgbLabel;
@property (nonatomic) NSTextField *rgbField;
@end

@implementation ToolColorView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    NSRect rectZero = NSRectFromCGRect(CGRectZero);
    self.colorWell = [[[NSColorWell alloc] initWithFrame:rectZero] autorelease];
    self.colorWell.target = self;
    self.colorWell.action = @selector(didSelectColorWell:);
    
    [self addSubview:self.colorWell];

    self.rgbLabel = [[[NSTextField alloc] initWithFrame:rectZero] autorelease];
    self.rgbLabel.editable = NO;
    [self.rgbLabel setBezeled:NO];
    [self.rgbLabel setDrawsBackground:NO];
    [self.rgbLabel setSelectable:NO];
    
    NSMutableParagraphStyle *mutParaStyle=[[[NSMutableParagraphStyle alloc] init] autorelease];
    [mutParaStyle setAlignment:NSRightTextAlignment];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:mutParaStyle
                                                           forKey:NSParagraphStyleAttributeName];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:@"rgb:"
                                                                  attributes:attributes];
    [self.rgbLabel setObjectValue:attrStr];
    [self addSubview:self.rgbLabel];
    
    self.rgbField= [[[NSTextField alloc] initWithFrame:rectZero] autorelease];
    [self addSubview:self.rgbField];
    
    return self;
}

- (void)didSelectColorWell:(id)colorWell
{
    NSString *colorFormat = @"(%.0f, %.0f, %.0f)";
    NSString *colorString =
    [NSString stringWithFormat:colorFormat, self.colorWell.color.redComponent * 255,
     self.colorWell.color.greenComponent * 255, self.colorWell.color.blueComponent * 255];
    self.rgbField.stringValue = colorString;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)relayout
{
    NSRect frame = self.frame;
    CGFloat rgbBarHeight = 20;
    CGFloat labelWidth = 30;
    CGFloat fieldWidth = 100;

    self.rgbLabel.frame = NSRectFromCGRect(CGRectMake(frame.size.width - fieldWidth - labelWidth,
                                                      frame.size.height - rgbBarHeight,
                                                      labelWidth, rgbBarHeight));
    self.rgbField.frame = NSRectFromCGRect(CGRectMake(frame.size.width - fieldWidth, frame.size.height - rgbBarHeight,
                                                      fieldWidth, rgbBarHeight));
    
    self.colorWell.frame = NSRectFromCGRect(CGRectMake(0, 0,
                                                     frame.size.width,
                                                     frame.size.height - rgbBarHeight));
}


- (void)shutdown
{
}

- (CGFloat)minimumHeight
{
    return 88;
}

@end
