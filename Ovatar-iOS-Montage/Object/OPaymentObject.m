//
//  OPaymentObject.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 10/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OPaymentObject.h"
#import "OConstants.h"

@implementation OPaymentObject

-(instancetype)init {
    self = [super init];
    if (self) {
        self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        self.mixpanel = [Mixpanel sharedInstance];
        
    }
    return self;
    
}

-(NSArray *)codes {
    NSMutableArray *codes = [[NSMutableArray alloc] init];
    [codes addObject:@{@"type":@"unlock", @"code":@"yourthebest", @"identifyer":@"com.ovatar.watermarkremove_tier_1"}];
    [codes addObject:@{@"type":@"discount", @"code":@"alrightgoonthen", @"identifyer":@"com.ovatar.watermarkremove_tier_3"}];
    
    return codes;
    
}

-(void)paymentRecordInterest {
    NSMutableArray *intrest = [[NSMutableArray alloc] initWithArray:[self.data objectForKey:@"app_product_interest"]];
    [intrest addObject:[NSDate date]];
    
    [self.data setObject:intrest forKey:@"app_product_interest"];
    [self.data synchronize];
    
}

-(void)paymentDestroyCurrentPricing {
    [self.data removeObjectForKey:@"app_product"];
    [self.data synchronize];
    
}

-(void)paymentRetriveCurrentPricing {
    if ([self.data objectForKey:@"app_product"] == nil) {
        self.purchase = false;
        if ([SKPaymentQueue canMakePayments]) {
//            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:APP_PREMIUM_IDENTIFYER]];
//            [request setDelegate:self];
//            [request start];
            
        }
        
    }
    
}

-(NSString *)paymentCurrency {
    if ([self.data objectForKey:@"app_product"] == nil) return @"£";
    else return [[self.data objectForKey:@"app_product"] objectForKey:@"currency"];
    
}

-(float)paymentAmount {
    if ([self.data objectForKey:@"app_product"] == nil) return 3.99;
    else return [[[self.data objectForKey:@"app_product"] objectForKey:@"price"] floatValue];
    
}

-(NSString *)paymentProductName {
    if ([self.data objectForKey:@"app_product"] == nil) return NSLocalizedString(@"Subscription_Plan_Title", nil);
    else return [[self.data objectForKey:@"app_product"] objectForKey:@"name"];
    
}

-(void)purchaseApplyPromotionCode:(NSString *)code {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@" ,code];
    NSDictionary *returned = [[self.codes filteredArrayUsingPredicate:predicate] firstObject];
    if (returned != nil) {
        if ([[returned objectForKey:@"type"] isEqualToString:@"unlock"]) {
            if ([self.delegate respondsToSelector:@selector(paymentSucsessfullyUpgradedWithState:)]) {
                [self.delegate paymentSucsessfullyUpgradedWithState:OPaymentStatePromotionAdded];
                
            }
            
            [self paymentSucsessfullyUpgraded:nil];
            
        }
        
        [self.mixpanel track:@"App Promotion Code Applied" properties:@{@"Code":[returned objectForKey:@"code"],
                                                                        @"Type":[returned objectForKey:@"type"]}];
        
    }
    else {
        if ([self.delegate respondsToSelector:@selector(paymentReturnedErrors:)]) {
            [self.delegate paymentReturnedErrors:[NSError errorWithDomain:@"The promo code is invalid. Sorry, no unlimited for you today." code:300 userInfo:nil]];
            
        }
        
    }
    
}

-(void)purchaseItemWithIdentifyer:(NSString *)identifyer {
    self.purchase = true;
    self.restoring = false;
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:identifyer]];
    [request setDelegate:self];
    [request start];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
    
}

