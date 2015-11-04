//
//  PracticeReadMusic.m
//  epiano
//
//  Created by jiang nan on 15/8/10.
//  Copyright (c) 2015年 jiang nan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PracticeReadMusic.h"

static unsigned char scales_map[15][7] = {
    {1,3,4,6,8,10,11},
    {1,3,5,6,8,10,11},
    {0,1,3,5,6,8,10},
    {0,1,3,5,7,8,10},
    {0,2,3,5,7,8,10},
    {0,2,3,5,7,9,10},
    {0,2,4,5,7,9,10},
    {0,2,4,5,7,9,11},
    {0,2,4,6,7,9,11},
    {1,2,4,6,7,9,11},
    {1,2,4,6,8,9,11},
    {1,3,4,6,8,9,11},
    {1,3,4,6,8,10,11},
    {1,3,5,6,8,10,11},
    {0,1,3,5,6,8,10},
};

void drawLine(CGContextRef* pCtx, CGPoint StartPoint, CGPoint EndPoint, CGFloat red, CGFloat green, CGFloat blue, CGFloat line_width)
{
    CGContextMoveToPoint(*pCtx, StartPoint.x, StartPoint.y);
    CGContextAddLineToPoint(*pCtx, EndPoint.x, EndPoint.y);
    CGContextSetRGBStrokeColor(*pCtx, red, green, blue, 1.0);
    CGContextSetLineWidth(*pCtx, line_width);
    CGContextStrokePath(*pCtx);     //draw the specified line by the above settings
}

void drawCircular(CGContextRef* pContext, CGRect rect)
{
    CGContextSetRGBStrokeColor(*pContext, (0x00)/255.0, (0x88)/255.0, (0xff)/255.0, 1.0);
    CGContextSetLineWidth(*pContext, 1);
    CGContextAddArc(*pContext, rect.size.width/2.0, rect.size.height/2.0, rect.size.width/2.0*CIRCULAR_RADIUS_SCALE, 0, 2*M_PI, 0);
    CGContextDrawPath(*pContext, kCGPathStroke);
}

#pragma mark - Draw Extra Line
@interface LineUnderNoteView : UIView
@end

@implementation LineUnderNoteView
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    drawLine(&ctx, CGPointMake(0, rect.size.height/2.0), CGPointMake(rect.size.width, rect.size.height/2.0), 0, 0, 0, 1.8);
}
@end

#pragma mark - Alert background
@interface AlertBackground ()
@property(nonatomic, strong) NSString* childClassName;

- (void)handleTapEvent:(UITapGestureRecognizer*)recognizer;
@end

@implementation AlertBackground
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEvent:)];
        recognizer.delegate = self;
        recognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)handleTapEvent:(UITapGestureRecognizer *)recognizer
{
    [self removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //NSLog(@"%@", NSStringFromClass([touch.view class]));
    /*For example if user click the tableViewCell, AlertBackground should not capture the touch event, otherwise the cell of tableView won't response the click event.
     */
    if ([NSStringFromClass([touch.view class]) isEqualToString:self.childClassName]) {
        return YES;
    } else {
        return NO;
    }
}
@end

#pragma mark - Draw CirCular On Navigation/On Popup View
@interface CirCularOnNavigation ()
@property(nonatomic, strong) NSMutableArray* signatureViewArray;
@property(nonatomic, strong) NSMutableArray* signatureImageArray;
@property(nonatomic, strong) NSMutableArray* selectorStatusArray;
@property(nonatomic, strong) NSMutableDictionary* gestureIndexDict;
@property(nonatomic, weak) NSMutableSet* signatureIndexSet;

- (void)handleTapEvent:(UITapGestureRecognizer*)recognizer;
- (void)updateSigViewOnPopupView:(BOOL)bOnPopupView SignatureSet:(NSMutableSet*)signatureSet;
@end

@implementation CirCularOnNavigation
- (id)initWithFrame:(CGRect)frame OnPopupView:(BOOL)bOnPopupView SignatureSet:(NSMutableSet *)signatureSet
{
    self = [super initWithFrame:frame];
    if (self) {
        self.signatureIndexSet = signatureSet;
        self.signatureViewArray = [[NSMutableArray alloc] initWithCapacity:15];     //15 signatures
        if (bOnPopupView)
        {
            self.signatureImageArray = [[NSMutableArray alloc] initWithCapacity:15];
            self.selectorStatusArray = [[NSMutableArray alloc] initWithCapacity:15];
            self.gestureIndexDict = [[NSMutableDictionary alloc] initWithCapacity:15];
        }
        CGFloat sig_circular_radius = frame.size.width/2.0*CIRCULAR_RADIUS_SCALE+SIG_VIEW_BOUNDS_DISTANCE, sig_image_circular_radius = frame.size.width/2.0*CIRCULAR_RADIUS_SCALE+SIG_VIEW_BOUNDS_DISTANCE+SIG_IMAGE_VIEW_DISTANCE;
        CGFloat virtual_point_x = frame.size.width/2.0;
        CGFloat curr_sig_view_angle = 2*M_PI/15.0/2.0;
        CGFloat each_sig_view_angle = 2*M_PI/15.0;
        for (NSInteger i = 0; i < 15; ++i) {
            CGFloat curr_point_x = virtual_point_x-sig_circular_radius*sin(curr_sig_view_angle),
            curr_point_y = frame.size.height/2.0+sig_circular_radius*cos(curr_sig_view_angle);
            UIImageView* sigView = [[UIImageView alloc] initWithFrame:CGRectMake(curr_point_x-SIG_VIEW_SQUARE_BOUND/2.0, curr_point_y-SIG_VIEW_SQUARE_BOUND/2.0, SIG_VIEW_SQUARE_BOUND, SIG_VIEW_SQUARE_BOUND)];
            sigView.image = [UIImage imageNamed:[NSString stringWithFormat:@"unselected_signature_%d", i]];
            [self addSubview:sigView];
            [self.signatureViewArray addObject:sigView];
            if (bOnPopupView) {
                CGFloat img_curr_point_x = virtual_point_x-sig_image_circular_radius*sin(curr_sig_view_angle), img_curr_point_y = frame.size.height/2.0+sig_image_circular_radius*cos(curr_sig_view_angle);
                UIImageView* sigImageView = [[UIImageView alloc] initWithFrame:CGRectMake(img_curr_point_x-SIG_IMAGE_RECT_WIDTH/2.0, img_curr_point_y-SIG_IMAGE_RECT_HEIGHT/2.0, SIG_IMAGE_RECT_WIDTH, SIG_IMAGE_RECT_HEIGHT)];
                sigImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"unselected_signature_image_%d", i]];
                [self addSubview:sigImageView];
                [self.signatureImageArray addObject:sigImageView];
                if ([self.signatureIndexSet containsObject:[NSNumber numberWithInteger:i]])
                    [self.selectorStatusArray addObject:[NSNumber numberWithBool:YES]];
                else
                    [self.selectorStatusArray addObject:[NSNumber numberWithBool:NO]];
                
                CGFloat cover_view_lx = MIN(curr_point_x-SIG_VIEW_SQUARE_BOUND/2.0, img_curr_point_x-SIG_IMAGE_RECT_WIDTH/2.0), cover_view_uy = MIN(curr_point_y-SIG_VIEW_SQUARE_BOUND/2.0, img_curr_point_y-SIG_IMAGE_RECT_HEIGHT/2.0);
                CGFloat cover_view_rx = MAX(curr_point_x+SIG_VIEW_SQUARE_BOUND/2.0, img_curr_point_x+SIG_IMAGE_RECT_WIDTH/2.0), cover_view_by = MAX(curr_point_y+SIG_VIEW_SQUARE_BOUND/2.0, img_curr_point_y+SIG_IMAGE_RECT_HEIGHT/2.0);
                UIView* touchView = [[UIView alloc] initWithFrame:CGRectMake(cover_view_lx, cover_view_uy, cover_view_rx-cover_view_lx, cover_view_by-cover_view_uy)];
                touchView.backgroundColor = [UIColor clearColor];
                [self addSubview:touchView];
                
                UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEvent:)];
                tapGesture.numberOfTapsRequired = 1;
                [touchView addGestureRecognizer:tapGesture];
                self.gestureIndexDict[[NSValue valueWithNonretainedObject:tapGesture]] = [NSNumber numberWithLong:i];
            }
            curr_sig_view_angle += each_sig_view_angle;
        }
        for (NSNumber* sigIndex in self.signatureIndexSet)
        {
            UIImageView* sigView = self.signatureViewArray[[sigIndex integerValue]];
            sigView.image = [UIImage imageNamed:[NSString stringWithFormat: @"selected_signature_%d", [sigIndex integerValue]]];
            if (bOnPopupView) {
                UIImageView* sigImageView = self.signatureImageArray[[sigIndex integerValue]];
                sigImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"selected_signature_image_%d", [sigIndex integerValue]]];
            }
        }
    }
    return self;
}

- (void)updateSigViewOnPopupView:(BOOL)bOnPopupView SignatureSet:(NSMutableSet *)signatureSet
{
    for (NSInteger i = 0; i < 15; ++i) {
        if ([signatureSet containsObject:[NSNumber numberWithInteger:i]]) {
            UIImageView* sigView = self.signatureViewArray[i];
            sigView.image = [UIImage imageNamed:[NSString stringWithFormat:@"selected_signature_%d", i]];
            if (bOnPopupView)
            {
                UIImageView* sigImageView = self.signatureImageArray[i];
                sigImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"selected_signature_image_%d", i]];
            }
        } else {
            UIImageView* sigView = self.signatureViewArray[i];
            sigView.image = [UIImage imageNamed:[NSString stringWithFormat:@"unselected_signature_%d", i]];
            if (bOnPopupView)
            {
                UIImageView* sigImageView = self.signatureImageArray[i];
                sigImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"unselected_signature_image_%d", i]];
            }
        }
    }
}

