/*
 *********************************************************************************
 *
 * Copyright (C) 2013-2014 T Dispatch Ltd
 *
 * See the LICENSE for terms and conditions of use, modification and distribution
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 *********************************************************************************
 *
 * @author Marcin Orlowski <marcin.orlowski@webnet.pl>
 *
 *********************************************************************************
 */

#import <UIKit/UIKit.h>

#import "CustomDialog.h"
#import "MapAnnotation.h"
#import "VehiclesManager.h"
#import "CreditCard.h"

//valid booking if everything webt ok, nil if user cancelled the proces.
typedef void (^DialogConfirmationBlock)(NSObject* response, BOOL bookedForLater);

@interface ConfirmBookingDialog : CustomDialog

+ (ConfirmBookingDialog*) showDialog:(MapAnnotation *)pickup
                             dropoff:(MapAnnotation *)dropoff
                 withVehiclesManager:(VehiclesManager *)vehiclesManager
                   confirmationBlock:(DialogConfirmationBlock)confirmationBlock;

@end
