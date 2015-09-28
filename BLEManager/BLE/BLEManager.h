//
//  BLEManager.h
//  BLEManager
//
//  Created by Chenglin Yu on 15/9/27.
//  Copyright © 2015年 yclzone. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

@interface BLEManager : NSObject
- (void)scanGoWithSolicitedServiceUUIDs:(nullable NSArray<CBUUID *> *)UUIDs;
- (void)scanStop;
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral;
- (void)disconnectPeripheral:(nonnull CBPeripheral *)peripheral;
@end
