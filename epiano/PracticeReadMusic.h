//
//  PracticeReadMusic.h
//  epiano
//
//  Created by jiang nan on 15/8/10.
//  Copyright (c) 2015年 jiang nan. All rights reserved.
//

#ifndef epiano_PracticeReadMusic_h
#define epiano_PracticeReadMusic_h

#import <UIKit/UIKit.h>
#import "NewPlayMidi.h"

#define MARGIN_LEFT     20.0
#define MARGIN_RIGHT    20.0
#define LINE_DISTANCE   18.0
#define STAFF_DISTANCE  64.0
#define STAFF_SCREEN_WIDTH_SCALE    0.72
#define STAFF_SCREEN_HEIGHT_SCALE   0.48
#define KEYBOARD_HSCREEN_SCALE      0.36
#define KEYBOARD_CORNER_RADIUS      5
#define HINT_BUTTON_WIDTH           128
#define HINT_BUTTON_HEIGHT          36

/*white key number can be set with any proper value, but here must keep the appointment that the most left and right must be white key
 */
#define WHITE_KEY_NUMBER        15
#define BLACK_KEY_WIDTH_SCALE   0.8
#define BLACK_KEY_HEIGHT_SCALE  0.618
#define DO_LABEL_SCALE_IN_KEY   0.2

#define DISPLAY_START_SCALE 1.0/2
#define DISPLAY_STOP_SCALE  2.0/3

#define WHOLE_NOTE_WIDTH        40/2.0
#define WHOLE_NOTE_HEIGHT       36/2.0
#define STOP_FLAG_WIDTH         10
#define STOP_FLAG_HEIGHT        36
#define FLAT_FLAG_WIDTH         12
#define FLAT_FLAG_HEIGHT        36
#define SHARP_FLAG_WIDTH        18
#define SHARP_FLAG_HEIGHT       36
#define FLAG_NOTE_DISTANCE      1
#define NOTE_VELOCITY           72
#define PRACTICE_NUMBER         10
#define ONE_HAND_OVERLAP_KEYS   7

#define BOTTOM_NOTE_VIRTUAL_VALUE   2*7+3
#define MIDDLE_NOTE_VIRTUAL_VALUE   4*7
#define TOP_NOTE_VIRTUAL_VALUE      5*7+4
#define SELECT_AND_PRESS_NOTE_DIS   64

#define CIRCULAR_RADIUS_SCALE       0.50
#define SIG_VIEW_BOUNDS_DISTANCE    24
#define SIG_VIEW_SQUARE_BOUND       22
#define SIG_IMAGE_VIEW_DISTANCE     36
#define SIG_IMAGE_RECT_WIDTH        51
#define SIG_IMAGE_RECT_HEIGHT       36
#define POPUP_SELECTOR_RADIUS_SCALE 0.81

#define STAFF_BUTTON_MARGIN_SCALE   0.5
#define NAVIGATION_LABEL_FONT_SIZE  28
#define NAVIGATION_LABEL_Y_SCALE    0.16
#define NAVIGATION_PRACTICE_Y_SCALE 0.92
#define NAVIGATION_SIGNATURE_WIDTH  96
#define NAVIGATION_SIGNATURE_HEIGHT 32
#define GRAY_VERTICAL_BAR_SCALE     0.64

typedef enum
{
    MUSIC_DOWN_C_MAJOR  = 0,
    MUSIC_DOWN_G_MAJOR  = 1,
    MUSIC_DOWN_D_MAJOR  = 2,
    MUSIC_DOWN_A_MAJOR  = 3,
    MUSIC_DOWN_E_MAJOR  = 4,
    MUSIC_DOWN_B_MAJOR  = 5,
    MUSIC_F_MAJOR       = 6,
    MUSIC_C_MAJOR       = 7,
    MUSIC_G_MAJOR       = 8,
    MUSIC_D_MAJOR       = 9,
    MUSIC_A_MAJOR       = 10,
    MUSIC_E_MAJOR       = 11,
    MUSIC_B_MAJOR       = 12,
    MUSIC_UP_F_MAJOR    = 13,
    MUSIC_UP_C_MAJOR    = 14,
    MUSIC_TOTAL_MAJORS  = 15,
} MusicSignatureType;

typedef enum
{
    MUSIC_TREBLE_AND_BASS_CLEF = 0,
    MUSIC_TREBLE_CLEF,
    MUSIC_BASS_CLEF,
} MusicClefType;

typedef enum
{
    KEYBOARD_WHITE_KEY = 0,
    KEYBOARD_BLACK_KEY,
} KeyType;

typedef enum
{
    MUSIC_NONE = 0,
    MUSIC_RESTORE_MARK,
    MUSIC_FLAT_MARK,
    MUSIC_SHARP_MARK,
} NoteMark;

@protocol DrawNoteDelegate <NSObject>
@required
- (void)fixNoteXOrder;
- (void)drawSelectedNote:(NSInteger)note_octave stepWithAlter:(NSInteger)oct_internal_index shouldMoveRight:(BOOL)bShouldMoveRight;
- (void)showPressedNote:(NSInteger)nNoteValue signatureType:(MusicSignatureType)type;
- (void)clearPressedNote:(NSInteger)nNoteValue;
@end

@interface DrawNoteOnStaff : NSObject
@property(nonatomic, strong) UIImageView* noteImageView;
@property(nonatomic, strong) NSMutableArray* noteUnderLineArray;
@property(nonatomic, strong) UIImageView* flagImageView;

- (id)init;
@end

@interface DrawStaff : UIView <DrawNoteDelegate>
@end

@interface DrawKeyboard : UIView
@property(nonatomic, strong) NewPlayMidi* midiPlayer;
@property(nonatomic, assign) NSInteger keyboard_start_octave;
@property(nonatomic, assign) MusicSignatureType signatureType;
@property(nonatomic, assign) id<DrawNoteDelegate> drawDelegate;
@property(nonatomic, strong) NSMutableArray* pianoKeyArray;
@property(nonatomic, strong) NSMutableSet* selectedNotes;
@property(atomic, strong) NSMutableSet* pressingNotes;

- (void)notifyCompleteOnePractice;
@end

@interface PracticeEntity : NSObject
@property(nonatomic, assign) MusicClefType clef_type;
@property(nonatomic, strong) NSMutableSet* signatureSet;
@property(nonatomic, assign) NSInteger note_number;
@end

@interface DrawGrayVerticalBar : UIView
@end

@interface CirCularOnNavigation : UIView
- (id)initWithFrame:(CGRect)frame OnPopupView:(BOOL)bOnPopupView SignatureSet:(NSMutableSet*)signatureSet;
@end

@interface AlertBackground : UIView <UIGestureRecognizerDelegate>
@end

@interface SignatureSelector : AlertBackground
@property(nonatomic, weak) CirCularOnNavigation* circularDelegate;

- (id)initWithFrame:(CGRect)frame SignatureSet:(NSMutableSet*)signatureSet;
@end

@interface PracticeReadMusic : UIViewController
@property(nonatomic, strong) DrawStaff* staff;
@property(nonatomic, strong) DrawKeyboard* keyboard;
@property(nonatomic, assign) CGRect mainRect;
@property(nonatomic, assign) CGFloat staff_start_x, staff_start_y;
@property(nonatomic, retain) PracticeEntity* pPracticeEntity;

- (void)doOnePractice;
@end

@interface PracticeNavigation : UIViewController
@property(nonatomic, strong) PracticeEntity* pPracticeEntity;
@end

#endif  //epiano_PracticeReadMusic_h