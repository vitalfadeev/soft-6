module cls.chips;

import std.stdio;
import bindbc.sdl;
import cls.o;
import cls.chip;
import colors : Pal, SDL_SetRenderDrawColorStruct;
import types;
import wrappers;


struct Chips
{
    // Sensor
    // Draw from O
    // Load from state
    mixin OMixin!O;

    string fileName = "xxx.sav";

    // Sensor = auto-generated
    // Load   = &Init.Load
    //mixin StateMixin;

    static
    void Load( O* o )
    {
        import cls.chip.chipout;
        import cls.spiro;
        import cls : Ma;

        auto chip1 = Ma( "Chip" );
        chip1.rect = GridRect( 1, 1, 5, 2 );
        chip1.dragable = true;
        chip1.selectable = true;
        chip1.hoverable = true;
        chip1.Add( cast(O*)new ChipOut() );
        with (chip1.reo) { w = 1; h = 1; hoverable = true; }
        chip1.Add( cast(O*)new ChipOut() );
        with (chip1.reo) { w = 1; h = 1; hoverable = true; }
        chip1.Add( cast(O*)new ChipOut() );
        with (chip1.reo) { w = 1; h = 1; hoverable = true; }
        Arrange( cast(O*)chip1 );
        o.Add( cast(O*)chip1 );

        auto chip2 = new Chip();
        chip2.rect = GridRect( 1, 5, 5, 2 );
        chip2.dragable = true;
        chip2.selectable = true;
        chip2.hoverable = true;
        chip2.Add( cast(O*)new ChipOut() );
        with (chip2.reo) { w = 1; h = 1; hoverable = true; }
        chip2.Add( cast(O*)new ChipOut() );
        with (chip2.reo) { w = 1; h = 1; hoverable = true; }
        chip2.Add( cast(O*)new ChipOut() );
        with (chip2.reo) { w = 1; h = 1; hoverable = true; }
        Arrange( cast(O*)chip2 );
        o.Add( cast(O*)chip2 );

        auto spiro = new Spiro();
        spiro.rect = GridRect( 7, 3, 5, 2 );
        spiro.dragable = true;
        spiro.selectable = true;
        spiro.hoverable = true;
        Arrange( cast(O*)spiro );
        o.Add( cast(O*)spiro );
    }
}

