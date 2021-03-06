//
//  PRRefreshControl.m
//  PRRefreshControl
//
//  Created by Elethom Hunter on 8/28/14.
//  Copyright (c) 2014 Project Rhinestone. All rights reserved.
//

#import "PRRefreshControl.h"

typedef NS_ENUM(NSUInteger, PRRefreshControlState) {
    PRRefreshControlStateNone,
    PRRefreshControlStateNormal,
    PRRefreshControlStateReady,
    PRRefreshControlStateRefreshing
};

CGFloat const kPRRefreshControlHeight = 50.f;

NSTimeInterval const kPRRefreshControlAnimationIntervalInset = .1f;
NSTimeInterval const kPRRefreshControlAnimationIntervalArrow = .2f;

@interface PRRefreshControl ()

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIImageView *arrowImageView;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, assign) PRRefreshControlState refreshState;

- (void)addScrollViewInset;
- (void)removeScrollViewInset;

- (void)scrollViewDidScroll;
- (void)scrollViewDidEndDragging;

@end

@implementation PRRefreshControl

- (void)beginRefreshing
{
    self.refreshing = YES;
    self.refreshState = PRRefreshControlStateRefreshing;
    [self addScrollViewInset];
}

- (void)endRefreshing
{
    self.refreshing = NO;
    [self removeScrollViewInset];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kPRRefreshControlAnimationIntervalInset * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.refreshState = PRRefreshControlStateNormal;
    });
}

- (void)addScrollViewInset
{
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets contentInset = self.scrollViewContentInset;
    contentInset.top += self.height;
    CGPoint contentOffset = self.scrollView.contentOffset;
    [UIView animateWithDuration:kPRRefreshControlAnimationIntervalInset animations:^{
        weakSelf.scrollView.contentInset = contentInset;
        if ([[UIDevice currentDevice].systemVersion compare:@"8" options:NSNumericSearch] != NSOrderedAscending) {
            weakSelf.scrollView.contentOffset = contentOffset;
        }
    }];
}

- (void)removeScrollViewInset
{
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets contentInset = self.scrollViewContentInset;
    [UIView animateWithDuration:kPRRefreshControlAnimationIntervalInset animations:^{
        weakSelf.scrollView.contentInset = contentInset;
    }];
}

- (void)setRefreshState:(PRRefreshControlState)refreshState
{
    switch (refreshState) {
        case PRRefreshControlStateNone:
        {
            [UIView animateWithDuration:kPRRefreshControlAnimationIntervalArrow animations:^{
                self.arrowImageView.hidden = YES;
                self.arrowImageView.transform = CGAffineTransformIdentity;
            }];
            [self.activityIndicator stopAnimating];
            break;
        }
        case PRRefreshControlStateNormal:
        {
            [UIView animateWithDuration:kPRRefreshControlAnimationIntervalArrow animations:^{
                self.arrowImageView.hidden = NO;
                self.arrowImageView.transform = CGAffineTransformIdentity;
            }];
            [self.activityIndicator stopAnimating];
            break;
        }
        case PRRefreshControlStateReady:
        {
            [UIView animateWithDuration:kPRRefreshControlAnimationIntervalArrow animations:^{
                self.arrowImageView.hidden = NO;
                self.arrowImageView.transform = CGAffineTransformMakeRotation(-M_PI);
            }];
            [self.activityIndicator stopAnimating];
            break;
        }
        case PRRefreshControlStateRefreshing:
        {
            [UIView animateWithDuration:kPRRefreshControlAnimationIntervalArrow animations:^{
                self.arrowImageView.hidden = YES;
                self.arrowImageView.transform = CGAffineTransformIdentity;
            }];
            [self.activityIndicator startAnimating];
            break;
        }
    }
    _refreshState = refreshState;
}

#pragma mark - Getters and setters

- (void)setHeight:(CGFloat)height
{
    if (_height != height) {
        _height = height;
        self.frame = CGRectMake(- self.scrollViewContentInset.left,
                                - self.height,
                                CGRectGetWidth(self.scrollView.frame),
                                self.height);
    }
}

