//
//  ZATitleView.m
//  PageController
//
//  Created by 张奥 on 2019/9/24.
//  Copyright © 2019 张奥. All rights reserved.
//

#import "ZATitleView.h"

@interface ZATitleView()<UIScrollViewDelegate>
@property (nonatomic, copy) NSArray *titles;
//滑动底视图
@property (nonatomic, strong) UIScrollView *scrollView;
//指示条
@property (nonatomic, strong) UIView *indicateView;
//title字号
@property (nonatomic, strong) UIFont *titleFont;
//title到两边的距离
@property (nonatomic, assign) CGFloat buttonSpace;
//正常颜色
@property (nonatomic, strong) UIColor *normalColor;
//选中颜色
@property (nonatomic, strong) UIColor *selectColor;
//存放按钮的宽度
@property (nonatomic, strong) NSMutableArray *itemWidths;
//选中的按钮
@property (nonatomic, strong) UIButton *selectButton;
//指示条滚动时间
@property (nonatomic, assign) NSTimeInterval duration;
//指示器的宽度
@property (nonatomic, assign) CGFloat indicateWidth;
@end

@implementation ZATitleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(NSMutableArray *)itemWidths{
    if (!_itemWidths) {
        _itemWidths = [NSMutableArray array];
    }
   return  _itemWidths;
}

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles titleFont:(UIFont *)titleFont normalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.titles = titles;
        self.titleFont = titleFont;
        self.normalColor = normalColor;
        self.selectColor = selectColor;
        self.buttonSpace = 20.f;
        
        
        [self setItem];
    }
    return self;
}

-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollView.backgroundColor = [UIColor redColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

-(UIView *)indicateView{
    if (!_indicateView) {
        _indicateView = [[UIView alloc] init];
        _indicateView.layer.cornerRadius = 2.f;
        _indicateView.layer.masksToBounds = YES;
        _indicateView.backgroundColor = [UIColor whiteColor];
    }
    return _indicateView;
}

-(void)setItem{
    
    CGFloat item_X = 0;
    for (int i=0; i<self.titles.count; i++) {
        NSString *title = self.titles[i];
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:self.titleFont}];
        //创建item
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(item_X, 0, self.buttonSpace*2+titleSize.width, self.frame.size.height);
        button.tag = i;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:self.normalColor forState:UIControlStateNormal];
        [button setTitleColor:self.selectColor forState:UIControlStateSelected];
        [button addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        [self.itemWidths addObject:[NSNumber numberWithDouble:CGRectGetWidth(button.frame)]];
        item_X += _buttonSpace*2+titleSize.width;
        
        if (i == 0) {
            button.selected = YES;
            self.selectButton = button;
            //添加指示器
            self.indicateView.frame = CGRectMake(_buttonSpace, self.frame.size.height - 4, titleSize.width, 4);
            [self.scrollView addSubview:self.indicateView];
        }
    }
    self.scrollView.contentSize = CGSizeMake(item_X, 0);
}

-(void)clickItem:(UIButton*)button{
    if (self.selectButton == button) return;
    button.selected = YES;
    self.selectButton.selected = !self.selectButton.selected;
    self.selectButton = button;
    [self scrollIndicateView];
    [self scrollSegmentView];
    if ([self.delegate respondsToSelector:@selector(ZA_clickItemIndex:)]) {
        [self.delegate ZA_clickItemIndex:button.tag];
    }
}

//根据选中的按钮滑动指示条
-(void)scrollIndicateView{
    CGSize titleSize = [self.selectButton.currentTitle sizeWithAttributes:@{NSFontAttributeName:self.titleFont}];
    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.indicateView.frame = CGRectMake(CGRectGetMinX(self.selectButton.frame)+self.buttonSpace,self.indicateView.frame.origin.y, titleSize.width, self.indicateView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
//根据选中调整scrollView的offset
-(void)scrollSegmentView{
    CGFloat sizeWidth = self.frame.size.width;
    if (self.scrollView.contentSize.width <= sizeWidth) {
        return;
    }
    if (self.selectButton.center.x <= sizeWidth/2) {
        //点击的是在scroll中心的左边(直接偏移到0)
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }else if (CGRectGetMinX(self.selectButton.frame) >= self.scrollView.contentSize.width - sizeWidth/2 ){
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width - sizeWidth, 0) animated:YES];
        
    }else{
        [self.scrollView setContentOffset:CGPointMake(self.selectButton.center.x - sizeWidth/2, 0) animated:YES];
    }
}

-(void)ZAScrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offSetX = scrollView.contentOffset.x;
    NSInteger currentIndex = self.selectButton.tag;
    CGFloat offSet;
    
    NSInteger buttonIndex = currentIndex;
    if (offSetX >= currentIndex * self.frame.size.width) {
        //左滑
        offSet = offSetX - currentIndex * self.frame.size.width;
        buttonIndex += 1;
    }else{
        //右滑
        offSet = currentIndex * self.frame.size.width - offSetX;
        buttonIndex -= 1;
        currentIndex -= 1;
    }
    
    CGFloat originMovedX = CGRectGetMinX(self.selectButton.frame) + _buttonSpace;
    CGFloat targetMoveWidth = [self widthAtIndex:currentIndex];
    
    CGFloat targetButtonWidth = [self widthAtIndex:buttonIndex] - 2 * _buttonSpace;
    CGFloat originButtonWidth = [self widthAtIndex:self.selectButton.tag] - 2*self.buttonSpace;
    
    CGFloat moved;
    moved = offSetX - self.selectButton.tag*self.frame.size.width;
    self.indicateView.frame = CGRectMake(originMovedX + targetMoveWidth / self.frame.size.width * moved, self.indicateView.frame.origin.y, self.indicateView.frame.size.width, self.indicateView.frame.size.height);
}

-(void)ZAScrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = round(scrollView.contentOffset.x / self.frame.size.width);
    [self setSelectedItemAtIndex:index];
}

- (CGFloat)widthAtIndex:(NSInteger)index {
    if (index < 0 || index > self.titles.count - 1) {
        return .0;
    }
    return [[self.itemWidths objectAtIndex:index] doubleValue];
}
- (void)setSelectedItemAtIndex:(NSInteger)index {
    for (UIView *view in self.scrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag == index) {
            UIButton *button = (UIButton *)view;
            [self clickItem:button];
        }
    }
}
@end
