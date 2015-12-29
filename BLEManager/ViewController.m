//
//  ViewController.m
//  BLEManager
//
//  Created by Chenglin Yu on 15/9/27.
//  Copyright © 2015年 yclzone. All rights reserved.
//

#import "ViewController.h"
#import "BLEManager.h"

@interface ViewController ()<BLEManagerDelagate>
/** manager */
@property (nonatomic, strong) BLEManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    BLEManager *manager = [BLEManager new];
    manager.delegate = self;
    [manager scanGoWithSolicitedServiceUUIDs:nil];
    self.manager = manager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.manager readValue];
}

#pragma mark - Event Response

- (IBAction)scanButtonDidClicked:(id)sender {
    [self.manager scanGoWithSolicitedServiceUUIDs:nil];
}

#pragma mark - BLEManagerDelagate
- (void)manager:(BLEManager *)manager didDiscoverPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI {
    if ([peripheral.name isEqualToString:@"yuejing"]) {
        NSLog(@"发现%@", peripheral);
        [manager connectPeripheral:peripheral];
    }
}

- (void)manager:(BLEManager *)manager didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%@", characteristic.value);
}

@end
