//
//  ViewController.m
//  SnipDemo
//
//  Created by 谢英杰(YingjieXie)-顺丰科技技术集团 on 2024/9/26.
//

#import "ViewController.h"
#import <SnipManager/SnipTools.h>

void callback(int ret) {
    
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

//startSnipping
- (IBAction)snipClick:(id)sender {
    NSInteger timestamp = (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
    NSString *path = [[NSString stringWithFormat:@"~/Library/Application Support/fslinkerstd/cache/capture/%@.png", @(timestamp)] stringByExpandingTildeInPath];
    startSnipping([path UTF8String], (int)(path.length), (void *)callback);
}

@end
