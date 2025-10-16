#include <stdio.h>

#define N 4

void swapRows(double A[N][N], double I[N][N], int row1, int row2) {
    for (int i = 0; i < N; i++) {
        double temp = A[row1][i];
        A[row1][i] = A[row2][i];
        A[row2][i] = temp;

        temp = I[row1][i];
        I[row1][i] = I[row2][i];
        I[row2][i] = temp;
    }
}

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
            int found = 0;
            for (int j = i + 1; j < N; j++) {
                if (A[j][i] != 0) {
                    swapRows(A, I, i, j);
                    found = 1;
                    break;
                }
            }
            if (!found) {
                printf("Erro: Não é possível inverter a matriz.\n");
                return 0;  // Matriz não é invertível
            }
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
        {4, 7, 2, 3},
        {3, 5, 1, 2},
        {2, 6, 3, 1},
        {1, 2, 4, 7}
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
