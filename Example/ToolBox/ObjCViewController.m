//
//  ObjCViewController.m
//  ToolBox_Example
//
//  Created by Nikola Majcen on 17/09/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#import "ObjCViewController.h"
#import <ToolBox/ToolBox-Swift.h>

@interface ObjCViewController ()

@end

@implementation ObjCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CustomInfoToolItem *item = [[CustomInfoToolItem alloc] initWithTitle:@"" value:@""];
}

@end
