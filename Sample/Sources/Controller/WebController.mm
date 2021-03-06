
#import "UIUtil.h"
#import "WebController.h"

@implementation WebController

#pragma mark Generic methods

// Contructor
- (id)initWithURL:(NSURL *)URL
{
	self = [super init];
	_URL = [URL retain];
	return self;
}

// Contructor
- (id)initWithUrl:(NSString *)url
{
	return [self initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

// Destructor
- (void)dealloc
{
	if (_loading) UIUtil::ShowNetworkIndicator(NO);
	[_rightButton release];
	[_URL release];
	[super dealloc];
}

//
- (UIWebView *)webView
{
	return (UIWebView *)self.view;
}

//
- (NSString *)url
{
	return self.URL.absoluteString;
}

//
- (void)setUrl:(NSString *)url
{
	self.URL = [NSURL URLWithString:url];
}

//
- (void)setURL:(NSURL *)URL
{
	if (URL != _URL)
	{
		[_URL release];
		_URL = [URL retain];
	}
	if (URL) [self.webView loadRequest:[NSURLRequest requestWithURL:_URL]];
}

//
- (NSString *)HTML
{
	return [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
}

//
- (void)setHTML:(NSString *)HTML
{
	[self.webView loadHTMLString:HTML baseURL:nil];
}

//
- (void)loadHTML:(NSString *)HTML baseURL:(NSURL *)baseURL
{
	[self.webView loadHTMLString:HTML baseURL:baseURL];
}


#pragma mark View methods

//
- (void)loadView
{
	UIWebView *webView = [[UIWebView alloc] initWithFrame:UIUtil::AppFrame()];
	//webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; 
	webView.scalesPageToFit = YES;
	webView.delegate = self;
	self.view = webView;
	[webView release];
}

// Do additional setup after loading the view.
- (void)viewDidLoad
{	
	[super viewDidLoad];

	self.URL = _URL;
}

// Override to allow rotation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark -
#pragma mark Web view delegate

//
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
	_Log(@"shouldStartLoadWithRequest %d: <url:%@>", navigationType, request.URL);
	if ([request.URL.scheme isEqualToString:@"close"])
	{
		if (self.navigationController && ([self.navigationController.viewControllers objectAtIndex:0] != self))
		{
			[self.navigationController popViewControllerAnimated:YES];
		}
		else
		{
			[self dismissModalViewControllerAnimated:YES];
		}
		return NO;
	}
	return YES;
}

//
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	if (_loading++ == 0) UIUtil::ShowNetworkIndicator(YES);
	self.title = NSLocalizedString(@"Loading...", @"加载中⋯");
	
	[_rightButton release];
	_rightButton = [self.navigationItem.rightBarButtonItem retain];

	UIActivityIndicatorView* indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithCustomView:indicator] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	[indicator startAnimating];
}

//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if (_loading != 0) _loading--;
	if (_loading == 0) UIUtil::ShowNetworkIndicator(NO);
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	[self.navigationItem setRightBarButtonItem:_rightButton animated:YES];
	
	[_rightButton release];
	_rightButton = nil;
}

//
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self webViewDidFinishLoad:webView];
	if (error.code != -999)
	{
#ifdef _WebViewInlineError
		NSString *string = [NSString stringWithFormat:
							@"<head>"
							@"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\"/>"
							@"<title>%@</title>"
							@"<head>"
							@"<body>%@</body>", 
							NSLocalizedString(@"Error", @"错误"),
							error.localizedDescription];
		
		[((UIWebView *)self.view) loadHTMLString:string baseURL:nil];
#else
		[UIAlertView alertWithTitle:NSLocalizedString(@"Error", @"错误") message:error.localizedDescription];
#endif
	}
}


@end


@implementation WebBrowser


#pragma mark Generic methods

// Destructor
//- (void)dealloc
//{
//	[super dealloc];
//}


#pragma mark View methods

