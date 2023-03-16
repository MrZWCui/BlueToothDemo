//
//  ZWBlueToothListView.m
//  ZWBlueTooth
//
//  Created by 崔先生的MacBook Pro on 2022/9/7.
//

#import "ZWBlueToothListView.h"

@interface ZWBlueToothListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@end

@implementation ZWBlueToothListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [[UIColor grayColor] CGColor];
        self.layer.borderWidth = 1;
        [self initView];
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [self.tableView reloadData];
}

- (void)initView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    self.tableView = tableView;
    [self addSubview:self.tableView];
}

#pragma mark - Delegate & DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if ([self.dataArray[indexPath.row] isKindOfClass:[CBPeripheral class]]) {
        CBPeripheral *peripheral = self.dataArray[indexPath.row];
        cell.textLabel.text = peripheral.name;
    }
    
    if ([self.dataArray[indexPath.row] isKindOfClass:[CBService class]]) {
        CBService *service = self.dataArray[indexPath.row];
        cell.textLabel.text = service.UUID.UUIDString;
    }
    
    if ([self.dataArray[indexPath.row] isKindOfClass:[CBCharacteristic class]]) {
        CBCharacteristic *characteristic = self.dataArray[indexPath.row];
        cell.textLabel.text = characteristic.UUID.UUIDString;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedPeripheraBlock) {
        self.selectedPeripheraBlock(self.dataArray, indexPath.row);
    }
}

@end
