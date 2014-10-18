/*
     File: RootViewController.m
 Abstract: This view controller manages the display of a set of view controllers by way of implementing the UIPageViewControllerDelegate protocol.
  Version: 3.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "RootViewController.h"

#import "ModelController.h"

#import "DataViewController.h"
#import "MyOutLineViewController.h"

#define FPK_REUSABLE_VIEW_NONE 0
#define FPK_REUSABLE_VIEW_SEARCH 1
#define FPK_REUSABLE_VIEW_TEXT 2
#define FPK_REUSABLE_VIEW_OUTLINE 3
#define FPK_REUSABLE_VIEW_BOOKMARK 4


static const NSInteger FPKReusableViewNone = FPK_REUSABLE_VIEW_NONE;
static const NSInteger FPKReusableViewSearch = FPK_REUSABLE_VIEW_SEARCH;
static const NSInteger FPKReusableViewText = FPK_REUSABLE_VIEW_TEXT;
static const NSInteger FPKReusableViewOutline = FPK_REUSABLE_VIEW_OUTLINE;
static const NSInteger FPKReusableViewBookmarks = FPK_REUSABLE_VIEW_BOOKMARK;


#define FPK_SEARCH_VIEW_MODE_MINI 0
#define FPK_SEARCH_VIEW_MODE_FULL 1

static const NSInteger FPKSearchViewModeMini = FPK_SEARCH_VIEW_MODE_MINI;
static const NSInteger FPKSearchViewModeFull = FPK_SEARCH_VIEW_MODE_FULL;



@interface RootViewController ()
@property (readonly, strong, nonatomic) ModelController *modelController;
@end

@implementation RootViewController
{
    NSUInteger currentReusableView;         // This flag is used to keep track of what alternate controller is displayed to the user
    NSUInteger currentSearchViewMode;
}

@synthesize modelController = _modelController;

-(id)init
{
    
    //
    //	Here we call the superclass initWithDocumentManager passing the very same MFDocumentManager
    //	we used to initialize this class. However, since you probably want to track which document are
    //	handling to synchronize bookmarks and the like, you can easily use your own wrapper for the MFDocumentManager
    //	as long as you pass an instance of it to the superclass initializer.
	
    NSString *documentPath = [[NSBundle mainBundle]pathForResource:@"11" ofType:@"pdf"];
    NSURL *documentUrl = [NSURL fileURLWithPath:documentPath];
    MFDocumentManager *aDocManager = [[MFDocumentManager alloc]initWithFileUrl:documentUrl];
    
    
    // This delegate has been added just to manage the links between pdfs, skip it if you just need standard visualization
    
	if((self = [super initWithDocumentManager:aDocManager])) {
		[self setDocumentDelegate:self];
        [self setAutoMode:MFDocumentAutoModeOverflow];
        [self setAutomodeOnRotation:YES];
//        [self setDocumentId:@"11"];   // We use the filename as an ID. You can use whaterver you like, like
//        
////        [self setDelegate:self];
////        OverlayManager *ovManager = [[OverlayManager alloc] init];
//        [self addOverlayDataSource:nil];
//
////        [self modelController];
	}
	return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] init];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    // 设置导航栏背景
    [navBar setBackgroundImage:[UIImage imageNamed:@"default.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [backButton setTitle:@"不读了" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:0.0 / 255.0 green:86.0 / 255 blue:44 / 255 alpha:1.0] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:18.0 / 255.0 green:141.0 / 255 blue:66.0 / 255 alpha:1.0] forState:UIControlStateHighlighted];
    [backButton setImage:[UIImage imageNamed:@"back1.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back2.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(ibaOutline:) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.RightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    DataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    self.pageViewController.dataSource = self.modelController;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
//    }
    
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ModelController *)modelController
{
     // Return the model controller object, creating it if necessary.
     // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[ModelController alloc] init];
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods

/*
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
}
 */

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        //竖屏时，或iPhone上，return UIPageViewControllerSpineLocationMin；
        //pageViewController数组中，仅有一个页面显示，所以 doubleSided 赋值NO
        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
        NSArray *viewControllers = @[currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }

    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    //横屏时，return UIPageViewControllerSpineLocationMid；
    //pageViewController数组中有两个VC页面
    //如果显示的是偶数页，那么就同时显示当前页面和下一个相邻的页面
    //如果显示的是奇数页，就同时显示前一个相邻的页面，和当前页面。
    DataViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = nil;

    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];


    return UIPageViewControllerSpineLocationMid;
}


