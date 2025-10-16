#include <stdio.h>

#define N 4

int gauss_jordan(double A[N][N], double I[N][N]) {
    int i, j, k;
    double temp;

    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            if (i == j) 
                I[i][j] = 1;
            else
                I[i][j] = 0;
        }
    }

    for (i = 0; i < N; i++) {
        temp = A[i][i];

        printf("A[%d][%d] = %lf\n", i, i, temp);

        // Verifica se é válido
        if (temp == 0) {
            printf("Erro: Não é possível inverter a matriz.\n");
            return 0;
        }

        // Normaliza as matrizes
        for (j = 0; j < N; j++) {
            A[i][j] /= temp;
            I[i][j] /= temp;
        }

        for (j = 0; j < N; j++) {
            if (i != j) {
                temp = A[j][i];
                for (k = 0; k < N; k++) {
                    A[j][k] -= A[i][k] * temp;
                    I[j][k] -= I[i][k] * temp;
                }
            }
        }
    }

    return 1;
}

int main() {
    // double A[N][N] = {
    //     {5, -2, 1, 0, 1,5},
    //     {1, 4, 2, 1, 0,3},
    //     {2, 1, 4, -1, 2,-1},
    //     {0, 2, -1, 5, 1, 2},
    //     {1, 0, 2, 1, 4, 0},
    //     {5, 3, -1, 2, 0, 6}
    // };
    double A[N][N] = {
        {1,2,3,4},
        {2,3,4,5},
        {3,4,5,6},
        {4,5,6,7}
    };

    double I[N][N];

    if (gauss_jordan(A, I)) {
        printf("A matriz original é:\n");
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                printf("%lf ", A[i][j]);
            }
            printf("\n");
        }
        printf("A matriz identidade é:\n");
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                printf("%lf ", I[i][j]);
            }
            printf("\n");
        }
    } else {
        printf("Não foi possível calcular a inversa.\n");
    }

    return 0;
}
