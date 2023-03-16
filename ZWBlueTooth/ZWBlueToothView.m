//
//  ZWBlueToothView.m
//  ZWBlueTooth
//
//  Created by 崔先生的MacBook Pro on 2022/9/6.
//

#import "ZWBlueToothView.h"
#import "ZWBlueToothListView.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ZWBlueToothView () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) ZWBlueToothListView *listView;

@property (nonatomic, strong) UIButton *scanDevicesBtn;
@property (nonatomic, strong) UILabel *conectedLabel;

@property (nonatomic, strong) UIButton *scanServicesBtn;
@property (nonatomic, strong) UILabel *selectedServiceLabel;

@property (nonatomic, strong) UIButton *scanCharacteristicBtn;
@property (nonatomic, strong) UILabel *selectedCharacteristicLabel;

@property (nonatomic, strong) UIButton *writeDataBtn;
@property (nonatomic, strong) UIButton *disConnectBtn;

//中心管理者(管理设备的扫描和连接)
@property (nonatomic, strong) CBCentralManager *centralManager;
//存储的设备
@property (nonatomic, strong) NSMutableArray *peripherals;
//扫描到的设备
@property (nonatomic, strong) CBPeripheral *cbPeripheral;
//扫描到的服务
@property (nonatomic, strong) CBService *cbService;
//扫描到的特征
@property (nonatomic, strong) CBCharacteristic *cbCharacteristic;
//外设状态
@property (nonatomic, assign) CBManagerState peripheralState;

//设备名 + mac地址
@property (nonatomic, strong) NSString *name;
//用来读取信息的特征 0xFFB1
@property (nonatomic, strong) CBCharacteristic *readCharacteristic;


@end

@implementation ZWBlueToothView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addUI];
        //建立中心角色
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

