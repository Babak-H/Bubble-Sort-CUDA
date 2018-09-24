#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <cstdlib>
#include <stdio.h>
#include <ctime>
#include <limits>
#include <algorithm>
#include <Windows.h>

__global__ void SortGPU(int *a, int size)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x * 2;
	int cacheFirst;
	int cacheSecond;
	int cacheThird;

	for (int j = 0; j < size / 2 + 1; j++) 
	{

		if (i + 1 < size) 
		{
			cacheFirst = a[i];
			cacheSecond = a[i + 1];

			if (cacheFirst > cacheSecond) 
			{
				int temp = cacheFirst;
				a[i] = cacheSecond;
				cacheSecond = a[i + 1] = temp;
			}
		}

		if (i + 2 < size) 
		{
			cacheThird = a[i + 2];
			if (cacheSecond > cacheThird) {
				int temp = cacheSecond;
				a[i + 1] = cacheThird;
				a[i + 2] = temp;
			}
		}
		__syncthreads();
	}
}


using namespace std;

int main()
{
	//int A[6] = { 6,5,3,2,1,4 };
	//int n = sizeof(A) / sizeof(*A);
	const int count = 512;
	int *h_a = new int[count];

	for (int i = 0; i < count; i++)
	{
		h_a[i] = rand() % 10000;
	}

	int *d_a;
	cudaMalloc(&d_a, sizeof(int)*count);
	cudaMemcpy(d_a, h_a, sizeof(int)*count, cudaMemcpyHostToDevice);

	SortGPU<<<1, 256>>>(d_a, count);
	
	cudaMemcpy(h_a, d_a, sizeof(int)*count, cudaMemcpyDeviceToHost);
	 

	cudaFree(d_a);
	delete[] h_a;

	cudaDeviceReset();
	return 0;
}


void SortCPU(int A[], int count)
{
	int k = 0, x, y;

	for (k = 0; k < count - 1; k++)
	{
		for (int i = 0; i < count - 1 - k; i++)
		{
			int flag = 0;
			if (A[i] > A[i + 1])
			{
				x = A[i];
				y = A[i + 1];

				A[i] = y;
				A[i + 1] = x;
				flag = 1;
			}

			if (flag == 0)
			{
				break;
			}
		}
	}

	for (int i = 0; i < 6; i++)
	{
		cout << A[i] << endl;
	}
	cout << endl;
}
