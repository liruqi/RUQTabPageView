//
//  RUQTabPageView.h
//  RUQTabPageView
//
//  Created by Ruqi Li.
//  Copyright (c) 2015 CMCM. All rights reserved.
//


#import <UIKit/UIKit.h>
#define UICOLORWITHRGB(rgb) ([UIColor colorWithRed:((CGFloat)((rgb & 0xFF0000) >> 16))/255.0 \
green:((CGFloat)((rgb & 0xFF00) >> 8))/255.0 \
blue:((CGFloat)(rgb & 0xFF))/255.0 \
alpha:1.0])

static const CGFloat kHeightOfTopScrollView = 36.0f;

@protocol RUQTabPageViewDelegate;
@interface RUQTabPageView : UIView<UIScrollViewDelegate>
{
    CGFloat _userContentOffsetX;
    BOOL _isAnimating;                              //是否正在响应点击事件做动画
    
    UIView *_shadowView;
    
    UIColor *_tabItemNormalColor;                   //正常时tab文字颜色
    UIColor *_tabItemSelectedColor;                 //选中时tab文字颜色
    UIImage *_tabItemNormalBackgroundImage;         //正常时tab的背景
    UIImage *_tabItemSelectedBackgroundImage;       //选中时tab的背景
    NSMutableArray *_viewArray;                     //主视图的子视图数组
    
    CGFloat _startContentOffsetX;
    CGFloat _bottomLineWidth;
    BOOL _staticTabs; // static tabs do not scroll, true for tabs less than or equal to 4
}

@property (nonatomic, strong) UIScrollView *rootScrollView; //主视图
@property (nonatomic, strong) UIScrollView *topScrollView; //顶部页签视图
@property (nonatomic, assign) CGFloat userContentOffsetX;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger scrollViewSelectedChannelID;
@property (nonatomic, weak) id<RUQTabPageViewDelegate> delegate;
@property (nonatomic, strong) UIColor *tabItemNormalColor;
@property (nonatomic, strong) UIColor *tabItemSelectedColor;
@property (nonatomic, strong) UIImage *tabItemNormalBackgroundImage;
@property (nonatomic, strong) UIImage *tabItemSelectedBackgroundImage;

@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, strong) UIButton *rigthSideButton;

@end

@protocol RUQPageViewControllerProtocol <NSObject>

@required
- (void)setNavigation:(UINavigationController *)view;

@end

@protocol RUQTabPageViewDelegate <NSObject>

@required

/*!
 * @method 顶部tab个数
 * @abstract
 * @discussion
 * @param 本控件
 * @result tab个数
 */
- (NSUInteger)numberOfTab:(RUQTabPageView *)view;

/*!
 * @method 每个tab所属的viewController
 * @abstract
 * @discussion
 * @param tab索引
 * @result viewController
 */
- (UIViewController<RUQPageViewControllerProtocol> *)slideSwitchView:(RUQTabPageView *)view viewOfTab:(NSUInteger)number;

- (UIViewController*) viewController;

@optional

/*!
 * @method 滑动左边界时传递手势
 * @abstract
 * @discussion
 * @param   手势
 * @result
 */
- (void)slideSwitchView:(RUQTabPageView *)view panLeftEdge:(UIPanGestureRecognizer*) panParam;

/*!
 * @method 滑动右边界时传递手势
 * @abstract
 * @discussion
 * @param   手势
 * @result
 */
- (void)slideSwitchView:(RUQTabPageView *)view panRightEdge:(UIPanGestureRecognizer*) panParam;

/*!
 * @method 点击tab
 * @abstract
 * @discussion
 * @param tab索引
 * @result
 */
- (void)slideSwitchView:(RUQTabPageView *)view didselectTab:(NSUInteger)number;

@end

