//
//  QCSlideSwitchView.h
//  QCSliderTableView
//
//  Created by “ jn on 14-4-16.
//  Copyright (c) 2014年 Scasy. All rights reserved.
//


#import <UIKit/UIKit.h>
#define UICOLORWITHRGB(rgb) ([UIColor colorWithRed:((CGFloat)((rgb & 0xFF0000) >> 16))/255.0 \
green:((CGFloat)((rgb & 0xFF00) >> 8))/255.0 \
blue:((CGFloat)(rgb & 0xFF))/255.0 \
alpha:1.0])

@protocol RUQTabPageViewDelegate;
@interface RUQTabPageView : UIView<UIScrollViewDelegate>
{
    CGFloat _userContentOffsetX;
    BOOL _isAnimating;                              //是否正在响应点击事件做动画
    
    NSInteger _userSelectedChannelID;               //点击按钮选择名字ID
    
    UIView *_shadowView;
    
    UIColor *_tabItemNormalColor;                   //正常时tab文字颜色
    UIColor *_tabItemSelectedColor;                 //选中时tab文字颜色
    UIImage *_tabItemNormalBackgroundImage;         //正常时tab的背景
    UIImage *_tabItemSelectedBackgroundImage;       //选中时tab的背景
    NSMutableArray *_viewArray;                     //主视图的子视图数组
    
    CGFloat _startContentOffsetX;
    CGFloat _bottomLineWidth;
}

@property (nonatomic, strong) UIScrollView *rootScrollView; //主视图
@property (nonatomic, strong) UIScrollView *topScrollView; //顶部页签视图
@property (nonatomic, assign) CGFloat userContentOffsetX;
@property (nonatomic, assign) NSInteger userSelectedChannelID;
@property (nonatomic, assign) NSInteger scrollViewSelectedChannelID;
@property (nonatomic, weak) id<RUQTabPageViewDelegate> delegate;
@property (nonatomic, strong) UIColor *tabItemNormalColor;
@property (nonatomic, strong) UIColor *tabItemSelectedColor;
@property (nonatomic, strong) UIImage *tabItemNormalBackgroundImage;
@property (nonatomic, strong) UIImage *tabItemSelectedBackgroundImage;

@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, strong) UIButton *rigthSideButton;
@property (nonatomic, strong) UIImageView *buttonBottomLine;

@property (nonatomic,assign) BOOL isOnlyInOneView;//按钮是否只在一个视图中显示,可以根据屏幕尺寸平均分配坐标,默认为NO

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
- (UIViewController *)slideSwitchView:(RUQTabPageView *)view viewOfTab:(NSUInteger)number;

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

