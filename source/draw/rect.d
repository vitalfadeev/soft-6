module draw.rect;

import bindbc.sdl;
import types;


void Rect( Renderer* renderer, int x, int y, int w, int h )
{
    SDL_Rect r = { x, y, w, h };
    SDL_RenderDrawRect( renderer, &r );
}

void Rect( Renderer* renderer, types.Rect* r )
{
    SDL_RenderDrawRect( renderer, r );
}
