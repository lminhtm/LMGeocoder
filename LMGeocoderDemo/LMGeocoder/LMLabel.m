//
//  LMLabel.m
//  OkieLa
//
//  Created by LMinh on 7/16/15.
//  Copyright (c) 2015 OkieLa. All rights reserved.
//

#import "LMLabel.h"

@implementation LMLabel

- (void)layoutSubviews
{
    if (self.numberOfLines != 1 && self.bounds.size.width != self.preferredMaxLayoutWidth) {
        self.preferredMaxLayoutWidth = self.bounds.size.width;
    }
    [super layoutSubviews];
}

@end
