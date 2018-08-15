//
//  OPaymentObject.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 10/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "Mixpanel.h"

typedef NS_ENUM(NSInteger, OPaymentState) {
    OPaymentStatePurchased,
    OPaymentStateRestored,
    OPaymentStatePromotionAdded
    
};

@protocol OPaymentDelegate;
@interface OPaymentObject : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) id <OPaymentDelegate> delegate;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) Mixpanel *mixpanel;

@property (nonatomic, strong) SKPayment *payment;
@property (nonatomic, strong) SKProduct *product;
@property (nonatomic, assign) BOOL purchase;
@property (nonatomic, assign) BOOL restoring;

-(void)paymentRecordInterest;
-(void)paymentDestroyCurrentPricing;
-(void)paymentRetriveCurrentPricing;
-(NSString *)paymentCurrency;
-(float)paymentAmount;
-(NSString *)paymentProductName;
-(void)paymentSucsessfullyUpgraded:(SKPaymentTransaction *)transaction;

-(void)purchaseApplyPromotionCode:(NSString *)code;
-(void)purchaseItemWithIdentifyer:(NSString *)identifyer;
-(void)purchaseRestore;

@end

@protocol OPaymentDelegate <NSObject>

@optional

-(void)paymentSucsessfullyUpgradedWithState:(OPaymentState)state;
-(void)paymentReturnedErrors:(NSError *)error;
-(void)paymentProcessing:(BOOL)restoring;
-(void)paymentCancelled;

@end
