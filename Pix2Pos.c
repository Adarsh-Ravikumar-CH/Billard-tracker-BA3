/*
 * Project: Billard 2025
 * File: Pix2Pos.c
 * Description: Extraction of billiard ball positions from Pixmap.bin
 *              based on color detection and scoring.
 *
 * Authors:
 *   Arun Gemsch
 *   Leon Kesslering
 *   Adarsh Ravikumar
 *   Patrick Stadler
 *
 * Date: 2025-12-27
 */


#include <stdio.h>
#include <stdlib.h>

#define EXPECTED_PARAMS 29 //we expect 29 parameters in comand line
const int BallminScore = 15 ; //minmal score to detect ball


//Function that extracts r,g,b components
void extractRGB(unsigned int color, unsigned char *r, unsigned char *g, unsigned char *b) {
    *r = (color >> 16) & 0xFF;  // Bits 23–16 - red
    *g = (color >> 8)  & 0xFF;  // Bits 15–8  - green
    *b =  color        & 0xFF;  // Bits 7–0   - blue
}

//function that checks if pixels is in given color range, gives back 1 (true) when it is, gives back 0 (false) if it isn't
//functions takes one color (r,g,b)(first 3 variables) and takes bounds for r,g,b (next 6 variabels)
int isColorInRange(unsigned char r, unsigned char g, unsigned char b,
    const unsigned char rMin, const unsigned char rMax,
    const unsigned char gMin, const unsigned char gMax,
    const unsigned char bMin, const unsigned char bMax)
{
    if (r < rMin || r > rMax) return 0;
    if (g < gMin || g > gMax) return 0;
    if (b < bMin || b > bMax) return 0;
    return 1;
}

//function that checks if a pixel has background color
// Gives back 1, if pixel has backgorund color
int isBackground(unsigned int color,
    unsigned char RbMin, unsigned char RbMax,
    unsigned char GbMin, unsigned char GbMax,
    unsigned char BbMin, unsigned char BbMax)
{
    unsigned char r, g, b;
    extractRGB(color, &r, &g, &b);
    return isColorInRange(r, g, b, RbMin, RbMax, GbMin, GbMax, BbMin, BbMax);
}


//function that test all pixel in a given square and counts how many are in color range
//gives back score, or if square is outside of image it gives back -1
int testSquare(unsigned int **matrix, int matrixwith, int matrixheight, int ballsize, int startX, int startY,
    unsigned char rMin, unsigned char rMax,
    unsigned char gMin, unsigned char gMax,
    unsigned char bMin, unsigned char bMax)
    {
        int score = 0;

        //test if square is in image
        if (startX + ballsize > matrixwith || startY + ballsize > matrixheight) {
            return -1;
        }

        //go trough all pixel in the square
        for (int y = startY; y < startY + ballsize; y++) {
            for (int x = startX; x < startX + ballsize; x++) {

                unsigned char r, g, b;
                extractRGB(matrix[y][x], &r, &g, &b); //decompose pixel in rgb with help of func extractRGB

                if (isColorInRange(r, g, b, rMin, rMax, gMin, gMax, bMin, bMax)) {
                    score ++;
                }
            }
        }
        return score;
    }

