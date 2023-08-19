module colors;

import bindbc.sdl;
import types;


enum Pal : SDL_Color
{
    Black  =   SDL_Color(   0,   0,   0, SDL_ALPHA_OPAQUE ),
    Grey   =   SDL_Color(  60,  60,  60, SDL_ALPHA_OPAQUE ),
    Normal =   SDL_Color( 199, 199, 199, SDL_ALPHA_OPAQUE ),
    Selected = SDL_Color(  99, 199,  99, SDL_ALPHA_OPAQUE ),
    Hovered =  SDL_Color(  99,  99,  99, SDL_ALPHA_OPAQUE ),
    Drag =     SDL_Color( 199,  99,  99, SDL_ALPHA_OPAQUE ),
    Drop =     SDL_Color( 199, 199,  99, SDL_ALPHA_OPAQUE ),
};

auto SDL_SetRenderDrawColorStruct(TR)( TR renderer, Pal color )
{
    SDL_SetRenderDrawColor( renderer, color.r, color.g, color.b, color.a );
}
auto SDL_SetRenderDrawColorStruct(TR)( TR renderer, SDL_Color color )
{
    SDL_SetRenderDrawColor( renderer, color.r, color.g, color.b, color.a );
}
