module wrappers;

import std.stdio;
import bindbc.sdl;
import cls.o;
import types;


void SendArrange( O* o )
{
    Ars ar;
    ar.rect = o.rect;
    ar.arrangator = &Arrangator1;
    Send( o, XSDL_ARRANGE, &ar );
}

void SendArrangeEo( O* o )
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

    foreach( e; *o )
        Send( e, XSDL_ARRANGE, &ar );
}

void SendDraw( O* o, SDL_Renderer* renderer )
{
    Send( o, XSDL_DRAW, cast(void*)renderer );
}

void SendDrawInRect( O* o, SDL_Renderer* renderer, GridRect* rect )
{
    Send( o, XSDL_DRAWINRECT, cast(void*)renderer, cast(void*)rect );
}

void Slow( O* o )
{
    Send( o, XSDL_SLOW );
}

void SendDrag( O* o )
{
    Send( o, XSDL_DRAG );
}

void SendDrop( O* o )
{
    Send( o, XSDL_DROP );
}

void XSave(T : O)( T* o )
{
    ubyte[] result;
    wrappers.Save( cast(O*)o, 1, &result );
    import std.file;
    write( "xxx.sav", result );
}

void XLoad()
{
    import std.file;

    auto result = cast(ubyte[])read( "xxx.sav" );

    foreach (c; result)
    {
        if ( c == 'o' ) {}
        if ( c == 's' ) {}
        if ( c == 'a' ) {}
        if ( c == 'r' ) {}
    }
}

void Sensor( O* o, D* d )
{
    o._state.funcs.Sensor( o, d );
}

void Draw( O* o, SDL_Renderer* renderer, GridRect* drawRect )
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