// Do additional setup after loading the view.
- (void)viewDidLoad
{
	[super viewDidLoad];

	// Create toolbar
	const static struct {NSString* title; SEL action;} c_buttons[] =
	{
		{(NSString *)UIBarButtonSystemItemRefresh, @selector(reload)},
		{@"BackwardIcon.png", @selector(goBack)},
		{@"ForwardIcon.png", @selector(goForward)},
		{(NSString *)UIBarButtonSystemItemAction, @selector(actionButtonClicked:)},
	};
	
	NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:3 * sizeof(c_buttons)/sizeof(c_buttons[0])];
	for (NSUInteger i = 0; i < sizeof(c_buttons) / sizeof(c_buttons[0]); ++i)
	{
		UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[buttons addObject:space];
		[space release];
		
		id target = ((NSUInteger)c_buttons[i].title == UIBarButtonSystemItemAction) ? (id)self : (id)self.webView;
		UIBarButtonItem *button;
		if ((NSUInteger)c_buttons[i].title < 256) 
		{
			button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItem)(NSUInteger)c_buttons[i].title  target:target action:c_buttons[i].action];
		}
		else
		{
			button = [[UIBarButtonItem alloc] initWithImage:UIUtil::ImageNamed(c_buttons[i].title) style:UIBarButtonItemStylePlain target:target action:c_buttons[i].action];
		}
		[buttons addObject:button];
		[button release];

		UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		[buttons addObject:space2];
		[space2 release];
	}	
	
	self.toolbarItems = buttons;
}

// Called when the view is about to made visible.
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_toolBarHidden = self.navigationController.toolbarHidden;
	[self.navigationController setToolbarHidden:NO animated:YES];
}

// Called after the view was dismissed, covered or otherwise hidden.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.navigationController setToolbarHidden:_toolBarHidden animated:YES];
}


#pragma mark -
#pragma mark Web view delegate

//
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[super webViewDidStartLoad:webView];
	
	UIBarButtonItem *stopButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.webView action:@selector(stopLoading)] autorelease];

	NSMutableArray *buttons = [NSMutableArray arrayWithArray:self.toolbarItems];
	[buttons replaceObjectAtIndex:(0 * 3 + 1) withObject:stopButton];
	((UIBarButtonItem *)[buttons objectAtIndex:1 * 3 + 1]).enabled = NO;
	((UIBarButtonItem *)[buttons objectAtIndex:2 * 3 + 1]).enabled = NO;
	[self setToolbarItems:buttons animated:YES];
}

//
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[super webViewDidFinishLoad:webView];
	
	UIBarButtonItem *refreshButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)] autorelease];
	NSMutableArray *buttons = [NSMutableArray arrayWithArray:self.toolbarItems];
	[buttons replaceObjectAtIndex:(0 * 3 + 1) withObject:refreshButton];
	((UIBarButtonItem *)[buttons objectAtIndex:1 * 3 + 1]).enabled = self.webView.canGoBack;
	((UIBarButtonItem *)[buttons objectAtIndex:2 * 3 + 1]).enabled = self.webView.canGoForward;
	[self setToolbarItems:buttons animated:YES];
}


#pragma mark Event methods

//
- (void)actionButtonClicked:(UIBarButtonItem *)sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Share", @"分享")
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
											   destructiveButtonTitle:nil
													otherButtonTitles:NSLocalizedString(@"Open with Safari", @"在 Safari 中打开")/*, NSLocalizedString(@"Send via Email", @"发送邮件链接")*/, nil];
	[actionSheet showFromBarButtonItem:sender animated:YES];
	[actionSheet release];
}


#pragma mark Action sheet delegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex)
	{
		case 0:
		{
			NSString *URL = [((UIWebView *)self.view) stringByEvaluatingJavaScriptFromString:@"window.location.href"];
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
			break;
		}
			
		case 1:
		{
			
		}
	}
}

@end