-(void)addUI {
    //扫描设备
    _scanDevicesBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _scanDevicesBtn.center = CGPointMake(self.center.x, 200);
    [_scanDevicesBtn setTitle:@"扫描设备" forState:UIControlStateNormal];
    [_scanDevicesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _scanDevicesBtn.layer.borderWidth = 1;
    _scanDevicesBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    [_scanDevicesBtn addTarget:self action:@selector(scanPeripheralClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_scanDevicesBtn];
    
    _conectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
    _conectedLabel.center = CGPointMake(self.center.x, 250);
    [self addSubview:_conectedLabel];
    
    //扫描服务
    _scanServicesBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _scanServicesBtn.center = CGPointMake(self.center.x, 300);
    [_scanServicesBtn setTitle:@"扫描服务" forState:UIControlStateNormal];
    [_scanServicesBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _scanServicesBtn.layer.borderWidth = 1;
    _scanServicesBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    [_scanServicesBtn addTarget:self action:@selector(serverClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_scanServicesBtn];
    _scanServicesBtn.hidden = YES;
    
    _selectedServiceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
    _selectedServiceLabel.center = CGPointMake(self.center.x, 350);
    [self addSubview:_selectedServiceLabel];
    
    //扫描特征
    _scanCharacteristicBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _scanCharacteristicBtn.center = CGPointMake(self.center.x, 400);
    [_scanCharacteristicBtn setTitle:@"扫描特征" forState:UIControlStateNormal];
    [_scanCharacteristicBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _scanCharacteristicBtn.layer.borderWidth = 1;
    _scanCharacteristicBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    [_scanCharacteristicBtn addTarget:self action:@selector(characteristicClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_scanCharacteristicBtn];
    _scanCharacteristicBtn.hidden = YES;
    
    _selectedCharacteristicLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
    _selectedCharacteristicLabel.center = CGPointMake(self.center.x, 450);
    [self addSubview:_selectedCharacteristicLabel];
    
    //写入数据
    _writeDataBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _writeDataBtn.center = CGPointMake(self.center.x, 500);
    [_writeDataBtn setTitle:@"写入数据" forState:UIControlStateNormal];
    [_writeDataBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _writeDataBtn.layer.borderWidth = 1;
    _writeDataBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    [_writeDataBtn addTarget:self action:@selector(writeCheckBleWithBle) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_writeDataBtn];
    _writeDataBtn.hidden = YES;
    
    //断开连接
    _disConnectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _disConnectBtn.center = CGPointMake(self.center.x, self.frame.size.height - 50);
    [_disConnectBtn setTitle:@"断开连接" forState:UIControlStateNormal];
    [_disConnectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _disConnectBtn.layer.borderWidth = 1;
    _disConnectBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    [_disConnectBtn addTarget:self action:@selector(disConnect) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_disConnectBtn];
    _disConnectBtn.hidden = YES;
}

#pragma mark - 设备
//扫描设备
- (void)scanPeripheralClick {
    if (self.peripheralState == CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

/**
 扫描到设备
 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (peripheral.name) {
        NSLog(@"发现设备,设备名:%@", peripheral.name);
        [self.peripherals addObject:peripheral];
        NSData *adata = advertisementData[@"kCBAdvDataManufacturerData"];
        NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[adata length]];
        /**
         该块有三个参数:
         bytes
         当前范围的字节.
         byteRange
         当前数据字节的范围.
         stop
         对布尔值的引用.该块可以将值设置为YES以停止进一步处理数据.stop参数是一个out-only参数.您应该只在块中将此布尔值设置为YES.
         
         NSData 转  十六进制string
         @return NSString类型的十六进制string
         */
        [adata enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
            char *dataBytes = (char *)bytes;
            for (NSInteger i = 0; i < byteRange.length; i++) {
                NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
                if ([hexStr length] == 2) {
                    [string appendString:hexStr];
                } else {
                    [string appendFormat:@"0%@", hexStr];
                }
            }
        }];
        
        if (string.length > 16) {
            NSLog(@"广播包: %@", string);
            
            NSString *macStr = [string substringWithRange:NSMakeRange(4, 12)];
            NSLog(@"MAC地址: %@", macStr);
        }
        
        if (!_listView) {
            self.listView = [[ZWBlueToothListView alloc] initWithFrame:CGRectMake(50, 100, self.frame.size.width - 100, self.frame.size.height - 200)];
            self.listView.dataArray = self.peripherals;
            [self addSubview:self.listView];
            
            __weak typeof(self) weakSelf = self;
            self.listView.selectedPeripheraBlock = ^(NSArray *dataArray, NSInteger index) {
                [weakSelf.centralManager stopScan];
                
                if ([dataArray[index] isKindOfClass:[CBPeripheral class]]) {
                    CBPeripheral *peripheral = dataArray[index];
                    [weakSelf.centralManager connectPeripheral:peripheral options:nil];
                }
                
                [weakSelf hideListView];
            };
        }
        self.listView.dataArray = self.peripherals;
    }
}

/**
 连接成功
 
 @param central 中心管理者
 @param peripheral 连接成功的设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"连接设备: %@", peripheral.name);
    self.cbPeripheral = peripheral;
    _conectedLabel.text = [@"已连接设备: " stringByAppendingFormat:@"%@", peripheral.name];
    _scanServicesBtn.hidden = NO;
    _disConnectBtn.hidden = NO;
}

/**
 连接失败
 @param central 中心管理者
 @param peripheral 连接失败的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%@ 设备连接失败", peripheral.name);
}

/**
 连接断开
 @param central 中心管理者
 @param peripheral 连接断开的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接断开");
}

#pragma mark - 服务
//扫描服务
- (void)serverClick {
    if (self.cbPeripheral) {
        //设置设备的代理
        self.cbPeripheral.delegate = self;
        //servi:传入nil 代表扫描所有服务
        [self.cbPeripheral discoverServices:nil];
    }
}

/**
 扫描到服务
 @param peripheral 服务对应的设备
 @param error 扫描错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    //遍历所有服务
    for (CBService *service in peripheral.services) {
        NSLog(@"服务: %@", service.UUID.UUIDString);
    }
    
    if (!_listView) {
        self.listView = [[ZWBlueToothListView alloc] initWithFrame:CGRectMake(50, 100, self.frame.size.width - 100, self.frame.size.height - 200)];
        self.listView.dataArray = peripheral.services;
        [self addSubview:self.listView];
        
        __weak typeof(self) weakSelf = self;
        self.listView.selectedPeripheraBlock = ^(NSArray *dataArray, NSInteger index) {
            if ([dataArray[index] isKindOfClass:[CBService class]]) {
                CBService *service = dataArray[index];
                weakSelf.cbService = service;
                weakSelf.selectedServiceLabel.text = [@"已选择服务: " stringByAppendingFormat:@"%@", service.UUID.UUIDString];
                weakSelf.scanCharacteristicBtn.hidden = NO;
            }
            
            [weakSelf hideListView];
        };
    }
}

#pragma mark - 特征
- (void)characteristicClick {
    //根据服务区扫描特征
    NSLog(@"开始扫描%@服务的特征", self.cbService.UUID.UUIDString);
    [self.cbPeripheral discoverCharacteristics:nil forService:self.cbService];
}

/**
 扫描到对应的特征
 @param peripheral 设备
 @param service 特征对应的服务
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@">>>服务:%@ 的 特征: %@", service.UUID, characteristic.UUID);
        
        //"FFB1"书写自己需要的特征值
        if ([characteristic.UUID.UUIDString isEqualToString:@"FFB1"]) {
            self.readCharacteristic = characteristic;
        }
    }
    //选择一个订阅
    if (!_listView) {
        self.listView = [[ZWBlueToothListView alloc] initWithFrame:CGRectMake(50, 100, self.frame.size.width - 100, self.frame.size.height - 200)];
        self.listView.dataArray = service.characteristics;
        [self addSubview:self.listView];
        
        __weak typeof(self) weakSelf = self;
        self.listView.selectedPeripheraBlock = ^(NSArray *dataArray, NSInteger index) {
            if ([dataArray[index] isKindOfClass:[CBCharacteristic class]]) {
                CBCharacteristic *characteristic = dataArray[index];
                weakSelf.cbCharacteristic = characteristic;
                weakSelf.selectedCharacteristicLabel.text = [@"已选择特征: " stringByAppendingFormat:@"%@", characteristic.UUID.UUIDString];
                [weakSelf.cbPeripheral readValueForCharacteristic:characteristic];
                //订阅，实时接收
                [weakSelf.cbPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                weakSelf.writeDataBtn.hidden = NO;
            }
            
            [weakSelf hideListView];
        };
    }
}

/**
 根据特征读到数据
 @param peripheral 读取到数据对应的设备
 @param characteristic 特征
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //接收蓝牙发来的数据
    NSLog(@"characteristic uuid: %@ value: %@", characteristic.UUID, characteristic.value);
    if (characteristic.value.length >= 12) {
        NSString *str = [self convertDataToHexStr:characteristic.value];
        NSString *circleStr = [str substringWithRange:NSMakeRange(6, 8)];
        NSString *timeStr = [str substringWithRange:NSMakeRange(14, 8)];
        
        NSString *circle10 = [NSString stringWithFormat:@"%lu", strtoul([circleStr UTF8String], 0, 16)];
        NSString *time10 = [NSString stringWithFormat:@"%lu", strtoul([timeStr UTF8String], 0, 16)];
        
        NSLog(@"圈数: %@ 时间: %@", circle10, time10);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

#pragma mark - 操作

- (void)writrBtnPeripheraClick {
    [self writeCheckBleWithBle];
}

- (void)writeCheckBleWithBle {
    Byte byte[] = {0xA1, 0x02, 0x01, 0x00, 0x55};
    NSData *data = [[NSData alloc] initWithBytes:byte length:5];
    [self.cbPeripheral writeValue:data forCharacteristic:self.cbCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"写入成功");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"收藏成功！" preferredStyle:UIAlertControllerStyleAlert];//先创建一个弹窗控制器 然后里面有title和message来提示需要的东西
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];//添加一个弹窗的action 活动可以是取消 可以是确认
    [alert addAction:sureAction];
//    [self presentViewController:alert animated:NO completion:nil];

    [self performSelector:@selector(disAlert:) withObject:alert afterDelay:1];

    if (self.readCharacteristic) {
        [peripheral readValueForCharacteristic:self.readCharacteristic];
    }
}

-(void)disAlert:(UIAlertController *)alert {
   [alert dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 状态

//断开连接
- (void)disConnect {
    [self.centralManager cancelPeripheralConnection:self.cbPeripheral];
    _conectedLabel.text = @"";
    _scanServicesBtn.hidden = YES;
    _selectedServiceLabel.text = @"";
    _scanCharacteristicBtn.hidden = YES;
    _selectedCharacteristicLabel.text = @"";
    _writeDataBtn.hidden = YES;
}

//状态更新时调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"未知状态");
            self.peripheralState = central.state;
            break;
        case CBManagerStateResetting:
            NSLog(@"重制状态");
            self.peripheralState = central.state;
            break;
        case CBManagerStateUnsupported:
            NSLog(@"不支持的状态");
            self.peripheralState = central.state;
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"未授权的状态");
            self.peripheralState = central.state;
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"关闭状态");
            self.peripheralState = central.state;
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"开启状态-可用状态");
            self.peripheralState = central.state;
            NSLog(@"%ld", (long)self.peripheralState);
            break;
        default:
            break;
    }
}

/**
 NSData 转  十六进制string
 @return NSString类型的十六进制string
 */
- (NSString *)convertDataToHexStr:(NSData *)adata{
    if (!adata || [adata length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[adata length]];
    
    [adata enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

- (void)hideListView {
    [self.centralManager stopScan];
    [self.listView removeFromSuperview];
    self.listView = nil;
}

- (NSMutableArray *)peripherals {
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

@end