- (void)handleTapEvent:(UITapGestureRecognizer *)recognizer
{
    NSInteger tapIndex = [(NSNumber*)self.gestureIndexDict[[NSValue valueWithNonretainedObject:recognizer]] intValue];
    if (1 == [self.signatureIndexSet count] && [self.signatureIndexSet containsObject:[NSNumber numberWithInteger:tapIndex]])
        return;
    
    NSNumber* nSelect = self.selectorStatusArray[tapIndex];
    UIImageView* sigView = self.signatureViewArray[tapIndex];
    UIImageView* sigImageView = self.signatureImageArray[tapIndex];
    if ([nSelect boolValue]) {
        sigView.image = [UIImage imageNamed:[NSString stringWithFormat:@"unselected_signature_%d", tapIndex]];
        sigImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"unselected_signature_image_%d", tapIndex]];
        [self.selectorStatusArray replaceObjectAtIndex:tapIndex withObject:[NSNumber numberWithBool:NO]];
        [self.signatureIndexSet removeObject:[NSNumber numberWithInteger:tapIndex]];
    } else {
        sigView.image = [UIImage imageNamed:[NSString stringWithFormat:@"selected_signature_%d", tapIndex]];
        sigImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"selected_signature_image_%d", tapIndex]];
        [self.selectorStatusArray replaceObjectAtIndex:tapIndex withObject:[NSNumber numberWithBool:YES]];
        [self.signatureIndexSet addObject:[NSNumber numberWithInteger:tapIndex]];
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    drawCircular(&context, rect);
}
@end

#pragma mark - Select Signature Popup View
@interface SignatureSelector ()
@property(nonatomic, strong) NSMutableSet* selectAllSigSet;
@property(nonatomic, strong) CirCularOnNavigation* popupSignatureView;
@property(nonatomic, assign) BOOL bSelectAll;

- (void)selectAllSignature;
- (void)finishSelect;
@end

@implementation SignatureSelector
- (id)initWithFrame:(CGRect)frame SignatureSet:(NSMutableSet *)signatureSet
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.childClassName = @"SignatureSelector";
        CGFloat popupViewRadius = [UIScreen mainScreen].bounds.size.height/2.0*POPUP_SELECTOR_RADIUS_SCALE;
        CGFloat center_x = [UIScreen mainScreen].bounds.size.width/2.0, center_y = [UIScreen mainScreen].bounds.size.height/2.0;
        UIView* circularView = [[UIView alloc] initWithFrame:CGRectMake(center_x-popupViewRadius, center_y-popupViewRadius, popupViewRadius*2.0, popupViewRadius*2.0)];
        circularView.backgroundColor = [UIColor whiteColor];
        circularView.layer.cornerRadius = popupViewRadius;
        [self addSubview:circularView];
        
        self.popupSignatureView = [[CirCularOnNavigation alloc] initWithFrame:CGRectMake(0, 0, popupViewRadius*2.0, popupViewRadius*2.0) OnPopupView:YES SignatureSet:signatureSet];
        self.popupSignatureView.backgroundColor = [UIColor clearColor];
        [circularView addSubview:self.popupSignatureView];
        
        UIButton* selectAllBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        selectAllBtn.frame = CGRectMake(center_x-NAVIGATION_SIGNATURE_WIDTH/2.0, center_y-NAVIGATION_SIGNATURE_HEIGHT/2.0-36, NAVIGATION_SIGNATURE_WIDTH, NAVIGATION_SIGNATURE_HEIGHT);
        [selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
        selectAllBtn.titleLabel.font = [UIFont systemFontOfSize:24];
        [selectAllBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectAllBtn.layer.cornerRadius = 5;
        selectAllBtn.backgroundColor = [UIColor colorWithRed:(0x00)/255.0 green:(0x88)/255.0 blue:(0xff)/255.0 alpha:1.0];
        [selectAllBtn addTarget:self action:@selector(selectAllSignature) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:selectAllBtn];
        
        UIButton* finishBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        finishBtn.frame = CGRectMake(center_x-NAVIGATION_SIGNATURE_WIDTH/2.0, center_y-NAVIGATION_SIGNATURE_HEIGHT/2.0+36, NAVIGATION_SIGNATURE_WIDTH, NAVIGATION_SIGNATURE_HEIGHT);
        [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        finishBtn.titleLabel.font = [UIFont systemFontOfSize:24];
        [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        finishBtn.layer.cornerRadius = 5;
        finishBtn.backgroundColor = [UIColor colorWithRed:(0x00)/255.0 green:(0x88)/255.0 blue:(0xff)/255.0 alpha:1.0];
        [finishBtn addTarget:self action:@selector(finishSelect) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:finishBtn];
        
        self.selectAllSigSet = [[NSMutableSet alloc] init];
        for (NSInteger i = 0; i < 15; ++i)
            [self.selectAllSigSet addObject:[NSNumber numberWithInteger:i]];
    }
    return self;
}

- (void)selectAllSignature
{
    if (self.bSelectAll) {
        self.bSelectAll = NO;
        [self.popupSignatureView updateSigViewOnPopupView:YES SignatureSet:self.circularDelegate.signatureIndexSet];
    } else {
        self.bSelectAll = YES;
        [self.popupSignatureView updateSigViewOnPopupView:YES SignatureSet:self.selectAllSigSet];
    }
}

- (void)finishSelect
{
    if (self.bSelectAll)
        [self.circularDelegate.signatureIndexSet setSet:self.selectAllSigSet];
    [self.circularDelegate updateSigViewOnPopupView:NO SignatureSet:self.circularDelegate.signatureIndexSet];
    [super removeFromSuperview];
}

- (void)handleTapEvent:(UITapGestureRecognizer *)recognizer
{
    [self finishSelect];
}
@end

#pragma mark - Draw Gray Vertical Bar On Navigation
@interface DrawGrayVerticalBar ()
@end

@implementation DrawGrayVerticalBar
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    drawLine(&context, CGPointMake(rect.size.width/2.0, rect.size.height*(1-GRAY_VERTICAL_BAR_SCALE)/2.0), CGPointMake(rect.size.width/2.0, rect.size.height*(1+GRAY_VERTICAL_BAR_SCALE)/2.0), (0x76)/255.0, (0x76)/255.0, (0x76)/255.0, 1.0);
}
@end

#pragma mark - Draw Red Horizontal Bar Upon Keyboard
@interface DrawRedHorizontalBar : UIView
@end

@implementation DrawRedHorizontalBar
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    drawLine(&context, CGPointMake(0, rect.size.height/2.0), CGPointMake(rect.size.width, rect.size.height/2.0), 1.0, 0.0, 0.0, rect.size.height);
}
@end

#pragma mark - Note Object On Staff Including Under Line And Flag(Optional, Required For Pressed Note)
@interface DrawNoteOnStaff ()
@end

@implementation DrawNoteOnStaff
- (id)init
{
    self = [super init];
    if (self) {
        self.noteImageView = [[UIImageView alloc] init];
        self.flagImageView = [[UIImageView alloc] init];
        self.noteUnderLineArray = [[NSMutableArray alloc] init];
    }
    return self;
}
@end

#pragma mark - Draw Staff On View
@interface DrawStaff ()
@property(nonatomic, assign) BOOL bMiddleCNoteBottom;
@property(nonatomic, assign) unsigned char base_octave;
@property(nonatomic, assign) CGFloat base_line_y_offset, note_x;
@property(nonatomic, assign) NSInteger staff_start_x, staff_width;
@property(nonatomic, assign) MusicClefType clef_type;
@property(nonatomic, strong) NSMutableArray* signatureViewArray;
@property(nonatomic, strong) NSMutableArray* selectedNoteArray;
@property(nonatomic, strong) NSMutableDictionary* pressedNoteDict; //key: note_value, value: DrawNoteOnStaff*

- (void)drawSingleStaff:(CGRect)rect ContextRef:(CGContextRef*)pCtx IsTrebleStaff:(BOOL)bTrebleStaff;
- (void)drawDoubleStaff:(CGRect)rect ContextRef:(CGContextRef*)pCtx;
- (BOOL)drawDownMajor:(MusicSignatureType)downType startX:(CGFloat)first_note_start_x startY:(CGFloat)first_note_start_y;
- (BOOL)drawUpMajor:(MusicSignatureType)upType startX:(CGFloat)first_note_start_x startY:(CGFloat)first_note_start_y;
- (void)drawSignature:(MusicSignatureType)type;
- (void)addExtraLineOnNote:(NSInteger)nNoteVirtualValue NoteViewX:(CGFloat)nNoteViewX AddLineIntoArray:(DrawNoteOnStaff*)noteArray;
- (void)eraseAllStaffView;
@end

@implementation DrawStaff
- (void)drawRect:(CGRect)rect
{
    /*Get graphics context associated with current view, here the context is the Layer which is the super class of UIView
     */
    self.staff_start_x = rect.origin.x+MARGIN_LEFT;
    self.staff_width = (rect.size.width-MARGIN_RIGHT)-self.staff_start_x;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    switch (self.clef_type) {
        case MUSIC_TREBLE_CLEF:
            [self drawSingleStaff:rect ContextRef:&ctx IsTrebleStaff:YES];
            break;
            
        case MUSIC_BASS_CLEF:
            [self drawSingleStaff:rect ContextRef:&ctx IsTrebleStaff:NO];
            break;
            
        case MUSIC_TREBLE_AND_BASS_CLEF:
            [self drawDoubleStaff:rect ContextRef:&ctx];
            break;
            
        default:
            NSLog(@"Unknown clef, don't draw any staff");
            break;
    }
    if (!self.signatureViewArray)
        self.signatureViewArray = [[NSMutableArray alloc] init];
    if (!self.selectedNoteArray)
        self.selectedNoteArray = [[NSMutableArray alloc] init];
    if (!self.pressedNoteDict)
        self.pressedNoteDict = [[NSMutableDictionary alloc] init];
}

