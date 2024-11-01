#include <linux/init.h>
#include <linux/module.h>


static int __init init_function(void)
{
    printk(KERN_INFO "Hello, World\n");
    return 0;
}

static void __exit cleanup_function(void)
{
    printk(KERN_INFO "Goodbye, cruel world\n");
}

module_init(init_function);
module_exit(cleanup_function);

MODULE_AUTHOR("David Jensen");
MODULE_LICENSE("Dual MIT/GPL");