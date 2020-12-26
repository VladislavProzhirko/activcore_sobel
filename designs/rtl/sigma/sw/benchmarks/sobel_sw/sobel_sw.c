#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>


int apply_sobel_filter(unsigned int image[4][4], unsigned int out[4][4]) {
    int kx[3][3] = { {-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1} };
    int ky[3][3] = { {-1, -2, -1}, {0, 0, 0}, {1, 2, 1} };

    int r, c, j, i, accx, accy, iml;
    int ox[4][4];
    int oy[4][4];
    for (r = 0; r < 4; r++) {
        for (c = 0; c < 4; c++) {
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

    for (r = 0; r < 4; r++) {
        for (c = 0; c < 4; c++) {
            out[r][c] = ox[r][c] + oy[r][c];
        }
    }

    return 0;
}

int main(int argc, char* argv[]) {

    unsigned int * io_data = (unsigned int*)0x90000000;
    int i,j;
    unsigned int bitmapData[4][4] = { 
		0xff, 0xd8, 0xff, 0xe1, //0
                0x00, 0x16, 0x45, 0x78, //1
                0x69, 0x66, 0x00, 0x00, //2
                0x4d, 0x4d, 0x00, 0x2a};//4

    unsigned int out[4][4];
    int i2 = 0;
    *((volatile unsigned int*)0x80000000) = 0x0;
    apply_sobel_filter(bitmapData, out);
    
    for (i = 0; i < 4; i++) {
        for (j = 0; j < 4; j++) {
            *(io_data++) = (unsigned int) out[i][j];
        }
    }
	

    *((volatile unsigned int*) 0x80000000) = 0xffffffff;

    return 0;
}