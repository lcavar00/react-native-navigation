#import <UIKit/UIKit.h>
#import "RNNDotIndicatorPresenter.h"
#import "UIViewController+LayoutProtocol.h"
#import "DotIndicatorOptions.h"
#import "UITabBarController+RNNUtils.h"

@implementation RNNDotIndicatorPresenter

- (void)apply:(UIViewController *)child :(DotIndicatorOptions *)options {
    if (![options hasValue]) return;

    if ([options.visible isFalse]) {
        if ([child tabBarItem].tag > 0) [self remove:child];
        return;
    }
    if ([self currentIndicatorEquals:child :options]) return;

    if ([self hasIndicator:child]) [self remove:child];

    UIView *indicator = [self createIndicator:options];
    [child tabBarItem].tag = indicator.tag;

    UITabBarController *bottomTabs = [self getTabBarController:child];
    int index = (int) [[bottomTabs childViewControllers] indexOfObject:child];
    [[bottomTabs getTabView:index] addSubview:indicator];
    [self applyConstraints:options badge:indicator tabBar:bottomTabs index:index];
}

- (UIView *)createIndicator:(DotIndicatorOptions *)options {
    UIView * indicator = [UIView new];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    indicator.layer.cornerRadius = [[options.size getWithDefaultValue:@6] floatValue] / 2;
    indicator.backgroundColor = [options.color getWithDefaultValue:[UIColor redColor]];
    indicator.tag = arc4random();
    return indicator;
}


- (void)applyConstraints:(DotIndicatorOptions *)options badge:(UIView *)badge tabBar:(UITabBarController *)bottomTabs index:(int)index {
    UIView *icon = [bottomTabs getTabIcon:index];
    float size = [[options.size getWithDefaultValue:@6] floatValue];
    [NSLayoutConstraint activateConstraints:@[
            [badge.leftAnchor constraintEqualToAnchor:icon.rightAnchor constant:-size / 2],
            [badge.topAnchor constraintEqualToAnchor:icon.topAnchor constant:-size / 2],
            [badge.widthAnchor constraintEqualToConstant:size],
            [badge.heightAnchor constraintEqualToConstant:size]
    ]];
}

- (BOOL)currentIndicatorEquals:(UIViewController *)child :(DotIndicatorOptions *)options {
    if (![self hasIndicator:child]) return NO;
    UIView *currentIndicator = [self getCurrentIndicator:child];
    return [[currentIndicator backgroundColor] isEqual:[options.color getWithDefaultValue:[UIColor redColor]]];
}

- (UIView *)getCurrentIndicator:(UIViewController *)child {
    UITabBarController *bottomTabs = [self getTabBarController:child];
    int tabIndex = (int) [[bottomTabs childViewControllers] indexOfObject:child];
    return [[bottomTabs getTabView:tabIndex] viewWithTag:[child tabBarItem].tag];
}

- (BOOL)hasIndicator:(UIViewController *)child {
    return [child tabBarItem].tag > 0;
}

- (void)remove:(UIViewController *)child {
    UIView *view = [[[child tabBarController] tabBar] viewWithTag:[child tabBarItem].tag];
    [view removeFromSuperview];
    [child tabBarItem].tag = -1;
}

- (UITabBarController *)getTabBarController:(id)viewController {
    return [viewController isKindOfClass:[UITabBarController class]] ? viewController : [viewController tabBarController];
}

@end