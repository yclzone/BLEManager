//
//  BLEManager.h
//  BLEManager
//
//  Created by Chenglin Yu on 15/9/27.
//  Copyright © 2015年 yclzone. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

@class BLEManager;
@protocol BLEManagerDelagate <NSObject>

- (void)manager:(BLEManager *)manager didDiscoverPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI;
- (void)manager:(BLEManager *)manager didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)manager:(BLEManager *)manager didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void)manager:(BLEManager *)manager didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic
          error:(nullable NSError *)error;

@end

@interface BLEManager : NSObject
- (void)scanGoWithSolicitedServiceUUIDs:(nullable NSArray<CBUUID *> *)UUIDs;
- (void)scanStop;
- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral;
- (void)disconnectPeripheral:(nonnull CBPeripheral *)peripheral;

- (void)readValue;

/** delegate */
@property (nonatomic, assign) id<BLEManagerDelagate> delegate;

@end
