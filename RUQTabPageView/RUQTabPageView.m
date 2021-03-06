//
//  RUQTabPageView.m
//  RUQTabPageView
//
//  Created by Ruqi Li.
//  Copyright (c) 2015 CMCM. All rights reserved.
//

#import "RUQTabPageView.h"

static CGFloat kWidthOfButtonMargin = 16.0f;
static const CGFloat kFontSizeOfTabButton = 15.0f;
static const NSUInteger kTagOfRightSideButton = 999;
static const CGFloat RUQTabPageViewShadowHeight = 1.5;

#define RGB(A, B, C)    [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha:1.0]
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define TAG_OFFSET 1987

@implementation UIImage (JN)
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

@implementation RUQTabPageView

#pragma mark - 初始化参数

- (void)initValues
{
    //创建顶部可滑动的tab
    _topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kHeightOfTopScrollView)];
    _topScrollView.delegate = self;
    _topScrollView.backgroundColor = [UIColor clearColor];
    _topScrollView.pagingEnabled = NO;
    _topScrollView.scrollsToTop = NO;
    _topScrollView.showsHorizontalScrollIndicator = NO;
    _topScrollView.showsVerticalScrollIndicator = NO;
    _topScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_topScrollView];
    _selectedIndex = 0;
    
    // 分割线
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightOfTopScrollView-0.5, kScreenWidth, 0.5)];
    lineView.image = [UIImage imageWithColor:[UIColor colorWithRed:193.0/255 green:193.0/255 blue:193.0/255 alpha:1.0]];
    [self addSubview:lineView];
    
    //创建主滚动视图
    _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kHeightOfTopScrollView, self.bounds.size.width, self.bounds.size.height - kHeightOfTopScrollView)];
    _rootScrollView.delegate = self;
    _rootScrollView.pagingEnabled = YES;
    _rootScrollView.userInteractionEnabled = YES;
    _rootScrollView.bounces = NO;
    _rootScrollView.scrollsToTop = NO;
    _rootScrollView.showsHorizontalScrollIndicator = NO;
    _rootScrollView.showsVerticalScrollIndicator = NO;
    _rootScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    _userContentOffsetX = 0;
    [_rootScrollView.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
    [self addSubview:_rootScrollView];
    
    _viewArray = [[NSMutableArray alloc] init];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initValues];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initValues];
    }
    return self;
}

#pragma mark getter/setter

- (void)setRigthSideButton:(UIButton *)rigthSideButton
{
    UIButton *button = (UIButton *)[self viewWithTag:kTagOfRightSideButton];
    [button removeFromSuperview];
    rigthSideButton.tag = kTagOfRightSideButton;
    _rigthSideButton = rigthSideButton;
    [self addSubview:_rigthSideButton];
    
}

#pragma mark - 创建控件

//当横竖屏切换时可通过此方法调整布局
- (void)layoutSubviews
{
    //如果有设置右侧视图，缩小顶部滚动视图的宽度以适应按钮
    if (self.rigthSideButton.bounds.size.width > 0) {
        _rigthSideButton.frame = CGRectMake(self.bounds.size.width - self.rigthSideButton.bounds.size.width, 0,
                                            _rigthSideButton.bounds.size.width, _topScrollView.bounds.size.height);
        
        _topScrollView.frame = CGRectMake(0, 0,
                                          self.bounds.size.width - self.rigthSideButton.bounds.size.width, kHeightOfTopScrollView);
    }
    
    //更新主视图的总宽度
    _rootScrollView.contentSize = CGSizeMake(self.bounds.size.width * [_viewArray count], 0);
    
    //更新主视图各个子视图的宽度
    for (int i = 0; i < [_viewArray count]; i++) {
        UIViewController *listVC = _viewArray[i];
        listVC.view.frame = CGRectMake(0+_rootScrollView.bounds.size.width*i, 0,
                                       _rootScrollView.bounds.size.width, _rootScrollView.bounds.size.height);
    }
    
    //滚动到选中的视图
    [_rootScrollView setContentOffset:CGPointMake(_selectedIndex * self.bounds.size.width, 0) animated:NO];
    
    //调整顶部滚动视图选中按钮位置
    UIButton *button = (UIButton *)[_topScrollView viewWithTag: self.selectedTag];
    [self adjustScrollViewContentX:button];
}

