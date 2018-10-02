//
//  OPaymentObject.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 10/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OPaymentObject.h"
#import "OConstants.h"
#import "OImageObject.h"

@implementation OPaymentObject

-(instancetype)init {
    self = [super init];
    if (self) {
        self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        
        self.mixpanel = [Mixpanel sharedInstance];
        
        self.slack = [[NSlackObject alloc] init];
        
    }
    return self;
    
}

-(NSArray *)codes {
    NSMutableArray *codes = [[NSMutableArray alloc] init];
    [codes addObject:@{@"type":@"unlock", @"code":@"yourthebest", @"identifyer":@"com.ovatar.montage.monthly.tier_2"}];
    [codes addObject:@{@"type":@"discount", @"code":@"alrightgoonthen", @"identifyer":@"com.ovatar.montage.monthly.tier_2"}];
    
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
        if ([SKPaymentQueue canMakePayments] && ![self paymentPurchasedItemWithProducts:@[@"montage.monthly", @"montage.yearly", @"montage_watermark"]]) {
            [self paymentPricingTier:^(BOOL elite, BOOL completed) {
                if (completed) {
                    [self.mixpanel identify:self.mixpanel.distinctId];
                    [self.mixpanel.people set:@{@"Elite":@(elite)}];
                    
                    NSString *identifyer = nil;
                    if (elite) identifyer = @"com.ovatar.montage.monthly.tier_2";
                    else identifyer = @"com.ovatar.montage.monthly.tier_1";
                    
                    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:identifyer]];
                    [request setDelegate:self];
                    [request start];
                    
                }
                
            }];
            
        }
        
    }
    
}

-(void)paymentPricingTier:(void (^)(BOOL elite, BOOL completed))completion {
    BOOL __block someoneisdoingwell = false;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"json"];
    NSArray *content = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
    
    if (IS_IPHONE_XS_MAX) {
        someoneisdoingwell = true;
        completion(someoneisdoingwell, true);

    }
    else {
        [[OImageObject sharedInstance] imageAuthorization:false completion:^(PHAuthorizationStatus status) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [[OImageObject sharedInstance] imagesFromAlbum:nil limit:25 completion:^(NSArray *images) {
                        int total = (int)[[images.firstObject objectForKey:@"images"] count];
                        for (int i = 0; i < total; i++) {
                            NSDictionary *item = [[images.firstObject objectForKey:@"images"] objectAtIndex:i];
                            PHAsset *asset = [item objectForKey:@"asset"];
                            for (NSDictionary *place in content) {
                                float latitude = [[place objectForKey:@"latitude"] floatValue];
                                float longitude = [[place objectForKey:@"longitude"] floatValue];
                                CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                                CLLocationDistance distance = [asset.location distanceFromLocation:location];
                                float miles = (distance / 1609.344);
                                if (miles <= 1.3) {
                                    NSLog(@"\nPlace: %@ distance : %fm" ,[place objectForKey:@"name"] ,(distance / 1609.344));
                                    someoneisdoingwell = true;
                                    completion(someoneisdoingwell, true);
                                    break;
                                    
                                }
                                
                                if (i == (total - 1)) {
                                    completion(someoneisdoingwell, true);
                                    break;
                                    
                                }
                                
                            }
                            
                        }
                        
                    }];
                    
                }
                else completion(false, false);
                
            }];
            
        }];
        
    }
        
}

-(NSString *)paymentCurrency {
    if ([self.data objectForKey:@"app_product"] == nil) return @"£";
    else return [[self.data objectForKey:@"app_product"] objectForKey:@"currency"];
    
}

-(NSString *)paymentProductIdentifyer {
    if ([self.data objectForKey:@"app_product"] == nil) return @"com.ovatar.montage.monthly.tier_1";
    else return [[self.data objectForKey:@"app_product"] objectForKey:@"identifyer"];
    
}

-(float)paymentAmount {
    if ([self.data objectForKey:@"app_product"] == nil) return 3.99;
    else return [[[self.data objectForKey:@"app_product"] objectForKey:@"price"] floatValue];
    
}

-(NSArray *)productsFromIdentifyer:(NSString *)identifyer {
    NSMutableArray *products = [[NSMutableArray alloc] init];
    if ([identifyer containsString:@"montage.monthly"] || [identifyer containsString:@"montage.yearly"]) {
        [products addObject:@{@"key":@"music",
                              @"summary":NSLocalizedString(@"Subscription_Music_Item", nil),
                              @"icon":@"purchase_music_icon"}];
        
        [products addObject:@{@"key":@"watermark",
                              @"summary":NSLocalizedString(@"Subscription_Watermark_Item", nil),
                              @"icon":@"notice_watermark_icon"}];
        
    }
    
    return products;
    
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
            
                [self.data setObject:code forKey:@"promo_code_added"];
                [self.data setObject:[returned objectForKey:@"identifyer"] forKey:@"promo_code_product"];
                [self.data setObject:[NSDate date] forKey:@"promo_code_timestamp"];
                [self.data synchronize];

                [self paymentSavePurchasedItem:[returned objectForKey:@"identifyer"]];
                [self.delegate paymentSucsessfullyUpgradedWithState:OPaymentStatePromotionAdded];

            }
                
        }
        
        [self.mixpanel track:@"App Promotion Code Applied" properties:@{@"Code":[returned objectForKey:@"code"],
                                                                        @"Type":[returned objectForKey:@"type"]}];
        
    }
    else {
        if ([self.delegate respondsToSelector:@selector(paymentReturnedErrors:)]) {
            [self.delegate paymentReturnedErrors:[NSError errorWithDomain:NSLocalizedString(@"Subscription_Promo_Error", nil) code:300 userInfo:nil]];
            
        }
        
    }
    
}

-(void)purchaseSubscription {
    self.purchase = true;
    self.restoring = false;
    
    if (self.paymentProductIdentifyer == nil) [self paymentRetriveCurrentPricing];
    else {
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.paymentProductIdentifyer]];
        [request setDelegate:self];
        [request start];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
        
    }
    
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
                                   @"identifyer":self.product.productIdentifier}
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

-(BOOL)paymentPurchasedItemWithProducts:(NSArray *)products {
    BOOL exists = false;
    for (NSString *product in products) {
        for (NSString *purchased in self.paymentPurchasedItems) {
            if ([purchased containsString:product]) exists = true;
            
        }
        
    }

    return exists;
    
}

@end
