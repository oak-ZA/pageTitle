//
//  ZATitleView.h
//  PageController
//
//  Created by 张奥 on 2019/9/24.
//  Copyright © 2019 张奥. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZATitleViewDelegate<NSObject>
@required
-(void)ZA_clickItemIndex:(NSInteger)index;
@end

@interface ZATitleView : UIView
@property (nonatomic,weak) id<ZATitleViewDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles titleFont:(UIFont *)titleFont normalColor:(UIColor *)normalColor selectColor:(UIColor *)selectColor;

-(void)ZAScrollViewDidScroll:(UIScrollView *)scrollView;
-(void)ZAScrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@end
