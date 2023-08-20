module cls.o.o;

import std.stdio;
import bindbc.sdl;
import cls.o.inits;
import types;
import colors;

alias SENSOR  = void function( O* o, D* dar );
alias DRAW    = void function( O* o, Renderer* renderer, GridRect* drawRect );
alias SAVE    = void function( O* o, size_t level, ubyte[]* result );
alias LOAD    = void function( O* o );
alias ARRANGE = void function( O* o, Ars * );


// State Machine
//   Sensor( e )
//     mov rax, [sensor]      // address of structure
//       cmp rax, 0           // if null 
//       jz skip              //   then skip
//     call [rax]             // call func

struct FN(string FNAME,TFN)
    if ( is( TFN == SENSOR ) ||
         is( TFN == DRAW ) ||
         is( TFN == SAVE ) ||
         is( TFN == LOAD ) ||
         is( TFN == ARRANGE )
    )
{
    TFN fn;

    void opCall(ARGS...)( O* o, ARGS args )
    {
        if ( fn !is null )
            fn( o, args );
    }
}

struct Funcs
{
    FN!("Sensor",  SENSOR)  Sensor;
    FN!("Draw",    DRAW)    Draw;
    FN!("Load",    LOAD)    Load;
    FN!("Save",    SAVE)    Save;
    FN!("Arrange", ARRANGE) Arrange;
}

struct State
{
    Funcs           funcs;
    TypeInfo_Struct type;
}

// O
//   state
//     funcs
//       Sensor
//       Draw
//       Load
//       Save
//       Arrange
//     type
//   type
//   ...
//   x
//   y
//   w
//   h
//   ...
struct O
{
    State _state = {                // State
        funcs : {                   // Funcs
            Sensor : { &.OSensor }, // FN
            Draw   : { &.ODraw },   // FN
            Load   : { null },      // FN
            Save   : { &.OSave!O }, // FN
            Arrange: { &.OArrange },// FN
        },
        type : typeid(O)            // TypeInfo_Struct
    };

    TypeInfo_Struct type = typeid(O);

    // DList
    // Inner content
    O* leo; // left  eated o
    O* reo; // right eated o
    // same level content
    O* l;   // left  o
    O* r;   // right o

    // Data
    m8 id;

    // View
    union {
        struct { GridCoord x,y,w,h; } // in Grid Coords
        GridRect           rect;
        GridPoint          point;
    }
    Coord     gridsize = 48;
    Color     fg       = Color(  199, 199,  199, SDL_ALPHA_OPAQUE );
    Color     bg       = Color(  0, 0,  0, SDL_ALPHA_OPAQUE );
    //
    bool      hoverable;
    bool      selectable;
    // Drag
    bool      dragable;
    GridPoint clickRel;

    // Methods
    bool Is( GridPoint p )
    {
        if ( PointInRect( &p, &rect ) )
            return true;

        return false;
    }

    // foreach( e; o )...
    int opApply(scope int delegate(ref O*) dg)
    {
        if ( leo !is null )
        for( auto e = leo; e !is null; e = e.r )
        {
            int result = dg(e);
            if (result)
                return result;
        }
        return 0;
    }    

    // foreach_reverse( e; o )...
    int opApplyReverse(scope int delegate(ref O*) dg)
    {
        if ( leo !is null )
        for( auto e = reo; e !is null; e = e.l )
        {
            int result = dg(e);
            if (result)
                return result;
        }
        return 0;
    }
}


void Eat( O* a, O* b )
{
    // no before
    if ( a.leo is null )
    {
        a.leo = b;
        a.reo = b;
    }
    else

    // has before
    {
        a.reo.r = b;
        b.l = a.reo;
        a.reo = b;
    }
}

void Out( O* a, O* b )
{
    if ( b.l !is null )
        b.l.r = b.r;

    if ( b.r !is null )
        b.r.l = b.l;

    if ( a.leo == b )
        a.leo = b.r;

    if ( a.reo == b )
        a.reo = b.l;

    b.l = null;
    b.r = null;
}

