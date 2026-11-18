#include <sys/prctl.h>

#include "my_application.h"

int main(int argc, char** argv) {
  // ps and system monitors show this; the background agent is "Taka".
  prctl(PR_SET_NAME, "Taka Settings");
  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
