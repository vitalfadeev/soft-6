module types;

import std.traits;
import std.conv;
import bindbc.sdl;

alias m    = void;
alias m8   = ubyte;
alias m8s  = ubyte[];
alias m32  = uint;
alias mptr = m*;
alias Code = m8;
alias Timestamp = ReturnType!SDL_GetTicks;
const DA =  1;
const DO =  0;
const DU = -1;
enum ChipState
{
    Normal,
    Selected,
    Hovered,
    Drag,
    Drop
}

alias PX        = typeof(SDL_Rect.x);
alias Coord     = typeof(SDL_Rect.x);
alias GridCoord = typeof(SDL_Rect.x);
alias Point     = SDL_Point;
alias Rect      = SDL_Rect;
alias Renderer  = SDL_Renderer;
alias D         = SDL_Event;
alias Event     = SDL_Event;


struct GridPoint
{
    GridCoord x,y;

    this( Coord x, Coord y )
    {
        this.x = x;
        this.y = y;
    }

    this(T)( Coord x, Coord y, T gridsize )
    {
        this.x = x / gridsize;
        this.y = y / gridsize;
    }


    GridPoint opBinary( string op : "+" )( GridPoint b )
    {
        return GridPoint( x + b.x, y + b.y );
    }

    GridPoint opBinary( string op : "-" )( GridPoint b )
    {
        return GridPoint( x - b.x, y - b.y );
    }
}

struct GridRect
{
    GridCoord x,y,w,h;
}


bool PointInRect( GridPoint* p, GridRect* r )
{
    return 
        SDL_PointInRect( cast(SDL_Point*)p, cast(SDL_Rect*)r ) == SDL_TRUE ?
            true : 
            false;
}

auto IntersectRect( GridRect* a, GridRect* b, GridRect* result )
{
    return SDL_IntersectRect( cast(SDL_Rect*)a, cast(SDL_Rect*)b, cast(SDL_Rect*)result );
}

bool RectInRect( GridRect* a, GridRect* b )
{
    SDL_Rect result;
    if ( SDL_IntersectRect( cast(SDL_Rect*)a, cast(SDL_Rect*)b, &result ) == SDL_TRUE )
        return true;
    else
        return false;
}

//struct Renderer
//{
//    SDL_Renderer* renderer;
//    alias renderer this;
 
//    auto SetDrawColor(R,G,B,A)( R r, G g, B b, A a )
//    {
//        return SDL_SetRendererDrawColor( renderer, r, g, b, a );
//    }
//}

alias XSDL_TYPE = Uint32;
XSDL_TYPE XSDL_IN_MOUSE;
XSDL_TYPE XSDL_OUT_MOUSE;
XSDL_TYPE XSDL_OVER_MOUSE;
XSDL_TYPE XSDL_DRAG;
XSDL_TYPE XSDL_DROP;
XSDL_TYPE XSDL_SLOW;
//
XSDL_TYPE XSDL_DRAWINRECT;
XSDL_TYPE XSDL_DRAW;
XSDL_TYPE XSDL_ARRANGE;

string XSDL_toString( XSDL_TYPE a )
{
    import std.traits;
    import std.string;
    import types;
    static foreach( m; __traits(allMembers, types) )
        static if ( m.startsWith( "XSDL_") )
            static if ( is( typeof( __traits( getMember, types, m ) ) == XSDL_TYPE ) )
                if ( a == __traits( getMember, types, m ) ) return m;

    return a.to!string;
}

enum OType
{
    O = 0x01,
    CHIP,
    CHIPPOUT,
    CHIPS,
}

enum OState
{
    // O
    O_INITS        = (OType.O << 8) + 0x01,
    O_HOVERS,
    O_HOVERSELECTS,
    O_DRAGS,
    // Chip
    CHIP_INITS     = (OType.CHIP << 8) + 0x01,
    // ChipPout
    CHIPPOUT_INITS = (OType.CHIPPOUT << 8) + 0x01,
    // Chips
    CHIPS_INITS    = (OType.CHIPS << 8) + 0x01,
}

auto CallIfNotNull(alias FUNC,TO,TA)(TO o, TA a)
{
    if ( func !is null )
        FUNC( o, a );
}

// arrange struct
struct Ars
{
    GridRect   rect;
    GridCoord  totalw;
    ARRANGATOR arrangator;
}

alias ARRANGATOR = GridPoint function( Ars* ar, Align ali, GridRect* r );

enum Align
{
    Left,
    Middle,
    Right
}