-(void)purchaseRestore {
    self.restoring = true;
    if ([SKPaymentQueue canMakePayments]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(paymentReturnedErrors:)]) {
                [self.delegate paymentReturnedErrors:[NSError errorWithDomain:NSLocalizedString(@"Subscription_Disabled_Error", nil) code:400 userInfo:nil]];
                
            }
            
        });
        
    }
    
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(paymentReturnedErrors:)]) {
            [self.delegate paymentReturnedErrors:error];
            
        }
        
    });
    
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(paymentReturnedErrors:)]) {
            [self.delegate paymentReturnedErrors:error];
            
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
        
    });
    
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (response.products.count > 0) {
        self.product = response.products.firstObject;
        self.payment = [SKPayment paymentWithProduct:response.products.firstObject];
        
        if (self.product != nil) {
            [self.data setObject:@{@"currency":self.product.priceLocale.currencySymbol,
                                   @"price":[NSNumber numberWithFloat:self.product.price.floatValue],
                                   @"name":self.product.localizedTitle,
                                   @"identifyer":self.product.localizedTitle
                                   }
                          forKey:@"app_product"];
            [self.data synchronize];
            
        }
        
        if (self.purchase) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] addPayment:self.payment];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(paymentProcessing:)]) {
                [self.delegate paymentProcessing:self.restoring];
                
            }
            
        });
        
    }
    
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (transaction.transactionState == SKPaymentTransactionStatePurchasing) {
                if ([self.delegate respondsToSelector:@selector(paymentProcessing:)]) {
                    [self.delegate paymentProcessing:self.restoring];
                    
                }
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
                
            }
            else {
                if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
                    if ([self.delegate respondsToSelector:@selector(paymentSucsessfullyUpgradedWithState:)]) {
                        [self.delegate paymentSucsessfullyUpgradedWithState:OPaymentStatePurchased];
                        
                    }
                    
                    [self paymentSucsessfullyUpgraded:transaction];
                    
                }
                
                if (transaction.transactionState == SKPaymentTransactionStateRestored) {
                    if ([self.delegate respondsToSelector:@selector(paymentSucsessfullyUpgradedWithState:)]) {
                        [self.delegate paymentSucsessfullyUpgradedWithState:OPaymentStateRestored];
                        
                    }
                    
                    [self paymentSucsessfullyUpgraded:transaction];
                    
                }
                
                if (transaction.transactionState == SKPaymentTransactionStateFailed || transaction.transactionState == SKPaymentTransactionStateDeferred) {
                    if (transaction.error.code != SKErrorPaymentCancelled) {
                        if ([self.delegate respondsToSelector:@selector(paymentReturnedErrors:)]) {
                            [self.delegate paymentReturnedErrors:transaction.error];
                            
                        }
                        
                    }
                    else {
                        if ([self.delegate respondsToSelector:@selector(paymentCancelled)]) {
                            [self.delegate paymentCancelled];
                            
                        }
                        
                    }
                    
                }
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
            }
            
        });
        
    }
    
}

-(BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product {
    if (self.paymentPurchasedItems.count > 0) return false;
    else return true;
    
}

-(void)paymentSucsessfullyUpgraded:(SKPaymentTransaction *)transaction {
    if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
        [self.mixpanel.people trackCharge:self.product.price];
        [self.mixpanel track:@"App Purchase Sucsessful" properties:
                                                        @{@"Date":transaction.transactionDate,
                                                          @"Name":self.product.localizedDescription,
                                                          @"Key":transaction.transactionIdentifier}];
        
        [self paymentSavePurchasedItem:self.product.productIdentifier];
        
    }
    
}
     
-(void)paymentSavePurchasedItem:(NSString *)identifyer {
    NSMutableArray *purchased = [self paymentPurchasedItems];
    if (![purchased containsObject:identifyer]) [purchased addObject:identifyer];
    
    [self.data setObject:purchased forKey:@"ovatar_purchased"];
    [self.data synchronize];

}
     
-(NSMutableArray *)paymentPurchasedItems {
    if ([[self.data objectForKey:@"ovatar_purchased"] count] == 0) return [[NSMutableArray alloc] init];
    else return [[NSMutableArray alloc] initWithArray:[self.data objectForKey:@"ovatar_purchased"]];
    
}

-(BOOL)paymentPurchasedItemWithIdentifyer:(NSString *)identifyer {
    BOOL exists = false;
    for (NSString *purchased in [self paymentPurchasedItems]) {
        if ([purchased containsString:identifyer]) exists = true;
        
    }

    return exists;
    
}

@end
