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
        //writeln( mao.typeInfo.name );
        //writeln( mao.typeInfo.tsize );
        //writeln( mao.typeInfo.toString() );
        //writeln( mao.typeInfo.factory( mao.typeInfo.toString() ) );
    }

    void Go()
    {
        wrappers.Load( this.mao ); // wrappers.Load
        XSave( this.mao );
        this.view.Draw();
        this.mainLoop.Go();
       // on QUIT
    }
}