- (void)drawSingleStaff:(CGRect)rect ContextRef:(CGContextRef *)pCtx IsTrebleStaff:(BOOL)bTrebleStaff
{
    //draw one group of five line
    CGFloat start_x = rect.origin.x+MARGIN_LEFT;
    CGFloat end_x = rect.size.width-MARGIN_RIGHT;
    CGFloat first_y = rect.size.height/2.0+2.0*LINE_DISTANCE;
    for (int i = 0; i < 5; ++i) {
        CGFloat current_y = first_y-i*LINE_DISTANCE;
        CGPoint StartPoint = CGPointMake(start_x, current_y);
        CGPoint EndPoint = CGPointMake(end_x, current_y);
        drawLine(pCtx, StartPoint, EndPoint, 0, 0, 0, 1.8);
    }
    drawLine(pCtx, CGPointMake(start_x, first_y), CGPointMake(start_x, first_y-4.0*LINE_DISTANCE), 0, 0, 0, 1.8);
    drawLine(pCtx, CGPointMake(end_x, first_y), CGPointMake(end_x, first_y-4.0*LINE_DISTANCE), 0, 0, 0, 1.8);
    
    if (bTrebleStaff) {
        self.base_octave = 4;
        UIImageView* trebleView = [[UIImageView alloc] initWithFrame:CGRectMake(start_x+20, first_y-4.0*LINE_DISTANCE-LINE_DISTANCE*1.6, 54, 134)];
        trebleView.image = [UIImage imageNamed:@"clef_treble@2x.png"];
        [self addSubview:trebleView];
        self.base_line_y_offset = first_y+2.5*LINE_DISTANCE;
    } else {    //bass staff
        self.base_octave = 2;
        UIImageView* bassView = [[UIImageView alloc] initWithFrame:CGRectMake(start_x+20, first_y-4.0*LINE_DISTANCE, 54, 64)];
        bassView.image = [UIImage imageNamed:@"clef_base@2x.png"];
        [self addSubview:bassView];
        self.base_line_y_offset = first_y+2.0*LINE_DISTANCE;
    }
}

- (void)drawDoubleStaff:(CGRect)rect ContextRef:(CGContextRef *)pCtx
{
    //draw two groups of five line
    CGFloat start_x = rect.origin.x+MARGIN_LEFT;
    CGFloat end_x = rect.size.width-MARGIN_RIGHT;
    CGFloat first_y = rect.size.height/2.0+STAFF_DISTANCE/2.0+4.0*LINE_DISTANCE;
    for (int i = 0; i < 2; ++i) {
        CGFloat tmp_y = (0 == i) ? (first_y) : (first_y-4.0*LINE_DISTANCE-STAFF_DISTANCE);
        for (int j = 0; j < 5; ++j) {
            CGFloat current_y = tmp_y-j*LINE_DISTANCE;
            CGPoint StartPoint = CGPointMake(start_x, current_y);
            CGPoint EndPoint = CGPointMake(end_x, current_y);
            drawLine(pCtx, StartPoint, EndPoint, 0, 0, 0, 1.8);
        }
    }
    drawLine(pCtx, CGPointMake(start_x, first_y), CGPointMake(start_x, first_y-8.0*LINE_DISTANCE-STAFF_DISTANCE), 0, 0, 0, 1.8);
    drawLine(pCtx, CGPointMake(end_x, first_y), CGPointMake(end_x, first_y-8.0*LINE_DISTANCE-STAFF_DISTANCE), 0, 0, 0, 1.8);
    UIImageView* clefView = [[UIImageView alloc] initWithFrame:CGRectMake(start_x+20, first_y-8.0*LINE_DISTANCE-STAFF_DISTANCE-LINE_DISTANCE*1.6, 54, 134)];     //treble view
    clefView.image = [UIImage imageNamed:@"clef_treble@2x.png"];
    [self addSubview:clefView];
    clefView = [[UIImageView alloc] initWithFrame:CGRectMake(start_x+20, first_y-4.0*LINE_DISTANCE, 54, 64)];      //bass view
    clefView.image = [UIImage imageNamed:@"clef_base@2x.png"];
    [self addSubview:clefView];
    clefView = [[UIImageView alloc] initWithFrame:CGRectMake(start_x-30, rect.size.height/2.0-STAFF_DISTANCE/2.0-4.0*LINE_DISTANCE-1, 18, STAFF_DISTANCE+8.0*LINE_DISTANCE+2)];
    clefView.image = [UIImage imageNamed:@"group.png"];
    [self addSubview:clefView];
    self.base_octave = 2;
    self.base_line_y_offset = first_y+2.0*LINE_DISTANCE;
}

- (BOOL)drawDownMajor:(MusicSignatureType)downType startX:(CGFloat)first_note_start_x startY:(CGFloat)first_note_start_y
{
    NSInteger group_note_num = 0, group_note_x_dis = 30;
    CGFloat group_start_x = 0, group_start_y = 0;
    for (NSInteger i = 0; i < 2; ++i) {
        switch (downType) {
            case MUSIC_DOWN_C_MAJOR:
                if (0 == i) {
                    group_note_num = 3;
                } else {    //1 == i
                    group_note_num = 4;
                }
                break;
                
            case MUSIC_DOWN_G_MAJOR:
                group_note_num = 3;
                break;
                
            case MUSIC_DOWN_D_MAJOR:
                if (0 == i) {
                    group_note_num = 2;
                } else {
                    group_note_num = 3;
                }
                break;
                
            case MUSIC_DOWN_A_MAJOR:
                group_note_num = 2;
                break;
                
            case MUSIC_DOWN_E_MAJOR:
                if (0 == i) {
                    group_note_num = 1;
                } else {
                    group_note_num = 2;
                }
                break;
                
            case MUSIC_DOWN_B_MAJOR:
                group_note_num = 1;
                break;
                
            case MUSIC_F_MAJOR:
                if (0 == i) {
                    group_note_num = 0;
                } else {
                    group_note_num = 1;
                }
                break;
                
            default:
            {
                NSLog(@"The signature type is not down type, draw failed!");
                return NO;
            }
        }
        if (0 == i) {
            group_start_x = first_note_start_x+group_note_x_dis/2.0;
            group_start_y = first_note_start_y-1.5*LINE_DISTANCE;
        } else if (1 == i) {
            group_start_x = first_note_start_x;
            group_start_y = first_note_start_y;
        }
        for (NSInteger j = 0; j < group_note_num; ++j) {
            UIImageView* downSigView = [[UIImageView alloc] initWithFrame:CGRectMake(group_start_x+j*group_note_x_dis, group_start_y+j*0.5*LINE_DISTANCE, 16, 44)];
            downSigView.image = [UIImage imageNamed:@"flag_flat@2x.png"];
            [self addSubview:downSigView];
            [self.signatureViewArray addObject:downSigView];
        }
    }
    return YES;
}

- (BOOL)drawUpMajor:(MusicSignatureType)upType startX:(CGFloat)first_note_start_x startY:(CGFloat)first_note_start_y
{
    NSInteger group_note_num = 0, group_note_x_dis = 36;
    CGFloat group_start_x = 0, group_start_y = 0;
    for (NSInteger i = 0; i < 3; ++i) {
        switch (upType) {
            case MUSIC_G_MAJOR:
                if (0 == i) {
                    group_note_num = 1;
                } else {
                    group_note_num = 0;
                }
                break;
                
            case MUSIC_D_MAJOR:
                if (2 != i) {
                    group_note_num = 1;
                } else {
                    group_note_num = 0;
                }
                break;
                
            case MUSIC_A_MAJOR:
                if (0 == i) {
                    group_note_num = 2;
                } else if (1 == i) {
                    group_note_num = 1;
                } else {
                    group_note_num = 0;
                }
                break;
                
            case MUSIC_E_MAJOR:
                if (2 != i) {
                    group_note_num = 2;
                } else {
                    group_note_num = 0;
                }
                break;
                
            case MUSIC_B_MAJOR:
                if (2 != i) {
                    group_note_num = 2;
                } else {
                    group_note_num = 1;
                }
                break;
                
            case MUSIC_UP_F_MAJOR:
                if (0 == i) {
                    group_note_num = 2;
                } else if (1 == i) {
                    group_note_num = 3;
                } else {
                    group_note_num = 1;
                }
                break;
                
            case MUSIC_UP_C_MAJOR:
                if (1 != i) {
                    group_note_num = 2;
                } else {
                    group_note_num = 3;
                }
                break;
                
            default:
            {
                NSLog(@"The signature type is not up type, draw failed!");
                return NO;
            }
        }
        if (0 == i) {
            group_start_x = first_note_start_x;
            group_start_y = first_note_start_y;
        } else if (1 == i) {
            group_start_x = first_note_start_x+group_note_x_dis/2.0;
            group_start_y = first_note_start_y+1.5*LINE_DISTANCE;
        } else {
            group_start_x = first_note_start_x+group_note_x_dis*2.0;
            group_start_y = first_note_start_y+2.5*LINE_DISTANCE;
        }
        for (NSInteger j = 0; j < group_note_num; ++j) {
            UIImageView* upSigView = [[UIImageView alloc] initWithFrame:CGRectMake(group_start_x+j*group_note_x_dis, group_start_y-j*0.5*LINE_DISTANCE, 18, 44)];
            upSigView.image = [UIImage imageNamed:@"flag_sharp@2x.png"];
            [self addSubview:upSigView];
            [self.signatureViewArray addObject:upSigView];
        }
    }
    return YES;
}

