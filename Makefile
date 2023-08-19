all:
	dub run

release:
	dub build --arch=x86_64  --compiler=ldc2.exe  --build=release

clean:
	rmdir /Q /S .dub
	del /Q *.exe
	del /Q *.pdb
	del /Q mixins.d
	del /Q dub.selections.json