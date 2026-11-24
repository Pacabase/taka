#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

// Must match TakaBuild.
#ifdef TAKA_DEVELOPMENT
constexpr wchar_t kWindowMutex[] = L"Local\\com.pacabase.taka.dev.window";
constexpr wchar_t kWindowTitle[] = L"Taka Dev";
#else
constexpr wchar_t kWindowMutex[] = L"Local\\com.pacabase.taka.window";
constexpr wchar_t kWindowTitle[] = L"Taka";
#endif

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // The agent opens the window again to bring it forward, as on macOS and Linux.
  ::CreateMutex(nullptr, FALSE, kWindowMutex);
  if (::GetLastError() == ERROR_ALREADY_EXISTS) {
    if (HWND open = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", kWindowTitle)) {
      if (::IsIconic(open)) ::ShowWindow(open, SW_RESTORE);
      ::SetForegroundWindow(open);
    }
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(400, 480);
  if (!window.Create(kWindowTitle, origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