- (void)drawSignature:(MusicSignatureType)type
{
    CGFloat base_start_x = 108;
    switch (type) {
        case MUSIC_DOWN_C_MAJOR:
        case MUSIC_DOWN_G_MAJOR:
        case MUSIC_DOWN_D_MAJOR:
        case MUSIC_DOWN_A_MAJOR:
        case MUSIC_DOWN_E_MAJOR:
        case MUSIC_DOWN_B_MAJOR:
        case MUSIC_F_MAJOR:
        {
            CGFloat treble_base_start_y = self.base_line_y_offset-STAFF_DISTANCE-9.9*LINE_DISTANCE;
            CGFloat bass_base_start_y = treble_base_start_y+5.0*LINE_DISTANCE+STAFF_DISTANCE;
            if (MUSIC_TREBLE_CLEF == self.clef_type) {
                [self drawDownMajor:type startX:base_start_x startY:treble_base_start_y+6.9*LINE_DISTANCE+STAFF_DISTANCE/2.0];
            } else if (MUSIC_BASS_CLEF == self.clef_type) {
                [self drawDownMajor:type startX:base_start_x startY:bass_base_start_y+1.8*LINE_DISTANCE-STAFF_DISTANCE/2.0];
            } else {    //MUSIC_TREBLE_AND_BASS_CLEF == self.clef_type
                [self drawDownMajor:type startX:base_start_x startY:treble_base_start_y];
                [self drawDownMajor:type startX:base_start_x startY:bass_base_start_y];
            }
            break;
        }
            
        case MUSIC_G_MAJOR:
        case MUSIC_D_MAJOR:
        case MUSIC_A_MAJOR:
        case MUSIC_E_MAJOR:
        case MUSIC_B_MAJOR:
        case MUSIC_UP_F_MAJOR:
        case MUSIC_UP_C_MAJOR:
        {
            CGFloat treble_base_start_y = self.base_line_y_offset-STAFF_DISTANCE-11.3*LINE_DISTANCE;
            CGFloat bass_base_start_y = treble_base_start_y+5.0*LINE_DISTANCE+STAFF_DISTANCE;
            if (MUSIC_TREBLE_CLEF == self.clef_type) {
                [self drawUpMajor:type startX:base_start_x startY:treble_base_start_y+5.3*LINE_DISTANCE+STAFF_DISTANCE/2.0];
            } else if (MUSIC_BASS_CLEF == self.clef_type) {
                [self drawUpMajor:type startX:base_start_x startY:bass_base_start_y+1.8*LINE_DISTANCE-STAFF_DISTANCE/2.0];
            } else {
                [self drawUpMajor:type startX:base_start_x startY:treble_base_start_y];
                [self drawUpMajor:type startX:base_start_x startY:bass_base_start_y];
            }
            break;
        }
            
        default:
            break;
    }
}

- (void)fixNoteXOrder
{
    NSInteger display_start = self.staff_start_x+self.staff_width*DISPLAY_START_SCALE;
    NSInteger display_end = self.staff_start_x+self.staff_width*DISPLAY_STOP_SCALE;
    self.note_x = display_start+arc4random()%(display_end-display_start);
}

- (void)drawSelectedNote:(NSInteger)note_octave stepWithAlter:(NSInteger)oct_internal_index shouldMoveRight:(BOOL)bShouldMoveRight
{
    CGFloat group_height = 3.5*LINE_DISTANCE;
    NSInteger nNoteVirtualValue = note_octave*7+oct_internal_index;
    CGFloat note_y = self.base_line_y_offset-(note_octave-self.base_octave)*group_height-LINE_DISTANCE/2.0*oct_internal_index;
    if (note_octave >= 4) {
        note_y -= STAFF_DISTANCE-2.0*LINE_DISTANCE;
    }
    self.bMiddleCNoteBottom = arc4random()%2;
    if (nNoteVirtualValue == MIDDLE_NOTE_VIRTUAL_VALUE && self.bMiddleCNoteBottom) {
        note_y += STAFF_DISTANCE-2.0*LINE_DISTANCE;
    }
    
    DrawNoteOnStaff* selectedNote = [[DrawNoteOnStaff alloc] init];
    CGFloat nNoteViewX = self.note_x-WHOLE_NOTE_WIDTH/2.0, nNoteViewY = note_y-WHOLE_NOTE_HEIGHT/2.0;
    if (bShouldMoveRight)
        nNoteViewX += WHOLE_NOTE_WIDTH;
    UIImageView* noteView = [[UIImageView alloc] initWithFrame:CGRectMake(nNoteViewX, nNoteViewY, WHOLE_NOTE_WIDTH, WHOLE_NOTE_HEIGHT)];
    noteView.image = [UIImage imageNamed:@"note_2@2x.png"];
    [self addSubview:noteView];
    selectedNote.noteImageView = noteView;
    [self addExtraLineOnNote:nNoteVirtualValue NoteViewX:nNoteViewX AddLineIntoArray:selectedNote];
    [self.selectedNoteArray addObject:selectedNote];
}

- (void)addExtraLineOnNote:(NSInteger)nNoteVirtualValue NoteViewX:(CGFloat)nNoteViewX AddLineIntoArray:(DrawNoteOnStaff *)noteArray
{
    CGFloat extra_line_y = 0;
    if (nNoteVirtualValue < BOTTOM_NOTE_VIRTUAL_VALUE) {
        extra_line_y = self.base_line_y_offset-1.0*LINE_DISTANCE-WHOLE_NOTE_HEIGHT/2.0;
        while (nNoteVirtualValue < BOTTOM_NOTE_VIRTUAL_VALUE) {
            LineUnderNoteView* noteLine = [[LineUnderNoteView alloc] initWithFrame:CGRectMake(nNoteViewX-3, extra_line_y, WHOLE_NOTE_WIDTH+6, WHOLE_NOTE_HEIGHT)];
            noteLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
            [self addSubview:noteLine];
            [noteArray.noteUnderLineArray addObject:noteLine];
            extra_line_y += LINE_DISTANCE;
            nNoteVirtualValue += 2;
        }
    }
    
    if (nNoteVirtualValue == MIDDLE_NOTE_VIRTUAL_VALUE) {
        if (MUSIC_TREBLE_CLEF == self.clef_type) {
            extra_line_y = self.base_line_y_offset-1.55*LINE_DISTANCE-WHOLE_NOTE_HEIGHT/2.0;
        } else if (MUSIC_BASS_CLEF == self.clef_type) {
            extra_line_y = self.base_line_y_offset-3.45*LINE_DISTANCE-STAFF_DISTANCE-WHOLE_NOTE_HEIGHT/2.0;
        } else {    //MUSIC_TREBLE_AND_BASS_CLEF == self.clef_type
            extra_line_y = (self.bMiddleCNoteBottom) ? (self.base_line_y_offset-7.0*LINE_DISTANCE-WHOLE_NOTE_HEIGHT/2.0) : (self.base_line_y_offset-5.0*LINE_DISTANCE-STAFF_DISTANCE-WHOLE_NOTE_HEIGHT/2.0);
        }
        LineUnderNoteView* noteLine = [[LineUnderNoteView alloc] initWithFrame:CGRectMake(nNoteViewX-3, extra_line_y, WHOLE_NOTE_WIDTH+6, WHOLE_NOTE_HEIGHT)];
        noteLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        [self addSubview:noteLine];
        [noteArray.noteUnderLineArray addObject:noteLine];
    }
    
    if (nNoteVirtualValue > TOP_NOTE_VIRTUAL_VALUE) {
        if (MUSIC_TREBLE_AND_BASS_CLEF == self.clef_type) {
            extra_line_y = self.base_line_y_offset-11.0*LINE_DISTANCE-STAFF_DISTANCE-WHOLE_NOTE_HEIGHT/2.0;;
        } else {
            extra_line_y = self.base_line_y_offset-4.0*LINE_DISTANCE-STAFF_DISTANCE-WHOLE_NOTE_HEIGHT/2.0;;
        }
        while (nNoteVirtualValue > TOP_NOTE_VIRTUAL_VALUE) {
            LineUnderNoteView* noteLine = [[LineUnderNoteView alloc] initWithFrame:CGRectMake(nNoteViewX-3, extra_line_y, WHOLE_NOTE_WIDTH+6, WHOLE_NOTE_HEIGHT)];
            noteLine.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
            [self addSubview:noteLine];
            [noteArray.noteUnderLineArray addObject:noteLine];
            extra_line_y -= LINE_DISTANCE;
            nNoteVirtualValue -= 2;
        }
    }
}

- (void)eraseAllStaffView
{
    if (self.signatureViewArray)
    {
        for (UIImageView* sigView in self.signatureViewArray)
            [sigView removeFromSuperview];
        [self.signatureViewArray removeAllObjects];
    }
    if (self.selectedNoteArray)
    {
        for (DrawNoteOnStaff* selectedNote in self.selectedNoteArray)
        {
            [selectedNote.noteImageView removeFromSuperview];
            for (LineUnderNoteView* underLine in selectedNote.noteUnderLineArray)
                [underLine removeFromSuperview];
            [selectedNote.noteUnderLineArray removeAllObjects];
        }
        [self.selectedNoteArray removeAllObjects];
    }
    if (self.pressedNoteDict)
    {
        for (DrawNoteOnStaff* pressedNote in [self.pressedNoteDict allValues])
        {
            [pressedNote.noteImageView removeFromSuperview];
            [pressedNote.flagImageView removeFromSuperview];
            for (LineUnderNoteView* underLine in pressedNote.noteUnderLineArray)
                [underLine removeFromSuperview];
            [pressedNote.noteUnderLineArray removeAllObjects];
        }
        [self.pressedNoteDict removeAllObjects];
    }
}