// struct Chip
//   O _super;
//   alias _super this;
//
//   void Sensor( o, d )
mixin template OMixin(TSUP=O,T_INIT_STATE=void)
    if ( __traits(hasMember, T_INIT_STATE, "_state") || is(T_INIT_STATE == void) )
{
    import std.traits;

    alias THIS=__traits(parent, {});

    // State
    static if ( !is(T_INIT_STATE == void) )
    {
        alias T1 = T_INIT_STATE;
        alias T2 = void;
    }
    // State-Less
    else
    {
        alias T1 = THIS;
        alias T2 = TSUP;
    }

    //
    static if ( !is(T_INIT_STATE==void) )
        enum TYPE = typeid(T_INIT_STATE);
    else
        enum TYPE = null;

    //
    TSUP _super = {                                     // O
        _state: {                                       // State
            funcs: {                                    // Funcs
                Sensor: { IFFN!(THIS,T1,T2,"Sensor") }, // FN
                Draw:   { IFFN!(THIS,T1,T2,"Draw")   }, // FN
                Load:   { IFFN!(THIS,T1,T2,"Load")   }, // FN
                Save:   { IFFN!(THIS,T1,T2,"Save")   }, // FN
                Arrange:{ IFFN!(THIS,T1,T2,"Arrange")}, // FN
            },
            type: TYPE                                  // TypeInfo_Struct
        },
        type : typeid(THIS)                             // TypeInfo_Struct
    };
    alias _super this;

    //
    mixin OSensorMixin!();
}

// O
//   Sensor
mixin template OSensorMixin()
{
    import types;

    alias THIS = typeof(this);

    
    static
    void Sensor( O* o, D* d )
    {
        Sense!THIS( o, d );

        // recursive
        SensorRecursive( o, d );
    }
}


// switch..case
//   if d.type == SDL_*   on_SDL_*;
//   if d.type == XSDL_*  on_XSDL_*;
//pragma( inline, true )
void Sense(T)( O* o, D* d )
{
    import std.traits;
    import std.string;
    import std.format;

    // SDL
    static foreach( m; __traits( allMembers, T ) )
        static if ( __traits(isStaticFunction, __traits(getMember, T, m)) ) 
            static if ( m.startsWith( "on_SDL_" ) )
            {
                if (d.type == mixin(m[3..$])) 
                { 
                    __traits(getMember, T, m)( o, d ); 
                    return; 
                }
            }

    // XSDL
    static foreach( m; __traits( allMembers, T ) )
        static if ( __traits(isStaticFunction, __traits(getMember, T, m)) ) 
            static if ( m.startsWith( "on_XSDL_" ) )
            {
                if (d.type == mixin(m[3..$]))
                { 
                    __traits(getMember, T, m)( o, d ); 
                    return; 
                }
            }
}


// Try
//   go_Init()
//   go_Hover()
//pragma( inline, true )
void Go(T)( O* o, D* d )
{
    import std.string;

    static foreach( m; __traits( allMembers, T ) )
        static if ( __traits(isStaticFunction, __traits(getMember, T, m)) ) 
            static if ( m.startsWith( "go_" ) )
                __traits(getMember, T, m)( o, d );
}

// Go!Hover
// Go!Init
static
void Go(alias T)( O* o )
    if (__traits(hasMember, T, "_state"))
{
    import std.traits;
    import std.string;
    import std.format;
    import std.conv;
    writeln( (o._state.type.to!string).rightJustify( 30, ' ' ), " -> ", T.stringof );

    // State
    //   funcs
    //   type
    o._state = T.init._state;
}


mixin template StateMixin()
{
    import types;

    alias THIS = typeof(this); // Init, Hover
    
    State _state = {                                      // State
        funcs : {                                         // Funcs
            Sensor : { IFFN!(THIS,THIS,void,"Sensor" ) }, // FN
            Draw   : { IFFN!(THIS,THIS,void,"Draw"   ) }, // FN
            Load   : { IFFN!(THIS,THIS,void,"Load"   ) }, // FN
            Save   : { IFFN!(THIS,THIS,void,"Save"   ) }, // FN
            Arrange: { IFFN!(THIS,THIS,void,"Arrange") }, // FN
        },
        type : typeid(THIS)                               // TypeInfo_Struct
    };

    mixin StateSensorMixin!(THIS);
}

mixin template StateSensorMixin(T)
{
    static
    void Sensor( O* o, D* d )
    {
        Sense!T( o, d );
        Go!T( o, d );

        // recursive
        SensorRecursive( o, d );
    }
}


template RJString( string S )
{
    import std.string;
    enum RJString = S.rightJustify( 30, ' ' );
}
template LJString( string S )
{
    import std.string;
    enum LJString = S.leftJustify( 30, ' ' );
}