- (void)setVerticalOffset:(CGFloat)verticalOffset
{
    if (_verticalOffset != verticalOffset) {
        _verticalOffset = verticalOffset;
        CGPoint center = self.contentView.center;
        center.y += self.verticalOffset;
        self.arrowImageView.center = center;
        self.activityIndicator.center = center;
    }
}

- (void)setScrollViewContentInset:(UIEdgeInsets)scrollViewContentInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_scrollViewContentInset, scrollViewContentInset)) {
        _scrollViewContentInset = scrollViewContentInset;
    }
    self.frame = CGRectMake(- self.scrollViewContentInset.left,
                            - self.height,
                            CGRectGetWidth(self.scrollView.frame),
                            self.height);
}

#pragma mark - Life cycle

- (id)init
{
    self = [self initWithFrame:CGRectMake(0, - kPRRefreshControlHeight, 320.f, kPRRefreshControlHeight)];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.height = kPRRefreshControlHeight;
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleHeight);
        self.contentView = contentView;
        [self addSubview:contentView];
        
        CGPoint center = contentView.center;
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PRRefreshControl.bundle/Arrow"]];
        arrowImageView.center = center;
        arrowImageView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                           UIViewAutoresizingFlexibleRightMargin |
                                           UIViewAutoresizingFlexibleTopMargin |
                                           UIViewAutoresizingFlexibleBottomMargin);
        self.arrowImageView = arrowImageView;
        [contentView addSubview:arrowImageView];
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center = center;
        activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin |
                                              UIViewAutoresizingFlexibleBottomMargin);
        self.activityIndicator = activityIndicator;
        [contentView addSubview:activityIndicator];
        
        self.refreshState = PRRefreshControlStateNone;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if ([newSuperview isKindOfClass:UIScrollView.class]) {
        self.scrollView = (UIScrollView *)newSuperview;
        
        UIScrollView *scrollView = self.scrollView;
        
        self.scrollViewContentInset = scrollView.contentInset;
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleBottomMargin);
        
        [self.scrollView addObserver:self
                          forKeyPath:NSStringFromSelector(@selector(contentOffset))
                             options:NSKeyValueObservingOptionNew
                             context:nil];
        [self.scrollView.panGestureRecognizer addObserver:self
                                               forKeyPath:NSStringFromSelector(@selector(state))
                                                  options:NSKeyValueObservingOptionNew
                                                  context:nil];
    } else {
        [self.scrollView removeObserver:self
                             forKeyPath:NSStringFromSelector(@selector(contentOffset))];
        [self.scrollView.panGestureRecognizer removeObserver:self
                                                  forKeyPath:NSStringFromSelector(@selector(state))];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.scrollView) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
            [self scrollViewDidScroll];
        }
    } else if (object == self.scrollView.panGestureRecognizer) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
            UIGestureRecognizerState state = [change[NSKeyValueChangeNewKey] integerValue];
            if (state == UIGestureRecognizerStateEnded ||
                state == UIGestureRecognizerStateCancelled) {
                [self scrollViewDidEndDragging];
            }
        }
    }
}

- (void)scrollViewDidScroll
{
    UIScrollView *scrollView = self.scrollView;
    UIEdgeInsets contentInset = self.scrollViewContentInset;
    CGFloat offset = scrollView.contentOffset.y + contentInset.top;
    if (self.isRefreshing) {
        contentInset.top += MIN(MAX(0, - offset), self.height);
        scrollView.contentInset = contentInset;
    } else if (scrollView.isDragging) {
        if (offset < - self.height) {
            self.refreshState = PRRefreshControlStateReady;
        } else if (offset < 0) {
            self.refreshState = PRRefreshControlStateNormal;
        } else {
            self.refreshState = PRRefreshControlStateNone;
        }
    }
}

- (void)scrollViewDidEndDragging
{
    UIScrollView *scrollView = self.scrollView;
    UIEdgeInsets contentInset = self.scrollViewContentInset;
    CGFloat offset = scrollView.contentOffset.y + contentInset.top;
    if (!self.refreshing) {
        if (offset < - self.height) {
            [self beginRefreshing];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

@end
