#import <Foundation/Foundation.h>
#include <libkrw/libkrw_plugin.h>
#include <libjailbreak/libjailbreak.h>

static int kbasehelper(uint64_t *kbase) {
    uint64_t slide = bootInfo_getUInt64(@"kernelslide");
    if(!slide) {
        JBLogDebug("[!]: %s: %s: Failed bootInfo_getUInt64 kernelslide! (Version: %d)\n", __FILE__, __func__, VERSION);
        return -1;
    }
    *kbase = slide + 0xFFFFFFF007004000;
    return 0;
}

static bool jbd_is_initialized = false;

__attribute__((used))
krw_plugin_initializer_t krw_initializer(krw_handlers_t handlers) {
    handlers->version = (uint64_t)(VERSION);
    if(!jbd_is_initialized) {
      int ret = jbdInitPPLRW();
      if(ret) {
          JBLogDebug("[!]: %s: %s: Failed jbdInitPPLRW! (Version: %llu)\n", __FILE__, __func__, handlers->version);
          return (krw_plugin_initializer_t)-1;
      }
      jbd_is_initialized = true;
      JBLogDebug("[*]: %s: %s: Successfully initialized jbdInitPPLRW! (Version: %llu)\n", __FILE__, __func__, handlers->version);
    }

    handlers->kbase = (krw_kbase_func_t)(kbasehelper);
    handlers->kread = (krw_kread_func_t)(kreadbuf);
    handlers->kwrite = (krw_kwrite_func_t)(kwritebuf);
    handlers->kmalloc = (krw_kmalloc_func_t)(kalloc);
    handlers->kdealloc = (krw_kdealloc_func_t)(kfree);
    JBLogDebug("[*]: %s: %s: Successfully initialized jbdrw krw plugin! (Version: %llu)\n", __FILE__, __func__, handlers->version);
    return 0;
}

__attribute__((used))
krw_plugin_initializer_t kcall_initializer(krw_handlers_t handlers) {
  if(!jbd_is_initialized) {
    int ret = jbdInitPPLRW();
    if(ret) {
        JBLogDebug("[!]: %s: %s: Failed jbdInitPPLRW! (Version: %llu)\n", __FILE__, __func__, handlers->version);
        return (krw_plugin_initializer_t)-1;
    }
    jbd_is_initialized = true;
    JBLogDebug("[*]: %s: %s: Successfully initialized jbdInitPPLRW! (Version: %llu)\n", __FILE__, __func__, handlers->version);
  }
  handlers->kcall = (krw_kcall_func_t)(jbdKcall);
  handlers->physread = (krw_physread_func_t)(physreadbuf);
  handlers->physwrite = (krw_physwrite_func_t)(physwritebuf);
  JBLogDebug("[*]: %s: %s: Successfully initialized jbdrw krw plugin! (Version: %llu)\n", __FILE__, __func__, handlers->version);
  return 0;
}