- (IBAction)ibaOutline:(UIButton *)sender {
    
    MyOutLineViewController *outlineVC = nil;
    
	if (currentReusableView != FPK_REUSABLE_VIEW_OUTLINE) {
		
        currentReusableView = FPK_REUSABLE_VIEW_OUTLINE;
		
        outlineVC = [[MyOutLineViewController alloc]initWithNibName:@"OutlineView" bundle:MF_BUNDLED_BUNDLE(@"FPKReaderBundle")];
        [outlineVC setDelegate:self];
		
		// We set the inital entries, that is the top level ones as the initial one. You can save them by storing
		// this array and the openentries array somewhere and set them again before present the view to the user again.
		
//		[outlineVC setOutlineEntries:[[self document] outline]];
        
        CGSize popoverContentSize = CGSizeMake(372, 530);
        
        UIView * sourceView = self.view;
        CGRect sourceRect = [self.view convertRect:sender.bounds fromView:sender];
        
        [self presentViewController:outlineVC fromRect:sourceRect sourceView:sourceView contentSize:popoverContentSize];
        
        //		[outlineVC release];
        
	} else {
        
        [self dismissAlternateViewController];
        
    }
}


-(void)dismissAlternateViewController {
    
    // This is just an utility method that will call the appropriate dismissal procedure depending
    // on which alternate controller is visible to the user.
    
    switch(currentReusableView) {
            
        case FPKReusableViewNone:
            break;
            
        case FPKReusableViewText:
            
            if(self.presentedViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
            currentReusableView = FPKReusableViewNone;
            
            break;
            
        case FPKReusableViewOutline:
        case FPKReusableViewBookmarks:
            
            // Same procedure for both outline and bookmark.
            
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                
#ifdef __IPHONE_8_0
                if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
                {
                    if(self.presentedViewController) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                }
                else
#endif
                {
                    
                    [_reusablePopover dismissPopoverAnimated:YES];
                }
                
            } else {
                
                /* On iPad iOS 8 and iPhone whe have a presented view controller */
                
                if(self.presentedViewController) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
            currentReusableView = FPKReusableViewNone;
            break;
            
        case FPKReusableViewSearch:
            
            if(currentSearchViewMode == FPKSearchViewModeFull) {
                
                //                [searchManager cancelSearch];
                //                [self dismissSearchViewController:searchViewController];
                currentReusableView = FPKReusableViewNone;
                
            } else if (currentSearchViewMode == FPKSearchViewModeMini) {
                //                [searchManager cancelSearch];
                //                [self dismissMiniSearchView];
                currentReusableView = FPKReusableViewNone;
            }
            
            // Cancel search and remove the controller.
            
            break;
        default: break;
    }
}

-(void)presentViewController:(UIViewController *)controller fromRect:(CGRect)rect sourceView:(UIView *)view contentSize:(CGSize)contentSize {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
#ifdef __IPHONE_8_0
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            
            controller.modalPresentationStyle = UIModalPresentationPopover;
            
            UIPopoverPresentationController * popoverPresentationController = controller.popoverPresentationController;
            
            popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popoverPresentationController.sourceRect = rect;
            popoverPresentationController.sourceView = view;
            popoverPresentationController.delegate = self;
            
            [self presentViewController:controller animated:YES completion:nil];
            
        } else
#endif
        {
            
            [self prepareReusablePopoverControllerWithController:controller];
            
            [_reusablePopover setPopoverContentSize:contentSize animated:YES];
            [_reusablePopover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        
    } else {
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(UIPopoverController *)prepareReusablePopoverControllerWithController:(UIViewController *)controller {
    
    UIPopoverController * popoverController = nil;
    
    if(!_reusablePopover) {
        
        popoverController = [[UIPopoverController alloc]initWithContentViewController:controller];
        popoverController.delegate = self;
        self.reusablePopover = popoverController;
        self.reusablePopover.delegate = self;
        
    } else {
        
        [_reusablePopover setContentViewController:controller animated:YES];
    }
    
    return _reusablePopover;
}

-(void)dismissOutlineViewController:(OutlineViewController *)ovc
{
    [self dismissAlternateViewController];
}

@end
