all: mega

c64:
	./make-c64.sh

mega:
	./make-mega.sh

clean:
	rm -f *d81 *bas *prg
