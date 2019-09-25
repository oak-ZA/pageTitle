//
//  ViewController.m
//  PageController
//
//  Created by 张奥 on 2019/9/24.
//  Copyright © 2019 张奥. All rights reserved.
//

#import "ViewController.h"
#import "ZATitleView.h"
#define SCREEN_Width [UIScreen mainScreen].bounds.size.width
#define SCREEN_Height [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UIScrollViewDelegate,ZATitleViewDelegate>{
    NSArray * _titles;
    ZATitleView * _titleView;
    UIScrollView * _scrollView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _titles = @[@"关注",@"视频",@"三星",@"四星",@"五星",@"六星",@"七星",@"八星",@"九星",@"十星"];
    _titleView = [[ZATitleView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_Width, 60) titles:_titles titleFont:[UIFont systemFontOfSize:13.f] normalColor:[UIColor whiteColor] selectColor:[UIColor blueColor]];
    _titleView.delegate = self;
    [self.view addSubview:_titleView];
    
    [self createScrollView];
    
}

-(void)createScrollView{
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(0, CGRectGetMaxY(_titleView.frame), SCREEN_Width, 150);
    _scrollView.backgroundColor = [UIColor yellowColor];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    _scrollView.contentSize = CGSizeMake(_titles.count*SCREEN_Width, 0);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_titleView ZAScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_titleView ZAScrollViewDidEndDecelerating:scrollView];
}

-(void)ZA_clickItemIndex:(NSInteger)index{
    [_scrollView setContentOffset:CGPointMake(index*SCREEN_Width, 0) animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