template IFFN(alias THIS,alias T1,alias T2,string FNAME)
{
    import std.traits;

    // T1.Draw
    static if ( __traits(hasMember,T1,FNAME) )
    {
        // static void Draw() {...}
        static if ( __traits(isStaticFunction, __traits( getMember, T1, FNAME ) ) )
        {
            pragma( msg, 
                RJString!(THIS.stringof ~ "." ~ FNAME), " <- ", 
                LJString!(T1.stringof), 
                " = ", (&__traits( getMember, T1, FNAME )) );
            enum IFFN = &__traits( getMember, T1, FNAME );
        }
        // enum Draw = &Init.Draw;
        else
        {
            pragma( msg, 
                RJString!(THIS.stringof ~ "." ~ FNAME), " <- ", 
                LJString!(T1.stringof), 
                " = ", __traits( getMember, T1, FNAME ) );
            enum IFFN = __traits( getMember, T1, FNAME );
        }
    }
    // T2.Draw
    else
    {
        static if ( !is( T2 == void ) )
        {        
            pragma( msg, 
                RJString!(THIS.stringof ~ "." ~ FNAME), " <- ", 
                LJString!(T2.stringof), 
                " = ",
                (__traits( getMember, 
                    __traits( getMember, 
                        __traits( getMember, 
                            __traits( getMember, 
                                T2.init, 
                                "_state" ),
                            "funcs" ),
                         FNAME ),
                     "fn" )
                )
            );
            enum IFFN = __traits( getMember, T2.init._state.funcs, FNAME ).fn;
        }
        else
        {        
            pragma( msg, RJString!(THIS.stringof ~ "." ~ FNAME), " <- " );
            enum IFFN = null;
        }
    }
}


static
void OSensor( O* o, D* d )
{
    Sense!O( o, d );

    // recursive
    SensorRecursive( o, d );
}


static
void ODraw( O* o, Renderer* renderer, GridRect* drawRect )
{
    _DrawBackground( o, renderer );
    _DrawGrid( o, renderer );
    _DrawLines( o, renderer );

    // recursive
    DrawRecursive( o, renderer, drawRect );
}

static
void _DrawBackground( O* o, Renderer* renderer )
{
    auto gridsize = o.gridsize;
    auto x = o.x;
    auto y = o.y;
    auto w = o.w;
    auto h = o.h;

    SDL_Rect _rect = { x*gridsize, y*gridsize, w*gridsize, h*gridsize };
    SetRenderDrawColorStruct( renderer, Pal.Black );
    SDL_RenderFillRect( renderer, &_rect );
}

static
void _DrawGrid( O* o, Renderer* renderer )
{
    auto gridsize = o.gridsize;
    auto x = o.x;
    auto y = o.y;
    auto w = o.w;
    auto h = o.h;

    SDL_SetRenderDrawColor( renderer, 55, 55, 55, SDL_ALPHA_OPAQUE );

    import std.range : iota;
    foreach( _y; iota( y*gridsize, (y+h)*gridsize, gridsize ) )
        SDL_RenderDrawLine( renderer, x*gridsize, _y, (x+w)*gridsize, _y );

    foreach( _x; iota( x*gridsize, (x+w)*gridsize, gridsize ) )
        SDL_RenderDrawLine( renderer, _x, y*gridsize, _x, (y+h)*gridsize );
}

static
void _DrawLines( O* o, Renderer* renderer )
{
    auto gridsize = o.gridsize;
    auto x = o.x;
    auto y = o.y;
    auto w = o.w;
    auto h = o.h;

    auto x1 = x * gridsize;
    auto y1 = y * gridsize;
    auto x2 = (x+w) * gridsize;
    auto y2 = (y+h) * gridsize;

    SetRenderDrawColorStruct( renderer, Pal.Normal );
    SDL_RenderDrawLine( renderer, x1, y1, x2, y2 ); // \
    SDL_RenderDrawLine( renderer, x1, y2, x2, y1 ); // /
}


//static
//void Load(T)( T* o )
//{
//    import std.stdio;
//    writeln( __FUNCTION__ );
//    LoadRecursive( o );
//}


// Save
// o code s state
//   a code type value
//   a code type value
//   a code type value
//   o code s state
//     a code type value
//     a code type value
//     a code type value
//   r
// r
//
// type
//   t bool
//   b byte
//   B ubyte
//   h short
//   H ushort
//   i int
//   I uint
//   l intlong
//   L ulong
//   f float
//   d double
//   s string
//   S struct
void OSave(T)( T* o, size_t level, ubyte[]* result )
{
    (*result) ~= Serialize!T( o );
}

