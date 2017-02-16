---
title: How to debug python extensions
tags: python, gdb
language: russian
---

## Ubuntu

    sudo apt-get install python3-dev python3-dbg

Small example:

    gdb python3
    run
    import ctypes
    ctypes.strint_at(0)

There is a SIGSEGV. You can check stack trace:

    bt

On Ubuntu 16.04.2 I have gdb with version 7.11.1. It already includes [python
support](https://docs.python.org/devguide/gdb.html), so you can use commands
such as `py-bt` and `py-list`.

### Create an extension

Let's create a trivial python's extension. You can find more information in
[python docs](https://docs.python.org/3.5/extending/extending.html).

    mkdir src/py-ext

Create a file `spammodule.c`:
```c
#include <Python.h>

static PyObject *
spam_system(PyObject *self, PyObject *args)
{
    const char *command;
    int sts;

    if (!PyArg_ParseTuple(args, "s", &command))
        return NULL;
    sts = system(command);
    return PyLong_FromLong(sts);
}

static PyMethodDef SpamMethods[] = {
    {"system", spam_system, METH_VARARGS, "Execute a shell command."},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef spammodule = {
    PyModuleDef_HEAD_INIT,
    "spam",
    "documentation for spam module",
    -1,
    SpamMethods
};

PyMODINIT_FUNC
PyInit_spam(void)
{
    return PyModule_Create(&spammodule);
}
```

Create a file `setup.py`:
```python
from distutils.core import setup, Extension

module_name = 'spam'
setup(
        name = module_name,
        ext_modules = [Extension(module_name,
                                sources = ['spammodule.c'])],
     )
```

Create a file `test_spam.py`:

```python
import spam

spam.system("ls")
```

Build the extension with debug symbols:
```bash
python3 setup.py build -g
```

Install locally
```bash
python3 setup.py install --prefix ~/local
```
Make a link in the current directory, so python can import new module

```bash
ln -s local/lib/python3.5/site-packages/spam.cpython-35m-x86_64-linux-gnu.so ./
```

Let's set a breakpoint inside the extension.
```
gdb python3

(gdb) br spam_system
Function "spam_system" not defined.
Make breakpoint pending on future shared library load? (y or [n]) y
Breakpoint 1 (spam_system) pending.
(gdb) run test_spam.py
Starting program: /usr/bin/python3 test_spam.py
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Breakpoint 1, spam_system (self=<module at remote 0x7ffff6b70c78>, args=('ls',))
    at spammodule.c:5
5       {
(gdb) py-bt
Traceback (most recent call first):
  <built-in method system of module object at remote 0x7ffff6b70c78>
  File "test_spam.py", line 3, in <module>
    spam.system("ls")

(gdb) bt
#0  spam_system (self=<module at remote 0x7ffff6b70c78>, args=('ls',))
    at spammodule.c:5
#1  0x00000000004e9b9f in PyCFunction_Call () at ../Objects/methodobject.c:109
#2  0x0000000000524414 in call_function (oparg=<optimized out>,
    pp_stack=0x7fffffffe170) at ../Python/ceval.c:4705
#3  PyEval_EvalFrameEx () at ../Python/ceval.c:3236
#4  0x000000000052d2e3 in _PyEval_EvalCodeWithName () at ../Python/ceval.c:4018
#5  0x000000000052dfdf in PyEval_EvalCodeEx () at ../Python/ceval.c:4039
#6  PyEval_EvalCode (co=<optimized out>, globals=<optimized out>,
    locals=<optimized out>) at ../Python/ceval.c:777
#7  0x00000000005fd2c2 in run_mod () at ../Python/pythonrun.c:976
#8  0x00000000005ff76a in PyRun_FileExFlags () at ../Python/pythonrun.c:929
#9  0x00000000005ff95c in PyRun_SimpleFileExFlags ()
    at ../Python/pythonrun.c:396
#10 0x000000000063e7d6 in run_file (p_cf=0x7fffffffe3e0,
    filename=0xa730c0 L"test_spam.py", fp=0xadaca0) at ../Modules/main.c:318
#11 Py_Main () at ../Modules/main.c:768
#12 0x00000000004cfe41 in main () at ../Programs/python.c:65
#13 0x00007ffff7811830 in __libc_start_main (main=0x4cfd60 <main>, argc=2,
    argv=0x7fffffffe5f8, init=<optimized out>, fini=<optimized out>,
    rtld_fini=<optimized out>, stack_end=0x7fffffffe5e8)
    at ../csu/libc-start.c:291
#14 0x00000000005d5f29 in _start ()
```
## Mac

I tried to debug a python extension on mac, but failed. I could not set a
breakpoint or check stack trace. The issue is that `gdb` is incompatible with
Apples's dynamic linker dyld on Mac OS X Sierra. When you run `gdb`, you can see a warning `unhandled dyld version (15)`. The issue is elaborated in [this article](https://stefan.budeanu.com/mac-os-x-sierra-and-ruby-debugging-an-unhappy-marriage/).

# Reference

http://podoliaka.org/2016/04/10/debugging-cpython-gdb/
