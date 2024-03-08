/* See LICENSE file for copyright and license details. */

/* alt-tab configuration */
static const unsigned int tabModKey         = 0x40; /* if this key is hold the alt-tab functionality stays acitve. This key must be the same as key that is used to active functin altTabStart `*/
static const unsigned int tabCycleKey       = 0x17; /* if this key is hit the alt-tab program moves one position forward in clients stack. This key must be the same as key that is used to active functin altTabStart */
static const unsigned int tabCycleKey2      = 0x31; /* grave key */
static const unsigned int tabPosY           = 1;    /* tab position on Y axis, 0 = bottom, 1 = center, 2 = top */
static const unsigned int tabPosX           = 1;    /* tab position on X axis, 0 = left, 1 = center, 2 = right */
static const unsigned int maxWTab           = 600;  /* tab menu width */
static const unsigned int maxHTab           = 200;  /* tab menu height */


/* appearance */
static const unsigned int borderpx  = 1.5;        /* border pixel of windows */
static const unsigned int gappx     = 15;        /* gaps between windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int usealtbar          = 1;        /* 1 means use non-dwm status bar */
static const char *altbarclass      = "Polybar"; /* Alternate bar class name */
static const char *alttrayname      = "tray";    /* Polybar tray instance name */
static const char *altbarcmd        = "/home/rongzi/.config/polybar/pwidgets/launch dwm"; /* Alternate bar launch command */
static const char *fonts[]          = { "Source Han Sans CN:size=18:style=regular" };
static const char dmenufont[]       = "monospace:size=20";
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_blue[]        = "#3399c8";
static const char col_cyan[]        = "#005577";
static const char *colors[][3]      = {
    /*               fg         bg         border   */
    [SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
    [SchemeSel]  = { col_gray4, col_cyan,  col_blue  },
};

/* tagging */
static const char *tags[] = { "1_", "2_", "3_", "4_﬙", "5_", "6_", "7_", "8_", "9_" };

static const Rule rules[] = {
    /* xprop(1):
     *  WM_CLASS(STRING) = instance, class
     *  WM_NAME(STRING) = title
     */
    /* class            instance title            tags mask isfloating isfullscreen monitor */
    {  "Gimp",          NULL,    NULL,            0,   1,   0,         -1           },
    // {  "Firefox",       NULL,    NULL,            1    <<   8,         0,           0,      -1 },
    {  NULL,            NULL,    "joshuto",       0,   1,   0,         1            },
    {  NULL,            NULL,    "note",          0,   1,   0,         1            },
    {  NULL,            NULL,    "quick",         0,   1,   0,         1            },
    {  NULL,            NULL,    "EmojiFloatWnd", 0,   1,   0,         1            },
    {  NULL,            NULL,    "成员",          0,   1,   0,         1            },
    {  NULL,            NULL,    "wemeetapp",     0,   1,   0,         1            },
    {  "Viewnior",      NULL,    NULL,            0,   1,   0,         1            },
    {  "kdeconnectd",   NULL,    NULL,            0,   0,   1,         1            },
    {  "Gcolor3",       NULL,    NULL,            0,   1,   0,         1            },
    {  "xfce4-notifyd", NULL,    NULL,            0,   1,   0,         1            }
};

/* layout(s) */
static const float mfact          = 0.55; /* factor of    master  area  size   [0.05..0.95] */
static const int   nmaster        = 1;    /* number of    clients in    master area         */
static const int   resizehints    = 1;    /* 1      means respect size  hints  in           tiled      resizals */
static const int   lockfullscreen = 1;    /* 1      will  force   focus on     the          fullscreen window   */

static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[]=",      tile },    /* first entry is default */
    { "><>",      NULL },    /* no layout function means floating behavior */
    { "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define MODKEY_ALT Mod1Mask
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY, view,       {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,           KEY, toggleview, {.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,             KEY, tag,        {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY, toggletag,  {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[]   = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL  };
static const char *termcmd[]    = { "alacritty", NULL  };
static const char *note[]       = { "/home/rongzi/.config/scripts/note", NULL  };
static const char *powerMenu[]  = { "/home/rongzi/.config/polybar/pwidgets/scripts/powermenu.sh", NULL  };
static const char *drun[]       = { "rofi", "-modi", "drun", "-show", "drun", "-config", "/home/rongzi/.config/rofi/main_menu.rasi", NULL };
static const char *winMenu[]    = { "rofi", "-modi", "window", "-show", "window", "-config", "/home/rongzi/.config/rofi/main_menu.rasi", NULL };
static const char *chrome[]     = { "google-chrome-stable", NULL };
static const char *lock[]       = { "/home/rongzi/.config/scripts/lock", NULL };
static const char *shot[]       = { "/home/rongzi/.config/scripts/shot", NULL };
static const char *mouseShot[]  = { "/home/rongzi/.config/scripts/mouse_shot", NULL };
static const char *picom[]      = { "/home/rongzi/.config/scripts/picom", NULL };
static const char *myPicom[]    = { "/home/rongzi/.config/scripts/my_picom", NULL };
static const char *btop[]       = { "/home/rongzi/.config/scripts/btop", NULL };
static const char *joshuto[]    = { "/home/rongzi/.config/scripts/joshuto", NULL };
static const char *clipboard[]  = { "/home/rongzi/.config/scripts/clipboard", NULL };
static const char *pcmanfm[]    = { "pcmanfm", NULL };
static const char *lightup[]    = { "/home/rongzi/.config/scripts/backlight", "+10%",  NULL };
static const char *lightdown[]  = { "/home/rongzi/.config/scripts/backlight","10%-",  NULL };
static const char *volumeup[]   = { "pactl", "set-sink-volume","@DEFAULT_SINK@", "+10%", NULL };
static const char *volumedown[] = { "pactl", "set-sink-volume","@DEFAULT_SINK@", "-10%", NULL };
static const char *volumemute[] = { "pactl", "set-sink-mute","@DEFAULT_SINK@", "toggle", NULL };


static const Key keys[] = {
    /* modifier                     key        function        argument */
    { MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
    { 0,             XF86XK_MonBrightnessUp,   spawn,          {.v = lightup } },
    { 0,             XF86XK_MonBrightnessDown, spawn,          {.v = lightdown } },
    { 0,             XF86XK_AudioRaiseVolume,     spawn,          {.v = volumeup } },
    { 0,             XF86XK_AudioLowerVolume,     spawn,          {.v = volumedown } },
    { 0,             XF86XK_AudioMute,            spawn,          {.v = volumemute } },
    { MODKEY,                       XK_d,      spawn,          {.v = drun } },
    { MODKEY,                       XK_o,      spawn,          {.v = clipboard } },
    { MODKEY,                       XK_t,      spawn,          {.v = pcmanfm } },
    { MODKEY,                       XK_v,      togglebar,      {0} },
    { MODKEY|ShiftMask,             XK_w,      spawn,          {.v = winMenu } },
    { MODKEY|ShiftMask,             XK_e,      spawn,          {.v = powerMenu } },
    { MODKEY,                       XK_c,      spawn,          {.v = chrome } },
    { MODKEY|ShiftMask,             XK_x,      spawn,          {.v = lock } },
    { MODKEY|ShiftMask,             XK_s,      spawn,          {.v = shot } },
    { MODKEY|ShiftMask,             XK_a,      spawn,          {.v = mouseShot } },
    { MODKEY,                       XK_n,      spawn,          {.v = picom } },
    { MODKEY,                       XK_b,      spawn,          {.v = myPicom } },
    { ControlMask|ShiftMask,        XK_Return, spawn,          {.v = btop } },
    { MODKEY_ALT,                   XK_Return, spawn,          {.v = note } },
    { ControlMask|ShiftMask,        XK_h,      spawn,          {.v = joshuto } },
    { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
    { MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
    { MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
    { MODKEY,                       XK_p,      incnmaster,     {.i = -1 } },
    { MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
    { MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
    { MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
    { MODKEY,                       XK_q,      view,           {0} },
    { MODKEY|ShiftMask,             XK_q,      killclient,     {0} },
    { MODKEY,                       XK_e,      setlayout,      {.v = &layouts[0]} },
    { MODKEY,                       XK_w,      setlayout,      {.v = &layouts[2]} },
    { MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
    { MODKEY,                       XK_0,      view,           {.ui = ~0 } },
    { MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
    { MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
    { MODKEY,                       XK_period, focusmon,       {.i = +1 } },
    { MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
    { MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
    { MODKEY,                       XK_minus,  setgaps,        {.i = -1 } },
    { MODKEY,                       XK_equal,  setgaps,        {.i = +1 } },
    { MODKEY|ShiftMask,             XK_equal,  setgaps,        {.i = 0  } },
    { MODKEY,                       XK_f,      togglefullscr,  {.i = 0  } },
    { Mod1Mask,                     XK_Tab,    altTabStart,    {.i = 1} },
    { Mod1Mask,                     XK_grave,  altTabStart,    {.i = 0} },
    TAGKEYS(                        XK_1,                      0)
    TAGKEYS(                        XK_2,                      1)
    TAGKEYS(                        XK_3,                      2)
    TAGKEYS(                        XK_4,                      3)
    TAGKEYS(                        XK_5,                      4)
    TAGKEYS(                        XK_6,                      5)
    TAGKEYS(                        XK_7,                      6)
    TAGKEYS(                        XK_8,                      7)
    TAGKEYS(                        XK_9,                      8)
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
    /* click          event             mask     button          function argument */
    {  ClkLtSymbol,   0,                Button1, setlayout,      {0}      },
    {  ClkLtSymbol,   0,                Button3, setlayout,      {.v      =        &layouts[2]} },
    {  ClkWinTitle,   0,                Button2, zoom,           {0}      },
    {  ClkStatusText, 0,                Button2, spawn,          {.v      =        termcmd      }  },
    {  ClkClientWin,  MODKEY,           Button1, movemouse,      {0}      },
    {  ClkClientWin,  MODKEY,           Button2, togglefloating, {0}      },
    {  ClkClientWin,  MODKEY|ShiftMask, Button1, resizemouse,    {0}      },
    {  ClkTagBar,     0,                Button1, view,           {0}      },
    {  ClkTagBar,     0,                Button3, toggleview,     {0}      },
    {  ClkTagBar,     MODKEY,           Button1, tag,            {0}      },
    {  ClkTagBar,     MODKEY,           Button3, toggletag,      {0}      },
};

static const char *ipcsockpath = "/tmp/dwm.sock"; static IPCCommand ipccommands[] = {
  IPCCOMMAND(  view,                1,      {ARG_TYPE_UINT}   ),
  IPCCOMMAND(  toggleview,          1,      {ARG_TYPE_UINT}   ),
  IPCCOMMAND(  tag,                 1,      {ARG_TYPE_UINT}   ),
  IPCCOMMAND(  toggletag,           1,      {ARG_TYPE_UINT}   ),
  IPCCOMMAND(  tagmon,              1,      {ARG_TYPE_UINT}   ),
  IPCCOMMAND(  focusmon,            1,      {ARG_TYPE_SINT}   ),
  IPCCOMMAND(  focusstack,          1,      {ARG_TYPE_SINT}   ),
  IPCCOMMAND(  zoom,                1,      {ARG_TYPE_NONE}   ),
  IPCCOMMAND(  incnmaster,          1,      {ARG_TYPE_SINT}   ),
  IPCCOMMAND(  killclient,          1,      {ARG_TYPE_SINT}   ),
  IPCCOMMAND(  togglefloating,      1,      {ARG_TYPE_NONE}   ),
  IPCCOMMAND(  setmfact,            1,      {ARG_TYPE_FLOAT}  ),
  IPCCOMMAND(  setlayoutsafe,       1,      {ARG_TYPE_PTR}    ),
  IPCCOMMAND(  quit,                1,      {ARG_TYPE_NONE}   )
};


