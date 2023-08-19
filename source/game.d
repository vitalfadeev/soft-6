module game;
/* Game Engine */


import std.algorithm;
import std.range;
import std.conv;
import std.format;
import std.stdio;
import std.traits;
import bindbc.sdl;
import cls.o;
import view;
import mainloop;
import types;
import wrappers;


struct Game
{
    O*        mao;
    View*     view;
    MainLoop* mainLoop;

    this( O* mao )
    {
        this.mao      = mao;
        this.view     = new View( &this );
        this.mainLoop = new MainLoop( &this );
    }

    void Go()
    {
        this.mao.Load(); // wrappers.Load
        this.mao.XSave(); // wrappers.XSave
        this.view.Draw();
        this.mainLoop.Go();
       // on QUIT
    }
}
