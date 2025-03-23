cvars = $gtk.args.cvars

WELCOME_TEXT = 'Welcome Player! Press ? at any time for help.'
TITLE_TEXT = cvars["game_metadata.gametitle"].value.to_s
AUTHOR_TEXT = "By #{cvars['game_metadata.devid'].value.to_s}"
NEW_GAME_TEXT = '[N] Play a new game'
CONTINUE_GAME_TEXT = '[C] Continue last game'
QUIT_TEXT = '[Q] Quit'
CHARACTER_SCREEN_TITLE_TEXT = '┤Character Information├'
MESSAGE_HISTORY_TITLE_TEXT = '┤Message history├'
ITEM_SELECTION_TITLE_TEXT = '┤Select item├'
LEVEL_UP_TITLE_TEXT = 'Congratulations! You level up!'
LEVEL_UP_SUBTITLE_TEXT = 'Select an attribute to increase.'

EXCEPTION_NOTHING_TO_PICK_UP_TEXT = 'There is nothing to pick up.'
PICKED_UP_TEXT = 'You picked up the'

EXCEPTION_NO_PORTAL_HERE_TEXT = 'There is no portal here.'
ENTER_PORTAL_TEXT = 'You enter the portal.'

NOTHING_TO_ATTACK_TEXT = 'Nothing to attack.'

WAY_BLOCKED_TEXT = 'That way is blocked.'

# DragonRuby is fixed at 1280x720 so choosing a resolution that fits neatly
SCREEN_WIDTH = 80  # 80 * 16 = 1280
SCREEN_HEIGHT = 45 # 45 * 16 = 720

UP_KEYS = [:up, :k, :kp_eight]
DOWN_KEYS = [:down, :j, :kp_two]
LEFT_KEYS = [:left, :h, :kp_four]
RIGHT_KEYS = [:right, :l, :kp_six]
UP_RIGHT_KEYS = [:page_up, :u, :kp_nine]
UP_LEFT_KEYS = [:insert, :y, :kp_seven]
DOWN_RIGHT_KEYS = [:page_down, :n, :kp_three]
DOWN_LEFT_KEYS = [:delete, :b, :kp_one]
WAIT_KEYS = [:space, :period, :kp_five]
LOOK_KEYS = [:forward_slash, :kp_divide]
INTERACTION_KEYS = [:enter, :kp_enter]