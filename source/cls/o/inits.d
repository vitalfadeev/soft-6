module cls.o.inits;

import std.stdio;
import bindbc.sdl;
import cls.o;
import cls.o.hovers;
import colors : Pal, SDL_SetRenderDrawColorStruct;
import types;
import wrappers;


struct Init
{
    mixin StateMixin;

    Color bg = Pal.Black;
    Color fg = Pal.Normal;

    enum Arrange = &OArrange;
    enum Save = &OSave!O;

    static
    void Draw( O* o, Renderer* renderer, GridRect* drawRect )
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
        auto x = o.x;
        auto y = o.y;
        auto w = o.w;
        auto h = o.h;

        SDL_Rect _rect = { x*gridsize, y*gridsize, w*gridsize, h*gridsize };
        SDL_SetRenderDrawColorStruct( renderer, o.bg );
        SDL_RenderFillRect( renderer, &_rect );
    }

    static
    void _DrawGrid( O* o, Renderer* renderer )
    {
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
        auto x = o.x;
        auto y = o.y;
        auto w = o.w;
        auto h = o.h;

        auto x1 = x * gridsize;
        auto y1 = y * gridsize;
        auto x2 = (x+w) * gridsize;
        auto y2 = (y+h) * gridsize;

        SDL_SetRenderDrawColorStruct( renderer, o.fg );
        SDL_RenderDrawLine( renderer, x1, y1, x2, y2 ); // \
        SDL_RenderDrawLine( renderer, x1, y2, x2, y1 ); // /
    }

    static
    void on_SDL_MOUSEMOTION( O* o, D* d )
    {
        //
    }

    static
    void on_XSDL_IN_MOUSE( O* o, D* d ) 
    { 
        //
    }

    static
    void on_XSDL_OVER_MOUSE( O* o, D* d )
    { 
        //
    }

    static
    void on_XSDL_OUT_MOUSE( O* o, D* d )
    { 
        //
    }

    //
    static
    void on_XSDL_SLOW( O* o, D* d )
    {
        // to slowTo
        //   t = tb - ta
        //   l = b - a
        //   proc = curt / t
        //   p = a * proc

        // draw 
        //   point + slowMoOffset
    }


    // Ways
    static
    void to_Hover( O* o, D* d )
    {
        auto motion   = d.motion;

        if ( d.type == SDL_MOUSEMOTION )
        if ( o.Is( GridPoint( motion.x, motion.y, gridsize ) ) )
        if ( o.hoverable )
        {
            import cls.o.hovers : Hover;
            Go!Hover( o );
            Send( o, XSDL_IN_MOUSE, d );
        }
    }
}
