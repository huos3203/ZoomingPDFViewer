//
//  MyOutLineViewController.h
//  ZoomingPDFViewer
//
//  Created by huoshuguang on 14-10-18.
//  Copyright (c) 2014年 Apple DTS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FastPdfKit/FastPdfKit.h>

@interface MyOutLineViewController :OutlineViewController

-(IBAction)actionBack:(id)sender;

@property (nonatomic, retain) NSArray *outlineEntries;
@property (nonatomic, retain) NSArray *openOutlineEntries;
@property (nonatomic, retain) IBOutlet UITableView *outlineTableView;
@property (assign) NSObject<OutlineViewControllerDelegate> *delegate;

@end
