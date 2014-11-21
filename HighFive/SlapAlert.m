//
//  SlapAlert.m
//  HighFive
//
//  Created by Trevor Grayson on 9/29/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "SlapAlert.h"
#import "SlapNet.h"

@implementation SlapAlert

+(SlapAlert*) newAlert:(Slap*) slap {
    NSString *msg = [NSString stringWithFormat:@"%@ high fived you with a %@ %4.2f high five!", slap.slapper.name, [SlapNet highFiveDescription: slap.ferocity], slap.ferocity ];
    SlapAlert *alert = [[SlapAlert alloc] initWithTitle:@"Slap!" message: msg delegate:self cancelButtonTitle:@"Leave Hanging" otherButtonTitles: @"Slap Back", nil];
    //put in init
    UIImage *img = [[UIImage alloc] initWithContentsOfFile: @"slap.jpg"];
    UIImageView * iv = [[UIImageView alloc] initWithImage: img];
    [iv setFrame: CGRectMake(10, 40, 264, 200)];
    //[alert setFrame: CGRectMake(0, 0, 500, 800)];
    CGSize theSize = [alert frame].size;
    
    UIGraphicsBeginImageContext(theSize);
    [img drawInRect:CGRectMake(0, 0, theSize.width, theSize.height)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[alert layer] setContents: iv];
    return alert;
}
@end
