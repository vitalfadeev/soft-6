import std.stdio;

void main()
{
	import game;
	import types;
	import cls.o;
	import cls.chips;

	auto mao = new Chips();
	mao.rect = GridRect( 0, 0, 12, 10 );
	new Game( cast(O*)mao ).Go();
}
