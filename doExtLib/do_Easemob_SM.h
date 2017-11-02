//
//  do_Easemob_SM.h
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_Easemob_ISM.h"
#import "doSingletonModule.h"
#import "doIEventCenter.h"

@interface do_Easemob_SM : doSingletonModule<do_Easemob_ISM,doIEventCenter>

@end