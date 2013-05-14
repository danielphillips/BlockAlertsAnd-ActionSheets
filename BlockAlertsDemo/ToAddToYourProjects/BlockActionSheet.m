//
//  BlockActionSheet.m
//
//

#import "BlockActionSheet.h"
#import "BlockBackground.h"
#import "BlockUI.h"

@implementation BlockActionSheet

@synthesize view = _view;
@synthesize vignetteBackground = _vignetteBackground;

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *buttonFont = nil;

#pragma mark - init

+ (void)initialize
{
    if (self == [BlockActionSheet class])
    {
        background = [UIImage imageNamed:kActionSheetBackground];
        background = [[background stretchableImageWithLeftCapWidth:0 topCapHeight:kActionSheetBackgroundCapHeight] retain];
        titleFont = [kActionSheetTitleFont retain];
        buttonFont = [kActionSheetButtonFont retain];
    }
}

+ (id)sheetWithTitle:(NSString *)title
{
    return [[[BlockActionSheet alloc] initWithTitle:title] autorelease];
}

- (id)initWithTitle:(NSString *)title 
{
    if ((self = [super init]))
    {
        UIWindow *parentView = [BlockBackground sharedInstance];
        CGRect frame = parentView.bounds;
        
        _view = [[UIView alloc] initWithFrame:frame];
        _blocks = [[NSMutableArray alloc] init];
        _height = kActionSheetTopMargin;

        if (title)
        {
            CGSize size = [title sizeWithFont:titleFont
                            constrainedToSize:CGSizeMake(frame.size.width-kActionSheetBorder*2, 1000)
                                lineBreakMode:UILineBreakModeWordWrap];
            
            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kActionSheetBorder, _height, frame.size.width-kActionSheetBorder*2, size.height)];
            labelView.font = titleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = UILineBreakModeWordWrap;
            labelView.textColor = kActionSheetTitleTextColor;
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = NSTextAlignmentCenter;
            labelView.shadowColor = kActionSheetTitleShadowColor;
            labelView.shadowOffset = kActionSheetTitleShadowOffset;
            labelView.text = title;
            [_view addSubview:labelView];
            [labelView release];
            
            _height += size.height + 5;
        }
        _vignetteBackground = NO;
    }
    
    return self;
}

- (void) dealloc 
{
    [_view release];
    [_blocks release];
    [super dealloc];
}

- (NSUInteger)buttonCount
{
    return _blocks.count;
}

- (void)addButtonWithTitle:(NSString *)title image:(NSString*)imageName imageHighlighted:(NSString*)imageNameHighlighted block:(void (^)())block atIndex:(NSInteger)index
{
    if (index >= 0)
    {
        [_blocks insertObject:[NSArray arrayWithObjects:
                               block ? [[block copy] autorelease] : [NSNull null],
                               title,
                               imageName,
                               imageNameHighlighted?imageNameHighlighted:imageName,
                               nil]
                      atIndex:index];
    }
    else
    {
        [_blocks addObject:[NSArray arrayWithObjects:
                            block ? [[block copy] autorelease] : [NSNull null],
                            title,
                            imageName,
                            imageNameHighlighted?imageNameHighlighted:imageName,
                            nil]];
    }
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title image:@"red-button.png" imageHighlighted:nil block:block atIndex:-1];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title image:@"bt-action-off.png" imageHighlighted:nil block:block atIndex:-1];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title image:@"action-gray-button.png" imageHighlighted:nil block:block atIndex:-1];
}

- (void)addButtonWithTitle:(NSString *)title andImageName:(NSString *)imageName andImageNameHighlighted:(NSString *)imageNameHighlighted block:(void (^)()) block
{
    [self addButtonWithTitle:title image:imageName imageHighlighted:imageNameHighlighted block:block atIndex:-1];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title image:@"action-red-button.png" imageHighlighted:nil block:block atIndex:index];
}

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title image:@"action-black-button.png" imageHighlighted:nil block:block atIndex:index];
}

- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title image:@"action-gray-button.png" imageHighlighted:nil block:block atIndex:index];
}