/*!
 * @method 创建子视图UI
 * @abstract
 * @discussion
 * @param
 * @result
 */
- (void) setDelegate:(id<RUQTabPageViewDelegate>)d
{
    NSUInteger number = [d numberOfTab:self];
    _staticTabs = (number <= 4);
    _viewArray = [NSMutableArray arrayWithCapacity:number];
    UIViewController *containerVC = [d viewController];
    for (int i=0; i<number; i++) {
        UIViewController<RUQPageViewControllerProtocol> *vc = [d slideSwitchView:self viewOfTab:i];
        [_viewArray addObject:vc];
        if ([vc respondsToSelector:@selector(setNavigation:)]) {
            [vc setNavigation: containerVC.navigationController];
        }
        [_rootScrollView addSubview:vc.view];
        vc.view.frame = _rootScrollView.bounds;
        //NSLog(@"%@ title:%@",[vc.view class], vc.title);
    }
    [self createNameButtons];
    
    //选中第一个view
    if (number > 0 && d && [d respondsToSelector:@selector(slideSwitchView:didselectTab:)]) {
        [d slideSwitchView:self didselectTab:_selectedIndex];
    }
    
    _delegate = d;
    
    //创建完子视图UI才需要调整布局
    [self setNeedsLayout];
}

/*!
 * @method 初始化顶部tab的各个按钮
 * @abstract
 * @discussion
 * @param
 * @result
 */