- (void)clearPressedNote:(NSInteger)nNoteValue
{
    NSNumber* key = [NSNumber numberWithInteger:nNoteValue];
    DrawNoteOnStaff* pressedNote = self.pressedNoteDict[key];
    if (pressedNote)
    {
        [pressedNote.noteImageView removeFromSuperview];
        [pressedNote.flagImageView removeFromSuperview];
        for (LineUnderNoteView* underLine in pressedNote.noteUnderLineArray)
            [underLine removeFromSuperview];
        [pressedNote.noteUnderLineArray removeAllObjects];
        [self.pressedNoteDict removeObjectForKey:key];
    }
}

- (void)showPressedNote:(NSInteger)nNoteValue signatureType:(MusicSignatureType)type
{
    NSInteger note_octave = nNoteValue/12-1, note_remainder = nNoteValue%12, group_index = 0;
    CGFloat group_height = 3.5*LINE_DISTANCE;
    CGFloat note_y = self.base_line_y_offset-(note_octave-self.base_octave)*group_height;
    NoteMark mark = MUSIC_NONE;
    switch (type) {
        case MUSIC_DOWN_C_MAJOR:
        case MUSIC_DOWN_G_MAJOR:
        case MUSIC_DOWN_D_MAJOR:
        case MUSIC_DOWN_A_MAJOR:
        case MUSIC_DOWN_E_MAJOR:
        case MUSIC_DOWN_B_MAJOR:
        case MUSIC_F_MAJOR:
        {
            if (note_remainder <= 5) {
                group_index = (note_remainder+1)/2.0;
            } else {
                group_index = (note_remainder+2)/2.0;
            }
            if (note_remainder > scales_map[type][group_index]) {
                mark = MUSIC_RESTORE_MARK;
            } else if (note_remainder < scales_map[type][group_index]) {
                mark = MUSIC_FLAT_MARK;
            }
            break;
        }
            
        case MUSIC_C_MAJOR:
        case MUSIC_G_MAJOR:
        case MUSIC_D_MAJOR:
        case MUSIC_A_MAJOR:
        case MUSIC_E_MAJOR:
        case MUSIC_B_MAJOR:
        case MUSIC_UP_F_MAJOR:
        case MUSIC_UP_C_MAJOR:
        {
            if (note_remainder <= 4) {
                group_index = note_remainder/2.0;
            } else {
                group_index = (note_remainder+1)/2.0;
            }
            if (note_remainder < scales_map[type][group_index]) {
                mark = MUSIC_RESTORE_MARK;
            } else if (note_remainder > scales_map[type][group_index]) {
                mark = MUSIC_SHARP_MARK;
            }
            break;
        }
            
        default:
            break;
    }
    
    if (nNoteValue >= 60)
    {
        if (note_octave == 4 && group_index == 0) {
            if (MUSIC_TREBLE_CLEF == self.clef_type) {
                note_y -= STAFF_DISTANCE-2.0*LINE_DISTANCE;
            } else if (MUSIC_BASS_CLEF == self.clef_type) {
                ;
            } else {    //MUSIC_TREBLE_AND_BASS_CLEF == self.clef_type
                note_y -= (self.bMiddleCNoteBottom ? 0 : STAFF_DISTANCE-2.0*LINE_DISTANCE);
            }
        } else {
            note_y -= (STAFF_DISTANCE-2.0*LINE_DISTANCE);
        }
    }
    
    NSString* pressNoteImageName = [[NSString alloc] init];
    CGFloat nImageWidth = 0, nImageHeight = 0;
    switch (mark) {
        case MUSIC_RESTORE_MARK:
            pressNoteImageName = @"flag_stop@2x.png";
            nImageWidth = STOP_FLAG_WIDTH;
            nImageHeight = STOP_FLAG_HEIGHT;
            break;
        case MUSIC_FLAT_MARK:
            pressNoteImageName = @"flag_flat@2x.png";
            nImageWidth = FLAT_FLAG_WIDTH;
            nImageHeight = FLAT_FLAG_HEIGHT;
            break;
        case MUSIC_SHARP_MARK:
            pressNoteImageName = @"flag_sharp@2x.png";
            nImageWidth = SHARP_FLAG_WIDTH;
            nImageHeight = SHARP_FLAG_HEIGHT;
            break;
            
        default:
            break;
    }
    note_y -= group_index*LINE_DISTANCE/2.0;
    CGFloat nNoteViewX = self.note_x+SELECT_AND_PRESS_NOTE_DIS-WHOLE_NOTE_WIDTH/2.0;
    CGFloat nNoteViewY = note_y-WHOLE_NOTE_HEIGHT/2.0;
    CGFloat nFlagViewX = nNoteViewX-FLAG_NOTE_DISTANCE-nImageWidth;
    CGFloat nFlagViewY = note_y-nImageHeight/2.0;
    if (MUSIC_FLAT_MARK == mark)
        nFlagViewY -= 0.5*LINE_DISTANCE;
    DrawNoteOnStaff* pressedNote = [[DrawNoteOnStaff alloc] init];
    UIImageView* pressNoteView = [[UIImageView alloc] initWithFrame:CGRectMake(nNoteViewX, nNoteViewY, WHOLE_NOTE_WIDTH, WHOLE_NOTE_HEIGHT)];
    pressNoteView.image = [UIImage imageNamed:@"note_2@2x.png"];
    [self addSubview:pressNoteView];
    pressedNote.noteImageView = pressNoteView;
    UIImageView* flagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(nFlagViewX, nFlagViewY, nImageWidth, nImageHeight)];
    flagImageView.image = [UIImage imageNamed:pressNoteImageName];
    [self addSubview:flagImageView];
    pressedNote.flagImageView = flagImageView;
    [self addExtraLineOnNote:note_octave*7+group_index NoteViewX:nNoteViewX AddLineIntoArray:pressedNote];
    [self.pressedNoteDict setObject:pressedNote forKey:[NSNumber numberWithInteger:nNoteValue]];
}
@end

#pragma mark - Draw Piano Key
@interface PianoKey : UIView
@property(nonatomic, assign) KeyType type;
@property(nonatomic, assign) BOOL bHintStatus;
@property(nonatomic, assign) NSInteger keyboard_index;
@property(nonatomic, weak) DrawKeyboard* keyboardDelegate;
@property(nonatomic, strong) UILongPressGestureRecognizer* recognizer;

- (id)initWithFrame:(CGRect)frame KeyType:(KeyType)type KeyboardIndex:(NSInteger)keyboard_index;
- (void)handleTapEvent:(UILongPressGestureRecognizer*)recognizer;
@end

@implementation PianoKey
- (id)initWithFrame:(CGRect)frame KeyType:(KeyType)type KeyboardIndex:(NSInteger)keyboard_index
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type = type;
        self.keyboard_index = keyboard_index;
        if (KEYBOARD_WHITE_KEY == type) {
            self.backgroundColor = [UIColor whiteColor];
            self.layer.borderWidth = 0.5;
            self.layer.borderColor = [[UIColor blackColor] CGColor];
        } else {    //KEYBOARD_BLACK_KEY == type
            self.backgroundColor = [UIColor blackColor];
        }
        self.layer.cornerRadius = KEYBOARD_CORNER_RADIUS;
        self.recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEvent:)];
        self.recognizer.minimumPressDuration = 0;
        self.recognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:self.recognizer];
    }
    return self;
}

- (void)handleTapEvent:(UILongPressGestureRecognizer *)recognizer
{
    NSInteger nNoteValue = (self.keyboardDelegate.keyboard_start_octave+1)*12+self.keyboard_index;
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        [self.keyboardDelegate.pressingNotes addObject:[NSNumber numberWithInteger:self.keyboard_index]];
        if ([self.keyboardDelegate.selectedNotes containsObject:[NSNumber numberWithInteger:self.keyboard_index]])
            self.backgroundColor = [UIColor greenColor];
        else    //not contained in the selected sets
            self.backgroundColor = [UIColor redColor];
        
        [self.keyboardDelegate.drawDelegate showPressedNote:nNoteValue signatureType:self.keyboardDelegate.signatureType];
        [self.keyboardDelegate.midiPlayer startPlayMidNote:(UInt32)nNoteValue velocity:NOTE_VELOCITY channel:0];
        
        if ([self.keyboardDelegate.selectedNotes isEqualToSet:self.keyboardDelegate.pressingNotes])
        {
            [self.keyboardDelegate notifyCompleteOnePractice];
            for (PianoKey* pianoKey in self.keyboardDelegate.pianoKeyArray)
            {
                pianoKey.bHintStatus = NO;
                if (KEYBOARD_WHITE_KEY == pianoKey.type)
                    pianoKey.backgroundColor = [UIColor whiteColor];
                else    //KEYBOARD_BLACK_KEY == pianoKey.type
                    pianoKey.backgroundColor = [UIColor blackColor];
            }
        }
    } else if (UIGestureRecognizerStateEnded == recognizer.state) {
        [self.keyboardDelegate.pressingNotes removeObject:[NSNumber numberWithInteger:self.keyboard_index]];
        if (KEYBOARD_BLACK_KEY == self.type && !self.bHintStatus)
            self.backgroundColor = [UIColor blackColor];
        else if (KEYBOARD_WHITE_KEY == self.type && !self.bHintStatus)
            self.backgroundColor = [UIColor whiteColor];
        
        [self.keyboardDelegate.drawDelegate clearPressedNote:nNoteValue];
        [self.keyboardDelegate.midiPlayer stopPlayMidNote:(UInt32)nNoteValue channel:0];
    }
}
@end

