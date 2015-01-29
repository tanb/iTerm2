//
//  ToolMiniBrowser.m
//  iTerm2
//
//  Created by tanB on 1/29/15.
//
//

#import "ToolMiniBrowser.h"
#import "ToolbeltView.h"
#import <WebKit/WebKit.h>

@interface ToolMiniBrowser () <NSTextFieldDelegate>
@property (nonatomic) WebView *webView;
@property (nonatomic) NSTextField *addressField;
@end

@implementation ToolMiniBrowser

- (NSString *)URLEncodeWithSearchText:(NSString *)searchText
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)searchText,
                                                                                 NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8));
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    NSRect rectZero = NSRectFromCGRect(CGRectZero);
    self.addressField = [[NSTextField alloc] initWithFrame:rectZero];
    self.addressField.delegate = self;
    [self addSubview:self.addressField];

    self.webView = [[WebView alloc] initWithFrame:rectZero];
//    NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B410 Safari/600.1.4";
//    [self.webView setCustomUserAgent:userAgent];
    self.webView.frameLoadDelegate = self;
    [self addSubview:self.webView];
    
    NSURL *initialURL = [NSURL URLWithString:@"https://www.google.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:initialURL];
    [self.webView.mainFrame loadRequest:request];
    
    return self;
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    self.addressField.stringValue = self.webView.mainFrame.dataSource.request.URL.host;
}

- (void)dealloc
{

    [super dealloc];
}

- (void)relayout
{
    NSRect frame = self.frame;
    CGFloat addressBarHeight = 20;
    
    self.addressField.frame = NSRectFromCGRect(CGRectMake(0, frame.size.height - addressBarHeight,
                                                     frame.size.width, addressBarHeight));
    self.webView.frame = NSRectFromCGRect(CGRectMake(0, 0,
                                                     frame.size.width,
                                                     frame.size.height - addressBarHeight));
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    BOOL retval = NO;
    
    if (commandSelector == @selector(insertNewline:)) {
        retval = YES;
        NSString *searchText = [self URLEncodeWithSearchText:self.addressField.stringValue];
        NSString *urlFormat = @"https://www.google.com/search?q=%@";
        NSString *urlString = [NSString stringWithFormat:urlFormat, searchText];
        
        NSURL *initialURL = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:initialURL];
        [self.webView.mainFrame loadRequest:request];
    }
    
    return retval;  
}

- (void)shutdown
{
}

- (CGFloat)minimumHeight
{
    return 88;
}

@end