- (void)createNameButtons
{
    _shadowView = [[UIView alloc] init];
    _shadowView.backgroundColor = self.tabItemSelectedColor;
    [_topScrollView addSubview:_shadowView];
    if(_staticTabs){
        [self createStaticTabButtons];
        return;
    }
    
    //顶部tabbar的总长度
    CGFloat topScrollViewContentWidth = kWidthOfButtonMargin;
    //每个tab偏移量
    CGFloat xOffset = kWidthOfButtonMargin;
    self.topScrollView.scrollEnabled = YES;
    
    for (int i = 0; i < [_viewArray count]; i++) {
        UIViewController *vc = _viewArray[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

        CGSize textSize = [RUQTabPageView sizeString:vc.title WithFont:[UIFont systemFontOfSize:kFontSizeOfTabButton] constrainedToSize:CGSizeMake(_topScrollView.bounds.size.width, kHeightOfTopScrollView) lineBreakMode:NSLineBreakByWordWrapping];
        //累计每个tab文字的长度
        topScrollViewContentWidth += kWidthOfButtonMargin+textSize.width;
        
        //设置按钮尺寸
        [button setFrame:CGRectMake(xOffset,  0,
                                    textSize.width, kHeightOfTopScrollView)];

        [button setTag:i + TAG_OFFSET];
        if (i == 0) {
            _shadowView.frame = CGRectMake(xOffset, kHeightOfTopScrollView - RUQTabPageViewShadowHeight, kScreenWidth/_viewArray.count, RUQTabPageViewShadowHeight);
        }
//        NSLog(@"title:%@ xOffset:%f buttonFrame:%@",vc.title,xOffset,NSStringFromCGRect(button.frame));
        
        [button setTitle:vc.title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:kFontSizeOfTabButton];
        [button setTitleColor:self.tabItemNormalColor forState:UIControlStateNormal];
        [button setTitleColor:self.tabItemSelectedColor forState:UIControlStateSelected];
        
        
        [button setBackgroundImage:self.tabItemNormalBackgroundImage forState:UIControlStateNormal];
        [button setBackgroundImage:self.tabItemSelectedBackgroundImage forState:UIControlStateSelected];
        [button addTarget:self action:@selector(onPageSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_topScrollView addSubview:button];
        
        //计算下一个tab的x偏移量
        xOffset += textSize.width + kWidthOfButtonMargin;
    }
    
    //设置顶部滚动视图的内容总尺寸
    _topScrollView.contentSize = CGSizeMake(topScrollViewContentWidth, kHeightOfTopScrollView);
}

- (void) createStaticTabButtons {
    kWidthOfButtonMargin = 0;
    self.topScrollView.scrollEnabled = NO;
    self.topScrollView.contentSize = CGSizeMake(kScreenWidth, kHeightOfTopScrollView);
    
    CGFloat xOffset = 0;
    CGFloat tabWidth = kScreenWidth/_viewArray.count;
    for (int i = 0; i < [_viewArray count]; i++) {
        UIViewController *vc = _viewArray[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //设置按钮尺寸
        [button setFrame:CGRectMake(xOffset,  0, tabWidth, kHeightOfTopScrollView)];
        
         [button setTag:i + TAG_OFFSET];
        if (i == 0) {
            _shadowView.frame = CGRectMake(0, kHeightOfTopScrollView - RUQTabPageViewShadowHeight, tabWidth, RUQTabPageViewShadowHeight);
        }
//        NSLog(@"title:%@ xOffset:%f buttonFrame:%@",vc.title,xOffset,NSStringFromCGRect(button.frame));
        
        [button setTitle:vc.title forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:kFontSizeOfTabButton];
        [button setTitleColor:self.tabItemNormalColor forState:UIControlStateNormal];
        [button setTitleColor:self.tabItemSelectedColor forState:UIControlStateSelected];
        
        [button setBackgroundImage:self.tabItemNormalBackgroundImage forState:UIControlStateNormal];
        [button setBackgroundImage:self.tabItemSelectedBackgroundImage forState:UIControlStateSelected];
        [button addTarget:self action:@selector(onPageSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_topScrollView addSubview:button];
        
        xOffset += tabWidth;
    }
}

#pragma mark - 顶部滚动视图逻辑方法

- (void) onPageSelected: (id) sender {
    _isAnimating = (((UIButton *)sender).tag != self.selectedTag);
    [self selectNameButton:sender];
}

/*!
 * @method 选中tab时间
 * @abstract
 * @discussion
 * @param 按钮
 * @result
 */
- (void)selectNameButton:(UIButton *)sender
{
    //如果点击的tab文字显示不全，调整滚动视图x坐标使用使tab文字显示全
    [self adjustScrollViewContentX:sender];
    
    //如果更换按钮
    if (sender.tag != self.selectedTag) {
        //取之前的按钮
        UIButton *lastButton = (UIButton *)[_topScrollView viewWithTag:self.selectedTag];
        lastButton.selected = NO;
        self.selectedTag = sender.tag;
    }
    
    //按钮选中状态
    if (!sender.selected) {
        sender.selected = YES;
        
        _shadowView.frame = CGRectMake(sender.frame.origin.x, kHeightOfTopScrollView - RUQTabPageViewShadowHeight, sender.frame.size.width, RUQTabPageViewShadowHeight);

        //设置新页出现
        [_rootScrollView setContentOffset:CGPointMake((sender.tag - TAG_OFFSET)*self.bounds.size.width, 0) animated: YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(slideSwitchView:didselectTab:)]) {
            [self.delegate slideSwitchView:self didselectTab: _selectedIndex];
        }
    }
    //重复点击选中按钮
    else {
        
    }
}

/*!
 * @method 调整顶部滚动视图x位置
 * @abstract
 * @discussion
 * @param
 * @result
 */
- (void)adjustScrollViewContentX:(UIButton *)sender
{
    //如果 当前显示的最后一个tab文字超出右边界
    if (sender.frame.origin.x - _topScrollView.contentOffset.x > _topScrollView.frame.size.width - (kWidthOfButtonMargin+sender.bounds.size.width)) {
        //向左滚动视图，显示完整tab文字
        [_topScrollView setContentOffset:CGPointMake(sender.frame.origin.x - (_topScrollView.bounds.size.width- (kWidthOfButtonMargin+sender.bounds.size.width)), 0)  animated:YES];
    }
    
    //如果 （tab的文字坐标 - 当前滚动视图左边界所在整个视图的x坐标） < 按钮的隔间 ，代表tab文字已超出边界
    if (sender.frame.origin.x - _topScrollView.contentOffset.x < kWidthOfButtonMargin) {
        //向右滚动视图（tab文字的x坐标 - 按钮间隔 = 新的滚动视图左边界在整个视图的x坐标），使文字显示完整
        [_topScrollView setContentOffset:CGPointMake(sender.frame.origin.x - kWidthOfButtonMargin, 0)  animated:YES];
    }
}

#pragma mark 主视图逻辑方法

//滚动视图开始时
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _rootScrollView) {
        _userContentOffsetX = scrollView.contentOffset.x;
        
    }
    
}

//滚动视图结束
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isAnimating) {
        return;
    }
    if (scrollView == _rootScrollView) {
        //NSLog(@"[QCSlideSwitchView] contentOffset.x: %f",scrollView.contentOffset.x);
        
        int tag = (int)scrollView.contentOffset.x / self.bounds.size.width + TAG_OFFSET;
        UIButton *button = (UIButton *)[_topScrollView viewWithTag:tag];
        UIButton *toButton = (UIButton *)[_topScrollView viewWithTag:tag + 1];
        
        if (button && toButton) {
            CGFloat width = CGRectGetWidth(button.frame);
            CGFloat offset = (int) scrollView.contentOffset.x % (int) self.bounds.size.width;
            CGFloat percent = offset / self.bounds.size.width;
            CGFloat widthDelta =  CGRectGetWidth(toButton.frame) - width;
            CGFloat lineWidth = width + percent * widthDelta;
            
            //                NSLog(@"[QCSlideSwitchView] _shadowView: %f %f => %f",
            //                      percent,
            //                      CGRectGetMinX(_shadowView.frame),
            //                      button.frame.origin.x + percent * width);
            
            _shadowView.frame = CGRectMake(button.frame.origin.x + percent * (CGRectGetMinX(toButton.frame) - CGRectGetMinX(button.frame)), kHeightOfTopScrollView - RUQTabPageViewShadowHeight, lineWidth, RUQTabPageViewShadowHeight);
            
            CGFloat buttonGap = fabs((_shadowView.frame.origin.x+_shadowView.frame.size.width/2)-(button.frame.origin.x+button.frame.size.width/2));
            CGFloat toButtonGap = fabs((_shadowView.frame.origin.x+_shadowView.frame.size.width/2)-(toButton.frame.origin.x+toButton.frame.size.width/2));

            UIButton *slideSelectedBtn = (buttonGap < toButtonGap) ? button : toButton;
            slideSelectedBtn.selected = YES;
            
            //如果更换按钮
            if (slideSelectedBtn.tag != self.selectedTag) {
                //取之前的按钮
                UIButton *lastButton = (UIButton *)[_topScrollView viewWithTag:self.selectedTag];
                lastButton.selected = NO;
                self.selectedTag = slideSelectedBtn.tag;
            }
        }
    }
}