#pragma mark - Draw Keyboard On View
@interface DrawKeyboard ()
{
    NSInteger keyboard_complete_oct, keyboard_remainder_notes;
}
@property(nonatomic, weak) PracticeReadMusic* practiceDelegate;
@property(nonatomic, strong) NSMutableArray* doNoteLabel;
@property(nonatomic, strong) NSMutableArray* doNoteString;

- (void)randSelectNote:(NSInteger)nNoteNum;
- (void)randSelectKeyboardOctave:(MusicSignatureType)type ClefType:(MusicClefType)clef_type;
@end

@implementation DrawKeyboard
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if (WHITE_KEY_NUMBER > 52) {
            NSLog(@"There're a total of 52 white key numbers, set the macro value properly");
            return nil;
        }
        
        NSInteger nRemainderWhiteKey = WHITE_KEY_NUMBER%7;
        keyboard_complete_oct = WHITE_KEY_NUMBER/7;
        keyboard_remainder_notes = nRemainderWhiteKey+((nRemainderWhiteKey < 4) ? (nRemainderWhiteKey-1) : (nRemainderWhiteKey-2));
        self.pianoKeyArray = [[NSMutableArray alloc] initWithCapacity:keyboard_complete_oct*12+keyboard_remainder_notes];
        
        CGFloat white_key_width = frame.size.width/WHITE_KEY_NUMBER;
        CGFloat black_key_width = white_key_width*BLACK_KEY_WIDTH_SCALE;
        CGFloat black_key_height = frame.size.height*BLACK_KEY_HEIGHT_SCALE;

        NSInteger key_index = 0;
        for (NSInteger i = 0; i < WHITE_KEY_NUMBER; ++i)
        {
            //add white key
            PianoKey* pianoKey = [[PianoKey alloc] initWithFrame:CGRectMake(i*white_key_width, 0, white_key_width, frame.size.height) KeyType:KEYBOARD_WHITE_KEY KeyboardIndex:key_index];
            pianoKey.keyboardDelegate = self;
            [self addSubview:pianoKey];
            [self sendSubviewToBack:pianoKey];
            [self.pianoKeyArray addObject:pianoKey];
            key_index++;
            
            //add black key
            if (i%7 != 2 && i%7 != 6 && i != WHITE_KEY_NUMBER-1)
            {
                pianoKey = [[PianoKey alloc] initWithFrame:CGRectMake((i+1)*white_key_width-black_key_width/2.0, 0, black_key_width, black_key_height) KeyType:KEYBOARD_BLACK_KEY KeyboardIndex:key_index];
                pianoKey.keyboardDelegate = self;
                [self addSubview:pianoKey];
                [self.pianoKeyArray addObject:pianoKey];
                key_index++;
            }
        }
        
        NSInteger nDoNoteNum = (keyboard_remainder_notes == 0) ? keyboard_complete_oct : (keyboard_complete_oct+1);
        CGFloat label_start_x_in_key = white_key_width*DO_LABEL_SCALE_IN_KEY;
        CGFloat label_start_y_in_key = frame.size.height*(1-DO_LABEL_SCALE_IN_KEY);
        CGFloat label_width, label_height = label_width = white_key_width*(1-DO_LABEL_SCALE_IN_KEY*2);
        self.doNoteLabel = [[NSMutableArray alloc] initWithCapacity:nDoNoteNum];
        for (NSInteger i = 0; i < nDoNoteNum; ++i) {
            UILabel* doLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*7*white_key_width+label_start_x_in_key, label_start_y_in_key, label_width, label_height)];
            [self addSubview:doLabel];
            [self.doNoteLabel addObject:doLabel];
        }
        self.doNoteString = [[NSMutableArray alloc] initWithObjects:@"C", @"c", @"c1", @"c2", @"c3", nil];
        self.selectedNotes = [[NSMutableSet alloc] init];
        self.pressingNotes = [[NSMutableSet alloc] init];
        self.multipleTouchEnabled = YES;
        self.midiPlayer = [NewPlayMidi getMidiPlayer];
    }
    return self;
}
    
- (void)notifyCompleteOnePractice
{
    [self.pressingNotes removeAllObjects];
    [self.practiceDelegate doOnePractice];
}

/*
 钢琴88键 21-108
 下表列出的是与音符相对应的命令标记。
 八度音阶||                    音符号
 #  ||
    || C   | bD  |  D  | bE  |  bF |  F  | bG  |  G  | bA  |  A  | bB  | bC
    || B#  | C#  |  D  | D#  |  E  | E#  | F#  |  G  | G#  |  A  | A#  | B
 -----------------------------------------------------------------------------
 .  ||   0 |   1 |   2 |   3 |   4 |   5 |   6 |   7 |   8 |   9 |  10 | 11
 0  ||  12 |  13 |  14 |  15 |  16 |  17 |  18 |  19 |  20 |  21 |  22 | 23
 1  ||  24 |  25 |  26 |  27 |  28 |  29 |  30 |  31 |  32 |  33 |  34 | 35
 2  ||  36 |  37 |  38 |  39 |  40 |  41 |  42 |  43 |  44 |  45 |  46 | 47
 3  ||  48 |  49 |  50 |  51 |  52 |  53 |  54 |  55 |  56 |  57 |  58 | 59
 4  ||  60 |  61 |  62 |  63 |  64 |  65 |  66 |  67 |  68 |  69 |  70 | 71
 5  ||  72 |  73 |  74 |  75 |  76 |  77 |  78 |  79 |  80 |  81 |  82 | 83
 6  ||  84 |  85 |  86 |  87 |  88 |  89 |  90 |  91 |  92 |  93 |  94 | 95
 7  ||  96 |  97 |  98 |  99 | 100 | 101 | 102 | 103 | 104 | 105 | 106 | 107
 8  || 108 | 109 | 110 | 111 | 112 | 113 | 114 | 115 | 116 | 117 | 118 | 119
 9  || 120 | 121 | 122 | 123 | 124 | 125 | 126 | 127 |
 
 {1,3,4,6,8,10,11}  fifths=-7, bB,bE,bA,bD,bG,bC,bF     bC大调/降a小调
 {1,3,5,6,8,10,11}  fifths=-6, bB,bE,bA,bD,bG,bC        bG大调/降e小调
 {0,1,3,5,6,8,10}   fifths=-5, bB,bE,bA,bD,bG           bD大调/降b小调
 {0,1,3,5,7,8,10}   fifths=-4, bB,bE,bA,bD              bA大调/f小调
 {0,2,3,5,7,8,10}   fifths=-3, bB,bE,bA                 bE大调/c小调
 {0,2,3,5,7,9,10}   fifths=-2, bB,bE                    bB大调/g小调
 {0,2,4,5,7,9,10}   fifths=-1, bB                       F大调/d小调
 {0,2,4,5,7,9,11}   fifths=0                            C大调/a小调
 {0,2,4,6,7,9,11}   fifths=1, #F                        G大调/e小调
 {1,2,4,6,7,9,11}   fifths=2, #F,#C                     D大调/b小调
 {1,2,4,6,8,9,11}   fifths=3, #F,#C,#G                  A大调/#f小调
 {1,3,4,6,8,9,11}   fifths=4, #F,#C,#G,#D               E大调/#c小调
 {1,3,4,6,8,10,11}  fifths=5, #F,#C,#G,#D,#A            B大调/#g小调
 {1,3,5,6,8,10,11}  fifths=6, #F,#C,#G,#D,#A,#E         #F大调/#d小调
 {0,1,3,5,6,8,10}   fifths=7, #F,#C,#G,#D,#A,#E,#B      #C大调/#a小调
 */

- (void)randSelectNote:(NSInteger)nNoteNum
{
    if ([self.selectedNotes count] > 0)
        [self.selectedNotes removeAllObjects];
    NSInteger nTotalCanPressKeys = keyboard_complete_oct*7;
    for (NSInteger i = 0; i < 7; ++i) {
        if (keyboard_remainder_notes > scales_map[self.signatureType][i]) {
            nTotalCanPressKeys++;
        }
    }
    [self.drawDelegate fixNoteXOrder];
    NSInteger pivot = arc4random()%nTotalCanPressKeys, haveSelected = 1;
    [self.selectedNotes addObject:[NSNumber numberWithInteger:pivot/7*12+scales_map[self.signatureType][pivot%7]]];
    [self.drawDelegate drawSelectedNote:self.keyboard_start_octave+pivot/7.0 stepWithAlter:pivot%7 shouldMoveRight:NO];
    //start random walk
    NSInteger left_bound, right_bound = left_bound = pivot;
    BOOL bWalkLeftMove = NO, bWalkRightMove = NO;
    for (NSInteger i = 0; haveSelected != nNoteNum; ++i) {
        NSInteger nHaveOccupied = right_bound-left_bound+1;
        NSInteger nReservedSeat = nNoteNum-haveSelected-1;
        NSInteger nCanSelectSeat = ONE_HAND_OVERLAP_KEYS-nHaveOccupied-nReservedSeat;
        if (i%2 == 0) {     //walk towards left
            nCanSelectSeat = MIN(nCanSelectSeat, left_bound);
            /*left_bound is the left end of the whole select set, cann't walk towards left any more.
             */
            if (!nCanSelectSeat)
                continue;
            pivot = left_bound-arc4random()%nCanSelectSeat-1;
            if (!bWalkLeftMove && left_bound-pivot == 1) {
                bWalkLeftMove = YES;
            } else {
                bWalkLeftMove = NO;
            }
            [self.selectedNotes addObject:[NSNumber numberWithInteger:pivot/7*12+scales_map[self.signatureType][pivot%7]]];
            [self.drawDelegate drawSelectedNote:self.keyboard_start_octave+pivot/7.0 stepWithAlter:pivot%7 shouldMoveRight:bWalkLeftMove];
            left_bound = pivot;
            haveSelected++;
        } else {        //towards right
            nCanSelectSeat = MIN(nCanSelectSeat, nTotalCanPressKeys-right_bound-1);
            /*right_bound is the right end of the whole select set*/
            if (!nCanSelectSeat)
                continue;
            pivot = right_bound+arc4random()%nCanSelectSeat+1;
            if (!bWalkRightMove && pivot-right_bound == 1) {
                bWalkRightMove = YES;
            } else {
                bWalkRightMove = NO;
            }
            [self.selectedNotes addObject:[NSNumber numberWithInteger:pivot/7*12+scales_map[self.signatureType][pivot%7]]];
            [self.drawDelegate drawSelectedNote:self.keyboard_start_octave+pivot/7.0 stepWithAlter:pivot%7 shouldMoveRight:bWalkRightMove];
            right_bound = pivot;
            haveSelected++;
        }
    }
}

