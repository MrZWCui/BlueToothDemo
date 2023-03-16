//
//  ZWBlueToothListView.h
//  ZWBlueTooth
//
//  Created by 崔先生的MacBook Pro on 2022/9/7.
//

#import <UIKit/UIKit.h>
#import "CoreBluetooth/CoreBluetooth.h"

typedef void(^SelectedPeripheraBlock)(NSArray *dataArray, NSInteger index);

@interface ZWBlueToothListView : UIView

@property (nonatomic, copy) NSArray *dataArray;

@property (nonatomic, copy) SelectedPeripheraBlock selectedPeripheraBlock;

@end
