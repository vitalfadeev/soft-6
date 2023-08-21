module cls.drawer;

import std : DList;
import bindbc.sdl;
import cls.o;
import types;


struct Drawer
{
    mixin OMixin;

    DList!DrawOp dops;

    static
    void Draw( O* o, Renderer* renderer, GridRect* drawRect )
    {
        _DrawDops( cast(Drawer*)o, renderer, drawRect );
    }
}

void _DrawDops( Drawer* o, Renderer* renderer, GridRect* drawRect )
{
    foreach( ref dop; o.dops )
    {
        switch ( dop.type )
        {
            case DTYPE.POINT : dop.p.Draw(  renderer, drawRect ); break;
            case DTYPE.LINE  : dop.l.Draw(   renderer, drawRect ); break;
            case DTYPE.RECT  : dop.r.Draw(   renderer, drawRect ); break;
            case DTYPE.CIRCLE: dop.c.Draw( renderer, drawRect ); break;
            default: 
        }
    }
}


enum DTYPE
{
    POINT,
    LINE,
    RECT,
    CIRCLE,
}

union DrawOp
{
    DTYPE      type;
    PointDraw  p;
    LineDraw   l;
    RectDraw   r;
    CircleDraw c;
}

struct PointDraw
{
    DTYPE type;
    Point p;

    void Draw( Renderer* renderer, GridRect* drawRect )
    {
        SDL_SetRenderDrawColor( renderer, 55, 55, 55, SDL_ALPHA_OPAQUE );
        SDL_RenderDrawPoint( renderer, p.x , p.y );
    }
}

struct LineDraw
{
    DTYPE type;
    Point p1;
    Point p2;

    void Draw( Renderer* renderer, GridRect* drawRect )
    {
        SDL_SetRenderDrawColor( renderer, 55, 55, 55, SDL_ALPHA_OPAQUE );
        SDL_RenderDrawLine( renderer, p1.x, p1.y, p2.x, p2.y );
    }
}

struct RectDraw
{
    DTYPE type;
    Point p1;
    Point p2;

    void Draw( Renderer* renderer, GridRect* drawRect )
    {
        SDL_Rect r = { p1.x, p1.y, p2.x-p1.x, p2.y-p1.y};

        SDL_SetRenderDrawColor( renderer, 55, 55, 55, SDL_ALPHA_OPAQUE );
        SDL_RenderDrawRect( renderer, &r );
    }
}

struct CircleDraw
{
    DTYPE type;
    Point p;
    Coord r;

    void Draw( Renderer* renderer, GridRect* drawRect )
    {
        import cls.spiro : Circle;

        Circle( renderer, p.x, p.y, r );
    }
}

struct Circle2pDraw
{
    DTYPE type;
    Point p1;
    Point p2;

    void Draw( Renderer* renderer, GridRect* drawRect )
    {
        import cls.spiro : Circle;

        Coord r = Geom.Len( p1, p2 );
        Circle( renderer, p1.x, p1.y, r );
    }
}

auto pow(T)( T a )
{
    return a*a;
}
auto sqrt(T)( T a )
{
    import std.math, std.conv;
    return std.math.sqrt( cast(float)a ).to!Coord;
}

struct Geom
{
    static
    auto Len( Point p1, Point p2 )
    {
        return sqrt( pow(p2.x-p1.x) + pow(p2.y-p1.y) );
    }
}
