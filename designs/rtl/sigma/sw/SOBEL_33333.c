//#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
//#include <math.h>

int apply_sobel_filter(unsigned int image[10][10], unsigned int out[10][10]) {
    int kx[3][3] = { {-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1} };
    int ky[3][3] = { {-1, -2, -1}, {0, 0, 0}, {1, 2, 1} };

    int r, c, j, i, accx, accy, iml;
    int ox[10][10];
    int oy[10][10];
    for (r = 0; r < 10; r++) {
        for (c = 0; c < 10; c++) {
            accx = 0;
            accy = 0;


            for (j = 0; j < 3; j++) {
                for (i = 0; i < 3; i++) {
			for (iml = 0; iml < (int)image[r + (j - 1)][c + (i - 1)]; iml++)
				accx += (int)kx[j][i];           

			for (iml = 0; iml < (int)image[r + (j - 1)][c + (i - 1)]; iml++)
				accy += (int)kx[j][i];
                }
            }
            ox[r][c] = accx;
            oy[r][c] = accy;
        }
    }

    

    for (r = 0; r < 10; r++) {
        for (c = 0; c < 10; c++) {
            out[r][c] = ox[r][c] + oy[r][c];
        }
    }

    return 0;
}

int main(int argc, char* argv[]) {
	
    unsigned int * io_data = (unsigned int*)0x90000000;
    int i,j;
    unsigned int bitmapData[10][10] = { 0xff, 0xd8, 0xff, 0xe1, //0
                0x00, 0x16, 0x45, 0x78, //1
                0x69, 0x66, 0x00, 0x00, //2
                0x4d, 0x4d, 0x00, 0x2a, //3
                0x00, 0x00, 0x00, 0x08, //4
                0x00, 0x00, 0x00, 0x00, //5
                0x00, 0x00, 0xff, 0xdb, //6
                0x00, 0x84, 0x00, 0x03, //7
                0x02, 0x02, 0x08, 0x08, //8
                0x08, 0x08, 0x08, 0x08, //9
                0x08, 0x08, 0x08, 0x08, //10
                0x08, 0x08, 0x08, 0x08, //11
                0x08, 0x08, 0x08, 0x08, //12
                0x08, 0x08, 0x08, 0x08, //13
                0x08, 0x08, 0x08, 0x08, //14
                0x08, 0x08, 0x08, 0x08,	//15
                0x08, 0x08, 0x08, 0x08, //16
                0x08, 0x08, 0x08, 0x08, //17
                0x08, 0x08, 0x08, 0x08, //18
                0x0a, 0x08, 0x08, 0x08, //19
                0x08, 0x0a, 0x0a, 0x0a, //20
                0x08, 0x08, 0x0b, 0x0d, //21
                0x0a, 0x08, 0x0d, 0x08, //22
                0x08, 0x0a, 0x08, 0x01,	//23
                0x03, 0x04, 0x04, 0x06 };//24

    unsigned int out[10][10];
    int i2 = 0;

    
    apply_sobel_filter(bitmapData, out);


    for (i = 0; i < 10; i++) {
        for (j = 0; j < 10; j++) {
            *(io_data++) = (unsigned int) out[i][j];
        }
    }

    return 0;
}