- (void)randSelectKeyboardOctave:(MusicSignatureType)type ClefType:(MusicClefType)clef_type
{
    self.signatureType = type;
    NSInteger index = -1;
    if (MUSIC_TREBLE_CLEF == clef_type) {
        index = 2;      //fix the start octave with c1
    } else if (MUSIC_BASS_CLEF == clef_type) {
        index = 0;      //fix with C
    } else {    //MUSIC_TREBLE_AND_BASS_CLEF == clef_type
        index = arc4random()%([self.doNoteString count]-[self.doNoteLabel count]+1);
    }
    /*The first octave contained in the `doNoteString` array is C which corresponds with 2
     */
    self.keyboard_start_octave = 2+index;
    for (NSInteger i = 0; i < [self.doNoteLabel count]; ++i) {
        UILabel* doLabel = self.doNoteLabel[i];
        doLabel.text = self.doNoteString[index+i];
        doLabel.textColor = [UIColor blackColor];
        doLabel.textAlignment = NSTextAlignmentCenter;
        doLabel.font = [UIFont systemFontOfSize:36];
    }
}
@end

#pragma mark - ViewController(The Root Container)
@interface PracticeReadMusic ()
@property(nonatomic, strong) UIButton* hintBtn;

- (void)hintShouldPressedKey;
- (void)returnPreviousPage;
@end

@implementation PracticeReadMusic
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.mainRect = [UIScreen mainScreen].bounds;
    self.staff_start_x = 32.0f, self.staff_start_y = 80.0f;
    self.view.backgroundColor = [UIColor colorWithRed:241/255.0 green:223/255.0 blue:183/255.0 alpha:1.0];
    
    self.staff = [[DrawStaff alloc] initWithFrame:CGRectMake(self.staff_start_x, self.staff_start_y, self.mainRect.size.width*STAFF_SCREEN_WIDTH_SCALE, self.mainRect.size.height*STAFF_SCREEN_HEIGHT_SCALE)];
    self.staff.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    self.staff.clef_type = self.pPracticeEntity.clef_type;
    [self.view addSubview:self.staff];
    
    self.keyboard = [[DrawKeyboard alloc] initWithFrame:CGRectMake(0, self.mainRect.size.height*(1-KEYBOARD_HSCREEN_SCALE), self.mainRect.size.width, self.mainRect.size.height*KEYBOARD_HSCREEN_SCALE)];
    [self.view addSubview:self.keyboard];
    self.keyboard.drawDelegate = self.staff;
    self.keyboard.practiceDelegate = self;
    
    DrawRedHorizontalBar* redHorizontalBar = [[DrawRedHorizontalBar alloc] initWithFrame:CGRectMake(0, self.mainRect.size.height*(1-KEYBOARD_HSCREEN_SCALE), self.mainRect.size.width, KEYBOARD_CORNER_RADIUS)];
    [self.view addSubview:redHorizontalBar];
    
    DrawGrayVerticalBar* verticalBar = [[DrawGrayVerticalBar alloc] initWithFrame:CGRectMake(self.staff_start_x+self.mainRect.size.width*STAFF_SCREEN_WIDTH_SCALE+12.0, self.staff_start_y, 4.0, self.mainRect.size.height*STAFF_SCREEN_HEIGHT_SCALE)];
    verticalBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:verticalBar];
    
    CGFloat hint_button_start_x = (self.mainRect.size.width*(1+STAFF_SCREEN_WIDTH_SCALE)+self.staff_start_x+6.0)/2.0-HINT_BUTTON_WIDTH/2.0, hint_button_start_y = self.staff_start_y+self.mainRect.size.height*STAFF_SCREEN_HEIGHT_SCALE/2.0-HINT_BUTTON_HEIGHT/2.0;
    self.hintBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.hintBtn.frame = CGRectMake(hint_button_start_x, hint_button_start_y, HINT_BUTTON_WIDTH, HINT_BUTTON_HEIGHT);
    [self.hintBtn setTitle:@"提示" forState:UIControlStateNormal];
    self.hintBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [self.hintBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.hintBtn.layer.cornerRadius = HINT_BUTTON_HEIGHT/2.0-3.0;
    self.hintBtn.backgroundColor = [UIColor colorWithRed:(0x00)/255.0 green:(0x88)/255.0 blue:(0xff)/255.0 alpha:1.0];
    [self.hintBtn addTarget:self action:@selector(hintShouldPressedKey) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hintBtn];
    
    UIButton* retBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    retBtn.frame = CGRectMake(1, 6, HINT_BUTTON_WIDTH/2.0, HINT_BUTTON_HEIGHT*2.0/3.0); //Minnie1.6 :)
    [retBtn setTitle:@"<Back" forState:UIControlStateNormal];
    retBtn.titleLabel.font = [UIFont systemFontOfSize:22];
    [retBtn addTarget:self action:@selector(returnPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:retBtn];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self doOnePractice];
}

- (void)doOnePractice
{
    [self.staff eraseAllStaffView];
    //first draw signature
    NSInteger nStatusNum = 1;
    MusicSignatureType type = MUSIC_C_MAJOR;
    for (NSNumber* signatureIndex in self.pPracticeEntity.signatureSet)
    {
        if (0 == arc4random()%nStatusNum)
            type = (MusicSignatureType)[signatureIndex integerValue];
        nStatusNum++;
    }
    [self.staff drawSignature:type];
    //then determine the keyboard octave and draw random selected note
    [self.keyboard randSelectKeyboardOctave:type ClefType:self.pPracticeEntity.clef_type];
    NSUInteger note_num = self.pPracticeEntity.note_number;
    [self.keyboard randSelectNote:note_num];
}

- (void)hintShouldPressedKey
{
    for (NSNumber* index in self.keyboard.selectedNotes)
    {
        PianoKey* pianoKey = self.keyboard.pianoKeyArray[[index integerValue]];
        pianoKey.backgroundColor = [UIColor greenColor];
        pianoKey.bHintStatus = YES;
    }
}

- (void)returnPreviousPage
{
    [self dismissViewControllerAnimated:YES completion:^{}];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
@end

#pragma mark - Practice Entity Transfered between two different View Controller
@interface PracticeEntity ()
@end

@implementation PracticeEntity
- (id)init
{
    self = [super init];
    if (self) {
        self.clef_type = MUSIC_TREBLE_AND_BASS_CLEF;
        self.signatureSet = [[NSMutableSet alloc] init];
        self.note_number = 1;
    }
    return self;
}
@end

#pragma mark - ViewController(The Practice Navigation)
@interface PracticeNavigation ()
{
    CGRect mainRect;
}
@property(weak, nonatomic) IBOutlet UIButton *trebleStaffBtn;
@property(weak, nonatomic) IBOutlet UIButton *bassStaffBtn;
@property(weak, nonatomic) IBOutlet UIButton *grandStaffBtn;
@property(weak, nonatomic) IBOutlet UILabel *trebleStaffLabel;
@property(weak, nonatomic) IBOutlet UILabel *bassStaffLabel;
@property(weak, nonatomic) IBOutlet UILabel *grandStaffLabel;
@property(weak, nonatomic) IBOutlet UIButton *startPracticeBtn;
@property(weak, nonatomic) IBOutlet UIButton *oneNoteBtn;
@property(weak, nonatomic) IBOutlet UIButton *twoNoteBtn;
@property(weak, nonatomic) IBOutlet UILabel *clefLabel;
@property(weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property(weak, nonatomic) IBOutlet UILabel *noteLabel;
@property(nonatomic, strong) CirCularOnNavigation* circularView;

- (void)selectSignature;
@end

@implementation PracticeNavigation
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pPracticeEntity = [[PracticeEntity alloc] init];
    [self.pPracticeEntity.signatureSet addObject:[NSNumber numberWithInteger:MUSIC_C_MAJOR]];
    mainRect = [UIScreen mainScreen].bounds;
    self.circularView = [[CirCularOnNavigation alloc] initWithFrame:CGRectMake(mainRect.size.width/3.0, mainRect.size.height/2.0-mainRect.size.width/6.0, mainRect.size.width/3.0, mainRect.size.width/3.0) OnPopupView:NO SignatureSet:self.pPracticeEntity.signatureSet];
    self.circularView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.circularView];
    
    DrawGrayVerticalBar* verticalBar = [[DrawGrayVerticalBar alloc] initWithFrame:CGRectMake(mainRect.size.width/3.0-2, 0, 4, mainRect.size.height)];
    verticalBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:verticalBar];
    verticalBar = [[DrawGrayVerticalBar alloc] initWithFrame:CGRectMake(mainRect.size.width/3.0*2.0-2, 0, 4, mainRect.size.height)];
    verticalBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:verticalBar];
    
    UIButton* signatureBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    signatureBtn.frame = CGRectMake(self.view.bounds.size.width/2.0-NAVIGATION_SIGNATURE_WIDTH/2.0, self.view.bounds.size.height/2.0-NAVIGATION_SIGNATURE_HEIGHT/2.0, NAVIGATION_SIGNATURE_WIDTH, NAVIGATION_SIGNATURE_HEIGHT);
    [signatureBtn setTitle:@"选择调号" forState:UIControlStateNormal];
    signatureBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [signatureBtn addTarget:self action:@selector(selectSignature) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signatureBtn];
}