ubyte[] Serialize(T)(T a)
    if ( is(T == string) )
{
    import std.conv;

    ubyte[] bytes;
    
    bytes ~= 's';
    bytes ~= " " ~ a.length.to!ubyte.to!string;
    if ( a.length )
        bytes ~= " " ~ a.ptr[0..a.length].to!string;
    
    return bytes;
}

ubyte[] Serialize(T)(T a)
    if ( is(T == bool) )
{
    import std.conv;

    ubyte[] bytes;
    
    bytes ~= 't';
    bytes ~= " " ~ a.to!string;
    
    return bytes;
}

ubyte[] Serialize(T)(T a)
    if ( is(T == byte) )
{
    import std.conv;

    ubyte[] bytes;
    
    bytes ~= 'b';
    bytes ~= " " ~ a.to!string;
    
    return bytes;
}

ubyte[] Serialize(T)(T a)
    if ( is(T == ubyte) )
{
    import std.conv;

    ubyte[] bytes;
    
    bytes ~= 'B';
    bytes ~= " " ~ a.to!string;
    
    return bytes;
}

ubyte[] Serialize(T)(T a)
    if ( is(T == int) )
{
    import std.conv;

    ubyte[] bytes;
    
    bytes ~= 'i';
    bytes ~= " " ~ ( cast(ubyte*)&a )[0..4].to!string;
    
    return bytes;
}

ubyte[] Serialize(T)(T a)
    if ( is(T == uint) )
{
    import std.conv;

    ubyte[] bytes;
    
    bytes ~= 'I';
    bytes ~= " " ~ ( cast(ubyte*)&a )[0..4].to!string;
    
    return bytes;
}

ubyte[] Serialize(T)(T a)
    if ( is( T == struct ) )
{
    import std.conv;

    ubyte[] bytes;
    
    bytes ~= "S";
    bytes ~= " " ~ a.to!string;
    
    return bytes;
}

// Serialize( _super )
ubyte[] Serialize(T)(T* o)
    if ( is( T == O ) )
{
    import std.traits;
    import std.stdio;
    import std.string;
    import std.range;
    import std.conv;

    ubyte[] bytes;

    // O
    bytes ~= "o ";
    bytes ~= o.type.toString;
    bytes ~= " ";
    bytes ~= "s ";
    bytes ~= (o._state.type !is null) ? (o._state.type.toString) : "(null)";
    bytes ~= "\n";

    // attr
    static foreach ( m; __traits( allMembers, T ) )
        static if ( 
            (m != "leo") &&
            (m != "reo") &&
            (m != "l") &&
            (m != "r") &&
            (m != "clickRel") &&
            (m != "_state") &&
            (m != "type") &&
            (m != "recursive") &&
            //(m != "_super") &&
            (!isSomeFunction!(__traits(getMember, T, m) ) ) 
        )
        {
            pragma( msg, T, ".", m );
            bytes ~= " a ";
            bytes ~= m;
            bytes ~= " ";
            bytes ~= Serialize( __traits(getMember, o, m) );
            bytes ~= "\n";
        }

    // recursive
    size_t level; 
    ubyte[] result;
    SaveRecursive( o, level+1, &result );
    bytes ~= result;
    
    // ret
    bytes ~= "r\n";

    return bytes;
}


//
void OArrange( O* o, Ars* ar )
{
    const ali = Align.Middle;

    o.point = ar.arrangator( ar, ali, &o.rect );

    // recursive
    ArrangeEo( o );
}


void Arrange( O* o )
{
    Ars ar;
    ar.rect = o.rect;
    ar.arrangator = &Arrangator1;
    OArrange( o, &ar );
}


void ArrangeEo( O* o )
{
    import std.range;
    if ( o.leo is null )
        return;

    Ars ar;
    ar.arrangator = &Arrangator1;
 
    GridCoord totalw;
    foreach( e; *o )
        totalw += e.w;
 
    ar.totalw = totalw;
 
    ar.rect.x = o.rect.x + (o.rect.w - totalw)/2;
    ar.rect.w = o.rect.w - totalw;
    ar.rect.y = o.rect.y;
    ar.rect.h = o.rect.h;

    ArrangeRecursive( o, &ar );
}

GridPoint Arrangator1( Ars* ar, Align ali, GridRect* r )
{
    if ( ali == Align.Left )
    {
        auto p = GridPoint( ar.rect.x, ar.rect.y );
        ar.rect.x = p.x + r.w;
        return p;
    }
    else
    if ( ali == Align.Middle )
    {
        auto p = GridPoint( ar.rect.x, ar.rect.y );
        ar.rect.x = p.x + r.w;
        return p;
    }
    
    return GridPoint( 0, 0 );
}


