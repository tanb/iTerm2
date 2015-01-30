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
@property (nonatomic) NSButton *backButton;
@property (nonatomic) NSButton *forwardButton;
@property (nonatomic) NSButton *reloadButton;
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
    self.addressField = [[[NSTextField alloc] initWithFrame:rectZero] autorelease];
    [self.addressField.cell setUsesSingleLineMode:YES];
    [self.addressField.cell setLineBreakMode:NSLineBreakByTruncatingTail];
    self.addressField.delegate = self;
    [self addSubview:self.addressField];

    self.backButton = [[[NSButton alloc] initWithFrame:rectZero] autorelease];
    self.backButton.title = @"<";
    self.backButton.target = self;
    self.backButton.enabled = NO;
    self.backButton.action = @selector(didClickBackButton);
    [self addSubview:self.backButton];
    
    self.forwardButton = [[[NSButton alloc] initWithFrame:rectZero] autorelease];
    self.forwardButton.title = @">";
    self.forwardButton.target = self;
    self.forwardButton.enabled = NO;
    self.forwardButton.action = @selector(didClickForwardButton);
    [self addSubview:self.forwardButton];
    
    self.reloadButton = [[[NSButton alloc] initWithFrame:rectZero] autorelease];
    self.reloadButton.title = @"⟳";
    self.reloadButton.target = self;
    self.reloadButton.action = @selector(didClickReloadButton);
    [self addSubview:self.reloadButton];

    self.webView = [[[WebView alloc] initWithFrame:rectZero] autorelease];
//    NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B410 Safari/600.1.4";
//    [self.webView setCustomUserAgent:userAgent];
    self.webView.frameLoadDelegate = self;
    [self addSubview:self.webView];
    
    NSURL *initialURL = [NSURL URLWithString:@"https://www.google.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:initialURL];
    [self.webView.mainFrame loadRequest:request];
    
    return self;
}

- (void)didClickBackButton
{
    [self.webView goBack:nil];
}

- (void)didClickForwardButton
{
    [self.webView goForward:nil];
}

- (void)didClickReloadButton
{
    [self.webView reload:nil];
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    self.addressField.stringValue = self.webView.mainFrame.dataSource.request.URL.absoluteString;
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
}

- (void)dealloc
{

    [super dealloc];
}

- (void)relayout
{
    NSRect frame = self.frame;
    CGFloat addressBarHeight = 20;
    CGFloat buttonWidth = 20;
    
    self.addressField.frame = NSRectFromCGRect(CGRectMake(buttonWidth * 3, frame.size.height - addressBarHeight,
                                                     frame.size.width - buttonWidth * 3, addressBarHeight));
    self.backButton.frame = NSRectFromCGRect(CGRectMake(0, frame.size.height - addressBarHeight,
                                                        buttonWidth, addressBarHeight));
    self.forwardButton.frame = NSRectFromCGRect(CGRectMake(buttonWidth, frame.size.height - addressBarHeight,
                                                        buttonWidth, addressBarHeight));
    self.reloadButton.frame = NSRectFromCGRect(CGRectMake(buttonWidth * 2, frame.size.height - addressBarHeight,
                                                           buttonWidth, addressBarHeight));
    self.webView.frame = NSRectFromCGRect(CGRectMake(0, 0,
                                                     frame.size.width,
                                                     frame.size.height - addressBarHeight));
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    BOOL retval = NO;
    
    if (commandSelector == @selector(insertNewline:)) {
        retval = YES;
        NSString *searchText;
        NSString *urlFormat;
        if ([self.addressField.stringValue hasPrefix:@"http"] ||
            [self.addressField.stringValue hasPrefix:@"https"]) {
            searchText = self.addressField.stringValue;
            urlFormat = @"%@";
        } else {
            searchText = [self URLEncodeWithSearchText:self.addressField.stringValue];
            urlFormat = @"https://www.google.com/search?q=%@";
        }
        
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
