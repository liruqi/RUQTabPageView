//
//  ViewController.m
//  RUQTabPageViewDemo
//
//  Created by RUQI LI on 31/8/15.
//  Copyright (c) 2015 RUQI LI. All rights reserved.
//

#import "ViewController.h"
#import "RUQTabPageView.h"
#import "DetailViewController.h"
@interface ViewController () <RUQTabPageViewDelegate>

@property (nonatomic, strong) RUQTabPageView *tabPageView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)loadView {
    CGRect f = [UIScreen mainScreen].bounds;
    self.view = [[UIView alloc] initWithFrame:f];
    self.view.backgroundColor = [UIColor whiteColor];
    
    f.origin.y += 20;
    f.size.height -= 20;
    RUQTabPageView *view = [[RUQTabPageView alloc] initWithFrame:f];
    // view.isOnlyInOneView=YES;
    view.topScrollView.backgroundColor = [UIColor whiteColor];
    view.backgroundColor = [UIColor lightGrayColor];
    view.tabItemNormalColor = UICOLORWITHRGB(0x692e83);
    view.tabItemSelectedColor = UICOLORWITHRGB(0xB282C6);
    
    NSArray *daysInWeek = @[@"Sunday",@"Monday",@"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
//    NSArray *daysInWeek = @[@"Sunday",@"Monday",@"Tuesday"];

    self.dataSource = [NSMutableArray arrayWithCapacity: daysInWeek.count];
    for (NSString* day in daysInWeek) {
        DetailViewController *vc = [DetailViewController new];
        vc.title = day;
        [self.dataSource addObject:vc];
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
    }
    view.delegate = self;
    [self.view addSubview:view];
    self.tabPageView = view;
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear: parent start");
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear: parent end");
}


- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear: parent start");
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear: parent end");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 滑动tab视图代理方法
- (void)slideSwitchView:(RUQTabPageView *)view panLeftEdge:(UIPanGestureRecognizer *)panParam
{
}

- (NSUInteger)numberOfTab:(RUQTabPageView *)view
{
    return self.dataSource.count;
}

- (UIViewController *)slideSwitchView:(RUQTabPageView *)view viewOfTab:(NSUInteger)number
{
    return [self.dataSource objectAtIndex:number];
}

- (void)slideSwitchView:(RUQTabPageView *)view didselectTab:(NSUInteger)number
{
    NSLog(@"didselectTab: %u", (unsigned int) number);
}

- (UIViewController*) viewController
{
    return self;
}

@end
