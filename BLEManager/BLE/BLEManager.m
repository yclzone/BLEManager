//
//  BLEManager.m
//  BLEManager
//
//  Created by Chenglin Yu on 15/9/27.
//  Copyright © 2015年 yclzone. All rights reserved.
//

#import "BLEManager.h"

static NSString * const CharacteristicForWrite  = @"";
static NSString * const CharacteristicForRead   = @"";

@interface BLEManager ()<CBCentralManagerDelegate, CBPeripheralDelegate>
/** centralManager */
@property (strong, nonatomic) CBCentralManager *centralManager;

/** peripheralConnected */
@property (strong, nonatomic) CBPeripheral *peripheralConnected;

/** discoverdPeripherals */
@property (strong, nonatomic) NSMutableArray *discoverdPeripherals;
@end

@implementation BLEManager

#pragma mark - Public Methods
- (void)scanGoWithSolicitedServiceUUIDs:(nullable NSArray<CBUUID *> *)UUIDs {
    if (self.centralManager.isScanning) {
        [self.centralManager stopScan];
    }
    
    NSDictionary *scanOptions = nil;
    if (UUIDs) {
        NSArray *serviceUUIDs = UUIDs;
        scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey : @(NO),
                        CBCentralManagerScanOptionSolicitedServiceUUIDsKey : serviceUUIDs
                        };
    }
    
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:scanOptions];
}

- (void)scanStop {
    [self.centralManager stopScan];
}

- (void)connectPeripheral:(nonnull CBPeripheral *)peripheral {
    NSDictionary *options = @{CBConnectPeripheralOptionNotifyOnConnectionKey : @(YES),
                              CBConnectPeripheralOptionNotifyOnDisconnectionKey : @(YES),
                              CBConnectPeripheralOptionNotifyOnNotificationKey : @(YES)
                              };
    [self.centralManager connectPeripheral:peripheral
                                   options:options];
}

- (void)disconnectPeripheral:(nonnull CBPeripheral *)peripheral {
    [self.centralManager cancelPeripheralConnection:peripheral];
}

- (void)writeValue:(nonnull NSData *)data
 forCharacteristic:(nonnull CBCharacteristic *)characteristic {
    [self.peripheralConnected writeValue:data
                       forCharacteristic:characteristic
                                    type:CBCharacteristicWriteWithResponse];
}


#pragma mark - CBCentralManagerDelegate
/** 蓝牙状态改变 */
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    NSString *stateInfo = @"";
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            stateInfo = @"CBCentralManagerStatePoweredOff";
            break;
        case CBCentralManagerStatePoweredOn:
            stateInfo = @"CBCentralManagerStatePoweredOn";
            break;
        case CBCentralManagerStateResetting:
            stateInfo = @"CBCentralManagerStateResetting";
            break;
        case CBCentralManagerStateUnauthorized:
            stateInfo = @"CBCentralManagerStateUnauthorized";
            break;
        case CBCentralManagerStateUnknown:
            stateInfo = @"CBCentralManagerStateUnknown";
            break;
        case CBCentralManagerStateUnsupported:
            stateInfo = @"CBCentralManagerStateUnsupported";
            break;
        default:
            break;
    }
    
    NSLog(@"state = %@", stateInfo);
}

/** 发现设备 */
- (void)centralManager:(nonnull CBCentralManager *)central
 didDiscoverPeripheral:(nonnull CBPeripheral *)peripheral
     advertisementData:(nonnull NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(nonnull NSNumber *)RSSI {
    if (self.discoverdPeripherals.count == 0) {
        [self.discoverdPeripherals addObject:peripheral];
    } else {
        BOOL isNew = YES;
        for (CBPeripheral *aPeripheral in self.discoverdPeripherals) {
            if ([aPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                isNew = NO;
                break;
            } else {
                
            }
        }
        if (isNew) {
            [self.discoverdPeripherals addObject:peripheral];
        }
    }
}

/** 连接设备失败 */
- (void)centralManager:(nonnull CBCentralManager *)central
didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral
                 error:(nullable NSError *)error {
    NSLog(@"Fail to connect peripheral %@, ERROR: %@", peripheral.identifier.UUIDString, error.localizedDescription);
}

/** 连接设备成功 */
- (void)centralManager:(nonnull CBCentralManager *)central
  didConnectPeripheral:(nonnull CBPeripheral *)peripheral {
    self.peripheralConnected = peripheral;
    self.peripheralConnected.delegate = self;
    
    NSArray *services = @[[CBUUID UUIDWithString:@"xxx"],
                          [CBUUID UUIDWithString:@"xxxxx"]];
    [self.peripheralConnected discoverServices:services];
}

/** 设备断开 */
- (void)centralManager:(nonnull CBCentralManager *)central
    didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral
                      error:(nullable NSError *)error {
    NSLog(@"Disconnect peripheral %@, ERROR: %@", peripheral.identifier.UUIDString, error.localizedDescription);
}


#pragma mark - CBPeripheralDelegate
/** 发现服务 */
- (void)peripheral:(nonnull CBPeripheral *)peripheral
    didDiscoverServices:(nullable NSError *)error {
    for (CBService *service in peripheral.services) {
        if ([service.UUID.UUIDString isEqualToString:@"xxxx"]) {
            NSLog(@"service = %@", service.UUID.UUIDString);
            
            [self.peripheralConnected discoverCharacteristics:nil
                                                   forService:service];
        }
    }
}

/** 发现特性 */
- (void)peripheral:(nonnull CBPeripheral *)peripheral
    didDiscoverCharacteristicsForService:(nonnull CBService *)service
                                   error:(nullable NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:CharacteristicForWrite]) {
            //
        }
        NSLog(@"%@", characteristic.UUID.UUIDString);
    }
}

/** 向特性写入数据 */
- (void)peripheral:(nonnull CBPeripheral *)peripheral
    didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic
                             error:(nullable NSError *)error {
    NSLog(@"Write value %@ for characteristic %@", characteristic.value, characteristic);
}

/** 特性值改变 */
- (void)peripheral:(nonnull CBPeripheral *)peripheral
    didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic
                              error:(nullable NSError *)error {
    NSLog(@"Characteristic %@ update value %@", characteristic, characteristic.value);
}

#pragma mark - Getter && Setter
- (CBCentralManager *)centralManager {
    if (!_centralManager) {
        
        NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey : @(YES)
                                  };
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:nil
                                                             options:options];
    }
    return _centralManager;
}

- (NSMutableArray *)discoverdPeripherals {
    if (!_discoverdPeripherals) {
        _discoverdPeripherals = [NSMutableArray array];
    }
    return _discoverdPeripherals;
}
@end
