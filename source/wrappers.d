module wrappers;

import std.stdio;
import bindbc.sdl;
import cls.o;
import types;


void SendSlow( O* o )
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