void DoSlow( O* o )
{
    //
}


// wrappers
void Sensor( O* o, D* d )
{
    o._state.funcs.Sensor( o, d );
}

void Draw( O* o, Renderer* renderer, GridRect* drawRect )
{
    o._state.funcs.Draw( o, renderer, drawRect );
}

void Load( O* o )
{
    o._state.funcs.Load( o );
}

void Save( O* o, size_t level, ubyte[]* result )
{
    o._state.funcs.Save( o, level, result );
}

void Arrange( O* o, Ars* ar )
{
    o._state.funcs.Arrange( o, ar );
}

// Recursive
void SensorRecursive( O* o, D* d )
{
    foreach( e; *o )
        .Sensor( e, d );
}

void DrawRecursive( O* o, Renderer* renderer, GridRect* drawRect )
{
    foreach( e; *o )
        .Draw( e, renderer, drawRect );
}

void SaveRecursive( O* o, size_t level, ubyte[]* result )
{
    foreach( e; *o )
        .Save( e, level, result );
}

void LoadRecursive( O* o )
{
    foreach( e; *o )
        .Load( e );
}

void ArrangeRecursive( O* o, Ars* ar )
{
    foreach( e; *o )
        .Arrange( e, ar );
}


// Send
void Send( O* o, XSDL_TYPE xsdl )
{
    D d;
    d.type = cast(SDL_EventType)xsdl;
    .Sensor( o, &d );
}
void Send( O* o, XSDL_TYPE xsdl, void* a1 )
{
    D d;
    d.type = cast(SDL_EventType)xsdl;
    d.user.data1 = a1;
    .Sensor( o, &d );
}
void Send( O* o, XSDL_TYPE xsdl, void* a1, void* a2 )
{
    D d;
    d.type = cast(SDL_EventType)xsdl;
    d.user.data1 = a1;
    d.user.data2 = a2;
    .Sensor( o, &d );
}



//ways
//              INIT, HOVER, HOVERSELECT, DRAG, DROP,
//INIT,                   1                            // go_Hover
//HOVER,           1                   1               // go_Init, go_HoverSelect
//HOVERSELECT,     1                         1         // go_Init, go_Drag
//DRAG,            1                   1               // go_Init, go_HoverSelect
//DROP,

// Tos( XSDL_IN_MOUSE )

struct Ways
{
    //                     INIT, HOVER, HOVERSELECT, DRAG, DROP,
    bool[5] Init        = [   0,     1,           0,    0,    0 ]; // go_Hover
    bool[5] Hover       = [   1,     0,           1,    0,    0 ]; // go_Init, go_HoverSelect
    bool[5] Hoverselect = [   1,     1,           0,    1,    0 ]; // go_Init, go_Drag
    bool[5] Drag        = [   1,     1,           1,    0,    0 ]; // go_Init, go_HoverSelect
    bool[5] Drop        = [   0,     0,           0,    0,    0 ];
}

// Check!Ways
void Check(T)()
    if ( is( T == struct ) )
{
    import std.string;
    import std.format;
    import std.stdio;

    alias TA = __traits(allMembers, T);

    string s;
    string ss;

    static foreach( m; __traits(allMembers, T))
    {
        s  = "";
        ss = "";
        static foreach( i, b; __traits(getMember, T.init, m) )
        {
            static if ( b )
            static if ( __traits(hasMember, mixin(__MODULE__), m ) )
            static if ( !__traits(hasMember, mixin(m), "go_" ~ TA[i]) )
               ss ~= format!
"
    void go_%s( o, d )
    {
        //
    }"( TA[i] );

        }

        if ( ss.length > 0 )
        {
            s = format!
"
struct %s
{
    mixin StateMixin;
    %s
}
"(m, ss);

        }

        if ( s.length > 0)
        {
            writeln( s );
            assert(0, "Require go_...");
        }
    }
}

static
this()
{
    Check!Ways();
}

// Sensor( o, d )
//   Sense( o, d );
//     on_...( o, d );
//   Go( o, d );
//     go_...( o, d );

// State
//   0b0000_0001 Init
//   0b0000_0010 Hover
//   0b0000_0100 Select
//   0b0000_0110 Hoverselect
//   0b0000_1000 Drag
//   0b0001_0000 Drop