int main(int argc, char *argv[]) { //argc reads parameters
    //checks if there is correct number of parameters; argc[0] is name of program -> so +1
    if (argc != EXPECTED_PARAMS + 1) { // +1 due to argv[0] (name of program)
        fprintf(stderr, "Error: Expected %d parameters, got %d.\n Execution of the program not possible — please enter the correct number of parameters.", EXPECTED_PARAMS, argc - 1);
        return 1;
    } // stops Program if number of parameters is incorrect

    //convert parameters into numbers.
    // ────────────────────────────────────────────────
    // 1. BillardBox
    // ────────────────────────────────────────────────
    int Lmin = atoi(argv[1]);
    int Lmax = atoi(argv[2]);
    int Cmin = atoi(argv[3]);
    int Cmax = atoi(argv[4]);

    // ────────────────────────────────────────────────
    // 2. Red Ball
    // ────────────────────────────────────────────────
    unsigned char RrMin = (unsigned char)atoi(argv[5]);
    unsigned char RrMax = (unsigned char)atoi(argv[6]);
    unsigned char GrMin = (unsigned char)atoi(argv[7]);
    unsigned char GrMax = (unsigned char)atoi(argv[8]);
    unsigned char BrMin = (unsigned char)atoi(argv[9]);
    unsigned char BrMax = (unsigned char)atoi(argv[10]);

    // ────────────────────────────────────────────────
    // 3. Yellow Ball
    // ────────────────────────────────────────────────
    unsigned char RyMin = (unsigned char)atoi(argv[11]);
    unsigned char RyMax = (unsigned char)atoi(argv[12]);
    unsigned char GyMin = (unsigned char)atoi(argv[13]);
    unsigned char GyMax = (unsigned char)atoi(argv[14]);
    unsigned char ByMin = (unsigned char)atoi(argv[15]);
    unsigned char ByMax = (unsigned char)atoi(argv[16]);

    // ────────────────────────────────────────────────
    // 4. White Ball
    // ────────────────────────────────────────────────
    unsigned char RwMin = (unsigned char)atoi(argv[17]);
    unsigned char RwMax = (unsigned char)atoi(argv[18]);
    unsigned char GwMin = (unsigned char)atoi(argv[19]);
    unsigned char GwMax = (unsigned char)atoi(argv[20]);
    unsigned char BwMin = (unsigned char)atoi(argv[21]);
    unsigned char BwMax = (unsigned char)atoi(argv[22]);

    // ────────────────────────────────────────────────
    // 5. Blue Background 
    // ────────────────────────────────────────────────
    unsigned char RbMin = (unsigned char)atoi(argv[23]);
    unsigned char RbMax = (unsigned char)atoi(argv[24]);
    unsigned char GbMin = (unsigned char)atoi(argv[25]);
    unsigned char GbMax = (unsigned char)atoi(argv[26]);
    unsigned char BbMin = (unsigned char)atoi(argv[27]);
    unsigned char BbMax = (unsigned char)atoi(argv[28]);

    // ────────────────────────────────────────────────
    // 6. Ball Diameter
    // ────────────────────────────────────────────────
    int BallDiameter = atoi(argv[29]);

    //checks if ballsize (named here: balldiameter) is within the bounds
    if (BallDiameter < 10 || BallDiameter > 15) {
        fprintf(stderr,
            "Error: BallSize (%d) is out of bounds. Stop program. "
            "The diameter of the ball must be between 10 and 15 pixels.\n",
            BallDiameter);
        return 1; // stops program
    }

    //open pixmap.bin
    FILE *fp = fopen("Pixmap.bin", "rb"); // "rb" = read binary
    if (fp == NULL) {
        fprintf(stderr, "Error: Pixmap.bin couldn't be opened. Program stops\n"); // Tests whether pixmap.bin could be opened.
        return 1; //stops program
    }

    //read with and height (first 2 parameters)
    unsigned int width_pixmap, height_pixmap;

    //checks if width_pixmap and height_pixmap are valid
    if (fread(&width_pixmap, sizeof(unsigned int), 1, fp) != 1 || fread(&height_pixmap, sizeof(unsigned int), 1, fp) != 1) { //now filepointer is befor 1. pixel
        fprintf(stderr, "Error: could not read width/height from Pixmap.bin. Program stops.\n");
        fclose(fp);
        return 1;
    }

    //checks if width and height are within bounds, if not program will stop
    if (width_pixmap < 100 || width_pixmap > 1000 || height_pixmap < 100 || height_pixmap > 1000) {
        fprintf(stderr, "Error: Program will stop. Width or height out of bounds: width x height = (%u x %u)\n", width_pixmap, height_pixmap);
        fclose(fp);
        return 1;
    }

    //Check if Lmin, Lmax, Cmin, Cmax are within logical bounds
    if (Lmin < 0 || Cmin < 0 || Lmin > Lmax || Cmin > Cmax) {
        fprintf(stderr, "Error: Invalid billiard box values (min > max or negative values). Program stops. \n");
        fclose(fp); 
        return 1;
    }

    //Check if Lmin, Lmax, Cmin, Cmax are within image dimensions
    if (Lmax > (int)height_pixmap || Cmax > (int)width_pixmap) {
        fprintf(stderr, "Error: Billiard box is outside the image bounds (Lmax=%d, Cmax=%d, image height=%u, image width=%u).\n", Lmax, Cmax, height_pixmap, width_pixmap);
        fclose(fp);
        return 1;
    }

    //creat 2D matrix
    unsigned int **matrix = malloc(height_pixmap * sizeof(unsigned int*));
    if (matrix == NULL) { //allocation of the row pointer array failed. -> Stops Program
        fprintf(stderr, "Error: Matrix couldn't be allocated. Program stops. \n");
        fclose(fp);
        return 1;
    }
    for (unsigned int y = 0; y < height_pixmap; y++) {
        matrix[y] = malloc(width_pixmap * sizeof(unsigned int));
        if (matrix[y] == NULL) { //allocation of a matrix row failed. -> stops program.
            fprintf(stderr, "Error: Row could not be allocated. Program stops. %u.\n", y);
            // Previously allocated rows are freed to avoid memory leaks
            for (unsigned int i = 0; i < y; i++) {
                free(matrix[i]);
            }
            free(matrix);
            fclose(fp);
            return 1;
        }
    }

    unsigned int total_pixels_read = 0; //pixel counter

    //read pixels form pixmap.bin and store them in matrix
    for (unsigned int y = 0; y < height_pixmap; y++) { //for first loop y=0, i reads the first row since it starts at 1. pixel and gos width_pixmap amount of pixels trough
        unsigned int read_count = fread(matrix[y], sizeof(unsigned int), width_pixmap, fp); //for 2. loop it does the same but now y=1, so we are 1 row deeper.
        total_pixels_read += read_count;
    }


    unsigned int expected_pixels = width_pixmap * height_pixmap;
    //only read expected amount of pixels (with*height) since matrix is only this size. So we have to check if there are still pixels in file. if so, then we know that number of Pixels in file is bigger than with*height
    int extra = fgetc(fp); //if we have reached end of file, this gives back EOF.
    if (extra != EOF) {
        fprintf(stderr, "Warning: file contains extra data after expected pixels.\n"
        "These additional pixels will be ignored, as the program only reads "
        "the first %u × %u = %u pixels.\n"
        "Note: The output may not match the expected result. \n",
        width_pixmap, height_pixmap, expected_pixels);
    }

    fclose(fp); // close file

    // check if to few pixels were read -> stop program
    if (total_pixels_read < expected_pixels) {
        fprintf(stderr, "Error: only %u of %u expected pixels were read. File may be incomplete. Program stops. \n", total_pixels_read, expected_pixels);
        // Free memory
        for (unsigned int i = 0; i < height_pixmap; i++) {
            free(matrix[i]);
        }
        free(matrix);
        return 1;
    }


    int bestScoreRed = 0, bestScoreYellow = 0, bestScoreWhite = 0;
    int bestX_R = -1, bestY_R = -1;
    int bestX_Y = -1, bestY_Y = -1;
    int bestX_W = -1, bestY_W = -1;


    //For all balls calculate best coordiinates with function that checks if pixel in middel of ballsize square has backgorund color
    for (int x = Cmin; x <= Cmax - BallDiameter; x++) {
        for (int y = Lmin; y <= Lmax - BallDiameter; y++) {
            int centerX = x + (BallDiameter / 2);
            int centerY = y + (BallDiameter / 2);
            if (isBackground(matrix[centerY][centerX], RbMin, RbMax, GbMin, GbMax, BbMin, BbMax))
                continue;

            int scoreRed = testSquare(matrix, width_pixmap, height_pixmap, BallDiameter, x, y, RrMin, RrMax, GrMin, GrMax, BrMin, BrMax);
            if (scoreRed > bestScoreRed) { 
                bestScoreRed = scoreRed;
                bestX_R = x;
                bestY_R = y;
            }

            int scoreYellow = testSquare(matrix, width_pixmap, height_pixmap, BallDiameter, x, y, RyMin, RyMax, GyMin, GyMax, ByMin, ByMax);
            if (scoreYellow > bestScoreYellow) {
                bestScoreYellow = scoreYellow;
                bestX_Y = x;
                bestY_Y = y;
            }

            int scoreWhite = testSquare(matrix, width_pixmap, height_pixmap, BallDiameter, x, y, RwMin, RwMax, GwMin, GwMax, BwMin, BwMax);
            if (scoreWhite > bestScoreWhite) {
                bestScoreWhite = scoreWhite;
                bestX_W = x;
                bestY_W = y; }
        }
    }

    //test if score is sufficient (is score higher than minimal required pixels)
    if (bestScoreRed < BallminScore) {
        fprintf(stderr,
            "Warning: The red ball was not detected (score = %d < minimum = %d).\n"
            "Coordinates set to (-1, -1) and score to 0.\n",
            bestScoreRed, BallminScore);
        bestX_R = -1;
        bestY_R = -1;
        bestScoreRed = 0;
    }

    if (bestScoreYellow < BallminScore) {
        fprintf(stderr,
            "Warning: The yellow ball was not detected (score = %d < minimum = %d).\n"
            "Coordinates set to (-1, -1) and score to 0.\n",
            bestScoreYellow, BallminScore);
        bestX_Y = -1;
        bestY_Y = -1;
        bestScoreYellow = 0;
    }

    if (bestScoreWhite < BallminScore) {
        fprintf(stderr,
            "Warning: The white ball was not detected (score = %d < minimum = %d).\n"
            "Coordinates set to (-1, -1) and score to 0.\n",
            bestScoreWhite, BallminScore);
        bestX_W = -1;
        bestY_W = -1;
        bestScoreWhite = 0;
    }

    //write results in pos.tex
    FILE *out = fopen("Pos.txt", "w");
    if (!out) {
        fprintf(stderr, "Error: Error: Unable to open Pos.txt for writing. Program stops. \n");
        for (unsigned int y = 0; y < height_pixmap; y++) free(matrix[y]);
        free(matrix); //free memory for the case that pox.txt couldn't be opened
        return 1;
    }
    fprintf(out, "Red: %d, %d, %d\n", bestX_R, bestY_R, bestScoreRed);
    fprintf(out, "Yellow: %d, %d, %d\n", bestX_Y, bestY_Y, bestScoreYellow);
    fprintf(out, "White: %d, %d, %d\n", bestX_W, bestY_W, bestScoreWhite);
    fclose(out);

    //free memory
    for (unsigned int y = 0; y < height_pixmap; y++) free(matrix[y]);
    free(matrix);
    return 0;
}