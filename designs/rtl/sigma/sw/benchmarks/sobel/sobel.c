
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>

int main (int argc, char* argv[])
{

     int i;
     unsigned int * io_data = (unsigned int*)0x80000000;
     
     
     *(io_data++) = 0xe1ffd8ff;
     *(io_data++) = 0x78451600;
     *(io_data++) = 0x00006669;
     *(io_data++) = 0x2a004d4d;
     *(io_data++) = 0x08000000;
     *(io_data++) = 0x00000000;
     *(io_data++) = 0xdbff0000; 
     *(io_data++) = 0x03008400;
     *(io_data++) = 0x08080202; 
     *(io_data++) = 0x08080808;
     *(io_data++) = 0x08080808; 
     *(io_data++) = 0x08080808;
     *(io_data++) = 0x08080808; 
     *(io_data++) = 0x08080808;
     *(io_data++) = 0x08080808;
     *(io_data++) = 0x08080808; 
     *(io_data++) = 0x08080808;
     *(io_data++) = 0x08080808; 
     *(io_data++) = 0x08080808;
     *(io_data++) = 0x0808080a; 
     *(io_data++) = 0x0a0a0a08;
     *(io_data++) = 0x0d0b0808; 
     *(io_data++) = 0x080d080a;
     *(io_data++) = 0x01080a08; 
     *(io_data++) = 0x06040403;
     
       
     int * START_ADDR    = (int*) 0x80000ffc;
     *(START_ADDR) = 0x1;
          
     while (1);
     
}