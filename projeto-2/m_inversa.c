#include <stdio.h>

#define N 3

void swapRows(double A[N][N], double I[N][N], int i, int j) {
    for (int k = 0; k < N; k++) {
        // Troca os elementos da matriz A
        double temp = A[i][k];
        A[i][k] = A[j][k];
        A[j][k] = temp;

        // Troca os elementos da matriz I
        temp = I[i][k];
        I[i][k] = I[j][k];
        I[j][k] = temp;
    }
}

int gauss_jordan(double A[N][N], double I[N][N]) {
    int i, j, k;
    double temp;

    // Cria a matriz identidade
    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            if (i == j) 
                I[i][j] = 1;
            else
                I[i][j] = 0;
        }
    }

    // Processo de Gauss-Jordan
    for (i = 0; i < N; i++) {

        // Pega o elemento pivô
        temp = A[i][i];

        // Verifica se o pivô é válido -> não pode ser 0
        if (temp == 0) {
            // Se o pivô for 0, procura uma linha abaixo para trocar
            int found = 0;
            for (int j = i + 1; j < N && !found; j++) {
                if (A[j][i] != 0) {
                    // Se o elemento da proxima linha for diferente de 0, troca as linhas
                    swapRows(A, I, i, j);
                    found = 1; // Indica que vai interromper o loop
                }
            }
            if (!found) {
                // Se não encontrou nenhum elemento válido, a matriz não é invertível, retorna erro
                // Exemplo de matriz não invertível:
                // 1 2 3
                // 4 5 6
                // 7 8 9
                printf("Erro: Não é possível inverter a matriz.\n");
                return 0;
            }
        }

        // Atualiza o pivô após possível troca de linhas
        temp = A[i][i];

        // Normaliza as matrizes relativo ao pivô
        for (j = 0; j < N; j++) {
            A[i][j] /= temp;
            I[i][j] /= temp;
        }

        // Elimina os outros elementos acima e abaixo do pivô
        for (j = 0; j < N; j++) {
            if (i != j) {
                // Caso não seja a linha do pivô
                temp = A[j][i];
                for (k = 0; k < N; k++) {
                    // Remove iterativamente os elementos
                    A[j][k] -= A[i][k] * temp;
                    I[j][k] -= I[i][k] * temp;
                }
            }
        }
    }

    return 1;
}

int main() {
    double A[N][N] = {
        {1,2,3},
        {4,5,6},
        {7,8,9}
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
