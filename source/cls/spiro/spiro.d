module cls.spiro.spiro;

import bindbc.sdl;
import cls.o;
import colors : Pal, SetRenderDrawColorStruct;
import types;
import wrappers;


struct Spiro
{
    mixin OMixin!O;

    static
    void Draw( O* o, Renderer* renderer, GridRect* drawRect )
    {
        Init._DrawBackground( o, renderer );
        _DrawSpiro( o, renderer );

        // recursive
        o.recursive!(cls.o.Draw)( renderer, drawRect );
    }


    static
    void _DrawSpiro( O* o, Renderer* renderer )
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

        int cx = x1 + (x2-x1)/2;
        int cy = y1 + (y2-y1)/2;
        int r = 50;

        SetRenderDrawColorStruct( renderer, o.fg );
        //Circle( renderer, cx, cy, r );
        DrawSpiro( renderer, cx, cy, r );
    }
}

void Circle( Renderer* renderer, int cx, int cy, int r )
{
    int x;
    int y = r;
    int delta = 1 - 2 * r;
    int error = 0;

    while ( y >= x )
    {
        Drawpixel( renderer, cx + x, cy + y );
        Drawpixel( renderer, cx + x, cy - y );
        Drawpixel( renderer, cx - x, cy + y );
        Drawpixel( renderer, cx - x, cy - y );
        Drawpixel( renderer, cx + y, cy + x );
        Drawpixel( renderer, cx + y, cy - x );
        Drawpixel( renderer, cx - y, cy + x );
        Drawpixel( renderer, cx - y, cy - x );

        error = 2 * (delta + y) - 1;

        if ( (delta < 0) && (error <= 0) )
        {
            x++;
            delta += (2 * x + 1);
            continue;
        }

        if ( (delta > 0) && (error > 0) )
        {
            y--;
            delta -= (2 * y + 1);
            continue;
        }

        x++;
        y--;
        delta += (2 * (x - y));
    }
}

pragma( inline, true )
void Drawpixel( Renderer* renderer, int x, int y )
{
    SDL_RenderDrawPoint( renderer, x , y );
}

void DrawSpiro( Renderer* renderer, int cx, int cy, int r )
{
    //  3 | 2
    // ---+---
    //  4 | 1
    import std.math;
    import std.conv;

    int x = 0;
    int y = r;

    int rr = r*r;
    int xx = x*x;
    int yy = y*y;

    // 1. 1/8
    while ( x < y )
    {
        Drawpixel( renderer, cx + x, cy + y );

        x++;
        xx = x*x;
        while ( xx + yy > rr )
        {
            y --;
            yy = y*y;
        }
    }

    // 1. 2/8
    while ( y > 0 )
    {
        Drawpixel( renderer, cx + x, cy + y );

        y--;
        yy = y*y;
        while ( xx + yy < rr )
        {
            x ++;
            xx = x*x;
        }
    }

    // 2. 3/8
    while ( -y < x )
    {
        Drawpixel( renderer, cx + x, cy + y );

        y--;
        yy = y*y;
        while ( xx + yy > rr )
        {
            x --;
            xx = x*x;
        }
    }

    // 2. 4/8
    while ( x > 0 )
    {
        Drawpixel( renderer, cx + x, cy + y );

        x--;
        xx = x*x;
        while ( xx + yy < rr )
        {
            y --;
            yy = y*y;
        }
    }

    // 3. 5/8
    while ( -x > y )
    {
        Drawpixel( renderer, cx + x, cy + y );

        x--;
        xx = x*x;
        while ( xx + yy > rr )
        {
            y ++;
            yy = y*y;
        }
    }

    // 3. 6/8
    while ( -y > 0 )
    {
        Drawpixel( renderer, cx + x, cy + y );

        y++;
        yy = y*y;
        while ( xx + yy < rr )
        {
            x --;
            xx = x*x;
        }
    }
}