- (long) selectedTag {
    return TAG_OFFSET + _selectedIndex;
}

- (void) setSelectedTag: (long) tag {
    _selectedIndex = tag - TAG_OFFSET;
}

//滚动视图释放滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _rootScrollView) {
        //调整顶部滑条按钮状态
        int tag = (int)scrollView.contentOffset.x/self.bounds.size.width + TAG_OFFSET;
        UIButton *button = (UIButton *)[_topScrollView viewWithTag:tag];
        button.selected = NO;
        [self selectNameButton:button];
        _isAnimating = NO;
    }
}

//传递滑动事件给下一层
-(void)scrollHandlePan:(UIPanGestureRecognizer*) panParam
{
    //当滑道左边界时，传递滑动事件给代理
    if(_rootScrollView.contentOffset.x <= 0) {
        if (self.delegate
            && [self.delegate respondsToSelector:@selector(slideSwitchView:panLeftEdge:)]) {
            [self.delegate slideSwitchView:self panLeftEdge:panParam];
        }
    } else if(_rootScrollView.contentOffset.x >= _rootScrollView.contentSize.width - _rootScrollView.bounds.size.width) {
        if (self.delegate
            && [self.delegate respondsToSelector:@selector(slideSwitchView:panRightEdge:)]) {
            [self.delegate slideSwitchView:self panRightEdge:panParam];
        }
    }
    _isAnimating = NO;
}

+ (CGSize)sizeString:(NSString *)string WithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode{
    
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
        
        return [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }else{
        return [string sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
    }
}
@end