- (void)viewDidLayoutSubviews
{
    CGFloat staff_button_width = mainRect.size.width/3.0/(3+4*STAFF_BUTTON_MARGIN_SCALE), staff_button_height = staff_button_width;
    CGFloat note_button_margin = (mainRect.size.width/3.0-staff_button_width*2.0)/3.0;
    UIImage* selectedImage = [UIImage imageNamed:@"selected_treble_staff.png"];
    [self.trebleStaffBtn setCenter:CGPointMake(staff_button_width*(STAFF_BUTTON_MARGIN_SCALE+0.5), mainRect.size.height/2.0)];
    [self.trebleStaffBtn setBounds:CGRectMake(0, 0, staff_button_width, staff_button_height)];
    [self.trebleStaffBtn setImage:selectedImage forState:UIControlStateSelected];
    
    selectedImage = [UIImage imageNamed:@"selected_bass_staff.png"];
    [self.bassStaffBtn setCenter:CGPointMake(staff_button_width*(1.5+STAFF_BUTTON_MARGIN_SCALE*2), mainRect.size.height/2.0)];
    [self.bassStaffBtn setBounds:CGRectMake(0, 0, staff_button_width, staff_button_height)];
    [self.bassStaffBtn setImage:selectedImage forState:UIControlStateSelected];
    
    selectedImage = [UIImage imageNamed:@"selected_grand_staff.png"];
    [self.grandStaffBtn setCenter:CGPointMake(staff_button_width*(2.5+STAFF_BUTTON_MARGIN_SCALE*3), mainRect.size.height/2.0)];
    [self.grandStaffBtn setBounds:CGRectMake(0, 0, staff_button_width, staff_button_height)];
    [self.grandStaffBtn setImage:selectedImage forState:UIControlStateSelected];
    
    self.trebleStaffBtn.selected = NO;
    self.bassStaffBtn.selected = NO;
    self.grandStaffBtn.selected = NO;
    if (MUSIC_TREBLE_CLEF == self.pPracticeEntity.clef_type) {
        self.trebleStaffBtn.selected = YES;
    } else if (MUSIC_BASS_CLEF == self.pPracticeEntity.clef_type) {
        self.bassStaffBtn.selected = YES;
    } else {    //MUSIC_TREBLE_AND_BASS_CLEF == self.pPracticeEntity.clef_type
        self.grandStaffBtn.selected = YES;
    }
    
    CGFloat staff_y_offset = mainRect.size.height/2.0+staff_button_height/2.0+32, staff_label_font_size = 14.0;
    [self.trebleStaffLabel setCenter:CGPointMake(staff_button_width*(STAFF_BUTTON_MARGIN_SCALE+0.5), staff_y_offset)];
    self.trebleStaffLabel.font = [UIFont systemFontOfSize:staff_label_font_size];
    self.trebleStaffLabel.textColor = [UIColor colorWithRed:(0x00)/255.0 green:(0x88)/255.0 blue:(0xff)/255.0 alpha:1.0];
    
    [self.bassStaffLabel setCenter:CGPointMake(staff_button_width*(1.5+STAFF_BUTTON_MARGIN_SCALE*2), staff_y_offset)];
    self.bassStaffLabel.font = [UIFont systemFontOfSize:staff_label_font_size];
    self.bassStaffLabel.textColor = [UIColor colorWithRed:(0x00)/255.0 green:(0x88)/255.0 blue:(0xff)/255.0 alpha:1.0];
    
    [self.grandStaffLabel setCenter:CGPointMake(staff_button_width*(2.5+STAFF_BUTTON_MARGIN_SCALE*3), staff_y_offset)];
    self.grandStaffLabel.font = [UIFont systemFontOfSize:staff_label_font_size];
    self.grandStaffLabel.textColor = [UIColor colorWithRed:(0x00)/255.0 green:(0x88)/255.0 blue:(0xff)/255.0 alpha:1.0];
    
    [self.startPracticeBtn setCenter:CGPointMake(mainRect.size.width/2.0, mainRect.size.height*NAVIGATION_PRACTICE_Y_SCALE)];
    self.startPracticeBtn.titleLabel.font = [UIFont systemFontOfSize:NAVIGATION_LABEL_FONT_SIZE];
    [self.startPracticeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startPracticeBtn.layer.cornerRadius = 5;
    self.startPracticeBtn.backgroundColor = [UIColor colorWithRed:(0x00)/255.0 green:(0x88)/255.0 blue:(0xff)/255.0 alpha:1.0];
    
    selectedImage = [UIImage imageNamed:@"selected_one_note.png"];
    [self.oneNoteBtn setCenter:CGPointMake(mainRect.size.width/3.0*2.0+note_button_margin+staff_button_width/2.0, mainRect.size.height/2.0)];
    [self.oneNoteBtn setBounds:CGRectMake(0, 0, staff_button_width, staff_button_height)];
    [self.oneNoteBtn setImage:selectedImage forState:UIControlStateSelected];
    
    selectedImage = [UIImage imageNamed:@"selected_two_note.png"];
    [self.twoNoteBtn setCenter:CGPointMake(mainRect.size.width/3.0*2.0+note_button_margin*2.0+staff_button_width*1.5, mainRect.size.height/2.0)];
    [self.twoNoteBtn setBounds:CGRectMake(0, 0, staff_button_width, staff_button_height)];
    [self.twoNoteBtn setImage:selectedImage forState:UIControlStateSelected];
    
    self.oneNoteBtn.selected = NO;
    self.twoNoteBtn.selected = NO;
    if (1 == self.pPracticeEntity.note_number) {
        self.oneNoteBtn.selected = YES;
    } else {    //2 == self.pPracticeEntity.note_number
        self.twoNoteBtn.selected = YES;
    }
    
    [self.clefLabel setCenter:CGPointMake(mainRect.size.width/3.0/2.0, mainRect.size.height*NAVIGATION_LABEL_Y_SCALE)];
    self.clefLabel.font = [UIFont systemFontOfSize:NAVIGATION_LABEL_FONT_SIZE];
    
    [self.signatureLabel setCenter:CGPointMake(mainRect.size.width/3.0*1.5, mainRect.size.height*NAVIGATION_LABEL_Y_SCALE)];
    self.signatureLabel.font = [UIFont systemFontOfSize:NAVIGATION_LABEL_FONT_SIZE];
    
    [self.noteLabel setCenter:CGPointMake(mainRect.size.width/3.0*2.5, mainRect.size.height*NAVIGATION_LABEL_Y_SCALE)];
    self.noteLabel.font = [UIFont systemFontOfSize:NAVIGATION_LABEL_FONT_SIZE];
}

- (void)selectSignature
{
    SignatureSelector* sigSelector = [[SignatureSelector alloc] initWithFrame:self.view.bounds SignatureSet:self.pPracticeEntity.signatureSet];
    sigSelector.circularDelegate = self.circularView;
    [self.view addSubview:sigSelector];
}

- (IBAction)selectTrebleStaff:(id)sender {
    self.trebleStaffBtn.selected = YES;
    self.bassStaffBtn.selected = NO;
    self.grandStaffBtn.selected = NO;
    self.pPracticeEntity.clef_type = MUSIC_TREBLE_CLEF;
}

- (IBAction)selectBassStaff:(id)sender {
    self.trebleStaffBtn.selected = NO;
    self.bassStaffBtn.selected = YES;
    self.grandStaffBtn.selected = NO;
    self.pPracticeEntity.clef_type = MUSIC_BASS_CLEF;
}

- (IBAction)selectGrandStaff:(id)sender {
    self.trebleStaffBtn.selected = NO;
    self.bassStaffBtn.selected = NO;
    self.grandStaffBtn.selected = YES;
    self.pPracticeEntity.clef_type = MUSIC_TREBLE_AND_BASS_CLEF;
}

- (IBAction)selectOneNote:(id)sender {
    self.oneNoteBtn.selected = YES;
    self.twoNoteBtn.selected = NO;
    self.pPracticeEntity.note_number = 1;
}

- (IBAction)selectTwoNote:(id)sender {
    self.oneNoteBtn.selected = NO;
    self.twoNoteBtn.selected = YES;
    self.pPracticeEntity.note_number = 2;
}

- (IBAction)startPractice:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    PracticeReadMusic* practiceReadMusic = [[PracticeReadMusic alloc] init];
    practiceReadMusic.pPracticeEntity = self.pPracticeEntity;
    //jump into next view controller
    practiceReadMusic.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:practiceReadMusic animated:YES completion:^{}];
}
@end