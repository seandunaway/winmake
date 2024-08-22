#include <Windows.h>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
	MessageBox(NULL, TEXT("hello world"), NULL, MB_OK | MB_ICONINFORMATION);
	return 0;
}
