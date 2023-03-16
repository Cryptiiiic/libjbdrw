#import <Foundation/Foundation.h>
#include <libkrw/libkrw_plugin.h>
#include <libjailbreak/libjailbreak.h>

static int kbasehelper(uint64_t *kbase) {
    uint64_t slide = bootInfo_getUInt64(@"kernelslide");
    if(!slide) {
        printf("[!]: %s: Failed bootInfo_getUInt64 kernelslide! (Version: %d)\n", __func__, VERSION);
        return -1;
    }
    *kbase = slide + 0xFFFFFFF007004000;
    return 0;
}

static krw_kread_func_t kreadhelper(uint64_t kaddr, void* output, size_t size) {
    kreadbuf(kaddr, output, size);
    if(kaddr && size && !output) {
        return (krw_kread_func_t)-1;
    }
    return 0;
}

static krw_kwrite_func_t kwritehelper(uint64_t kaddr, const void* input, size_t size) {
    kwritebuf(kaddr, input, size);
    if(kaddr && size && !input) {
        return (krw_kwrite_func_t)-1;
    }
    return 0;
}
static krw_physread_func_t physreadhelper(uint64_t physaddr, void* output, size_t size) {
    physreadbuf(physaddr, output, size);
    if(physaddr && size && !output) {
        return (krw_physread_func_t)-1;
    }
    return 0;
}

static krw_physwrite_func_t physwritehelper(uint64_t physaddr, const void* input, size_t size) {
    physwritebuf(physaddr, input, size);
    if(physaddr && size && !input) {
        return (krw_physwrite_func_t)-1;
    }
    return 0;
}

__attribute__((used))
krw_plugin_initializer_t krw_initializer(krw_handlers_t handlers) {
    handlers->version = (uint64_t)(VERSION);
    int ret = jbdInitPPLRW();
    if(ret) {
        printf("[!]: %s: Failed jbdInitPPLRW! (Version: %llu)\n", __func__, handlers->version);
        return (krw_plugin_initializer_t)-1;
    }
    printf("[*]: %s: Successfully initialized jbdInitPPLRW! (Version: %llu)\n", __func__, handlers->version);

    handlers->kbase = (krw_kbase_func_t)(kbasehelper);
    handlers->kread = (krw_kread_func_t)(kreadhelper);
    handlers->kwrite = (krw_kwrite_func_t)(kwritehelper);
    handlers->kmalloc = (krw_kmalloc_func_t)(kalloc);
    handlers->kdealloc = (krw_kdealloc_func_t)(kfree);
    handlers->kcall = (krw_kcall_func_t)(jbdKcall);
    handlers->physread = (krw_physread_func_t)(physreadhelper);
    handlers->physwrite = (krw_physwrite_func_t)(physwritehelper);
    printf("[*]: %s: Successfully initialized jbdrw krw plugin! (Version: %llu)\n", __func__, handlers->version);
    return 0;
}
