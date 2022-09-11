all: parent \
	 client 

parent: parent.c
	gcc -g -Wall parent.c -o parent -lpthread

client: client.c
	gcc -g -Wall client.c -o client -lpthread

clean:
	rm -f parent client
