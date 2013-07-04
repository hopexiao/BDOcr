/*==============================================================================
 Copyright (c) 2012-2013 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "AboutViewController.h"

@implementation AboutViewController

#pragma mark - Private

- (void)loadWebView{
    //  Load html from a local file
    NSString *aboutFilePath = [[NSBundle mainBundle] pathForResource:@"about"
                                                              ofType:@"html"];
    
    NSString* htmlString = [NSString stringWithContentsOfFile:aboutFilePath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    
    NSString *aPath = [[NSBundle mainBundle] bundlePath];
    NSURL *anURL = [NSURL fileURLWithPath:aPath];
    [webView loadHTMLString:htmlString baseURL:anURL];
}

#pragma mark - Public

- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadWebView];
}

- (void)viewDidUnload{
    [webView release];
    webView = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [webView release];
    [super dealloc];
}

- (IBAction)startButtonTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    //  Opens links within this UIWebView on a safari web browser
    
    BOOL retVal = NO;
    
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
    }else{
        retVal = YES;
    }
    
    return retVal;
}
@end
