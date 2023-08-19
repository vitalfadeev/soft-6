module cls.o.hovers;

import bindbc.sdl;
import cls.o;
import colors : Pal, SDL_SetRenderDrawColorStruct;
import cls.o.inits;
import types;
import wrappers;


struct Hover
{
    mixin StateMixin;
    
    SDL_Color bg = Pal.Hovered;
    SDL_Color fg = Pal.Normal;


    static
    void Draw( O* o, SDL_Renderer* renderer, GridRect* drawRect )
    {
        _DrawBackground( o, renderer );
        Init._DrawGrid( o, renderer );
        Init._DrawLines( o, renderer );

        // recursive
        o.recursive!(wrappers.Draw)( renderer, drawRect );
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
        SDL_SetRenderDrawColorStruct( renderer, Pal.Hovered );
        SDL_RenderFillRect( renderer, &_rect );
    }


    static
    void go_Init( O* o, D* d )
    {
        auto motion   = d.motion;
        auto gridsize = o.gridsize;

        if ( d.type == SDL_MOUSEMOTION )
        {
            if ( o.Is( GridPoint( motion.x, motion.y, gridsize ) ) )
                Send( o, XSDL_OVER_MOUSE, d );
            else
            {
                Go!Init( o );
                Send( o, XSDL_OUT_MOUSE, d );
            }
        }
    }

    static
    void go_Hoverselect( O* o, D* d )
    {
        auto button = d.button;
        auto gridsize = o.gridsize;

        if ( d.type == SDL_MOUSEBUTTONDOWN )
        if ( button.button & SDL_BUTTON_LMASK ) 
        {
            auto mousePoint = GridPoint( d.motion.x, d.motion.y, gridsize );
            o.clickRel = mousePoint - o.point;
            if ( o.selectable )
                Go!Hoverselect( o );
        }
    }
}