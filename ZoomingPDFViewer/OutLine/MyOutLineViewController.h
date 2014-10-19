//
//  MyOutLineViewController.h
//  ZoomingPDFViewer
//
//  Created by huoshuguang on 14-10-18.
//  Copyright (c) 2014年 Apple DTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyOutlineViewControllerDelegate.h"

@interface MyOutLineViewController :UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
	NSMutableArray *_outlineEntries;
	NSMutableArray *_openOutlineEntries;
	
	NSObject<MyOutlineViewControllerDelegate> *_delegate;
	
	IBOutlet UITableView *_outlineTableView;
}

-(IBAction)actionBack:(id)sender;

@property (nonatomic, retain) NSMutableArray *outlineEntries;
@property (nonatomic, retain) NSMutableArray *openOutlineEntries;
@property (nonatomic, retain) IBOutlet UITableView *outlineTableView;
@property (weak) NSObject<MyOutlineViewControllerDelegate> *delegate;

@end