- (UIButton *) createButtonTitle:(NSString *)title withImage:(UIImage *)image andHighLightedImage:(UIImage *)imageHighLighted
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.accessibilityLabel = title;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:imageHighLighted forState:UIControlStateHighlighted];
    button.titleLabel.font = buttonFont;
    button.titleLabel.minimumFontSize = 6;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.shadowOffset = kActionSheetButtonShadowOffset;
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:kActionSheetButtonTextColor forState:UIControlStateNormal];
    [button setTitleShadowColor:kActionSheetButtonShadowColor forState:UIControlStateNormal];
    [button setTitleColor:kActionSheetButtonShadowColor forState:UIControlStateHighlighted];
    [button setTitleShadowColor:kActionSheetButtonTextColor forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)showGridInView:(UIView *)view
{
    NSUInteger i = 1;
    
    for (NSArray *block in _blocks)
    {
        NSString *title = [block objectAtIndex:1];
        NSString *imageName = [block objectAtIndex:2];
        NSString *imageNameHighlighted = [block objectAtIndex:3];
        
        UIButton *button;
        
        if (i < _blocks.count){
            
            int collum = (i-1)%3;
            
            if (collum == 0 && (i-1)/3 != 0)
                _height += 105;
            
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitle:title forState:UIControlStateNormal];
            button.accessibilityLabel = title;
            [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:imageNameHighlighted] forState:UIControlStateHighlighted];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
            button.frame = CGRectMake(29+(29*collum)+([button backgroundImageForState:UIControlStateNormal].size.width*collum), _height, [button backgroundImageForState:UIControlStateNormal].size.width, [button backgroundImageForState:UIControlStateNormal].size.height);
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [button setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(button.frame.size.height+8, -5.0f, 0.0f, -5.0f)];
        }
        else
        {
            _height += 120;
            
            button = [self createButtonTitle:title withImage:[UIImage imageNamed:imageName] andHighLightedImage:[UIImage imageNamed:imageNameHighlighted]];
            button.frame = CGRectMake(kActionSheetBorder, _height, _view.bounds.size.width-kActionSheetBorder*2, kActionSheetButtonHeight);
            _height += kActionSheetButtonHeight + kActionSheetBorder;
            
        }
        
        button.tag = i++;
        
        [_view addSubview:button];
    }
    
    [self show];
}

- (void)showInView:(UIView *)view
{
    NSUInteger i = 1;
    for (NSArray *block in _blocks)
    {
        NSString *title = [block objectAtIndex:1];
        NSString *imageName = [block objectAtIndex:2];
        NSString *imageNameHighlighted = [block objectAtIndex:3];
        
        UIButton *button = [self createButtonTitle:title
                                         withImage:[UIImage imageNamed:imageName]
                               andHighLightedImage:[UIImage imageNamed:imageNameHighlighted]];
        
        button.frame = CGRectMake(kActionSheetBorder, _height, _view.bounds.size.width-kActionSheetBorder*2, kActionSheetButtonHeight);
        button.tag = i++;
        
        [_view addSubview:button];
        _height += kActionSheetButtonHeight + kActionSheetBorder + (_blocks.count == i ? 20.0 : 0.0);
    }
    [self show];
    
}

- (void) show
{
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
    modalBackground.image = background;
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    [_view insertSubview:modalBackground atIndex:0];
    [modalBackground release];
    
    [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:_view];
    CGRect frame = _view.frame;
    frame.origin.y = [BlockBackground sharedInstance].bounds.size.height;
    frame.size.height = _height + kActionSheetBounce;
    _view.frame = frame;
    
    __block CGPoint center = _view.center;
    center.y -= _height + kActionSheetBounce;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [BlockBackground sharedInstance].alpha = 1.0f;
                         _view.center = center;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              center.y += kActionSheetBounce;
                                              _view.center = center;
                                          } completion:nil];
                     }];
    
    [self retain];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (animated)
    {
        CGPoint center = _view.center;
        center.y += _view.bounds.size.height;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _view.center = center;
                             [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                         } completion:^(BOOL finished) {
                             [[BlockBackground sharedInstance] removeView:_view];
                             [_view release]; _view = nil;
                             
                             if (buttonIndex >= 0 && buttonIndex < [_blocks count])
                             {
                                 id obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:0];
                                 if (![obj isEqual:[NSNull null]])
                                 {
                                     ((void (^)())obj)();
                                 }
                             }
                             
                             [self autorelease];
                         }];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:_view];
        [_view release]; _view = nil;
        
        if (buttonIndex >= 0 && buttonIndex < [_blocks count])
        {
            id obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:0];
            if (![obj isEqual:[NSNull null]])
            {
                ((void (^)())obj)();
            }
        }
        
        [self autorelease];
    }
}

#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    int buttonIndex = [(UIButton *)sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
