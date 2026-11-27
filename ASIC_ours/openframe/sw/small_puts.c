// small_puts.c: puts() without the C library's buffered stdio.
//
// The test programs print with puts(). The C library's puts() brings in the
// FILE machinery and malloc: with full newlib that is 9 kbyte of code and
// 2 kbyte of initialised data, with newlib-nano still 3 kbyte. The programs
// themselves are a few hundred bytes. This version hands the string straight to
// _write(), the same low-level routine the library ends up calling, so the
// bytes on the UART are the same.
//
// Compile it with the program (it must come before the library on the link
// line, which it does when it is passed as a source file). See ../README.md,
// "Firmware size".
extern int _write(int fd, char *ptr, int len);

int puts(const char *s)
{
    int n = 0;
    while (s[n]) n++;
    _write(1, (char *)s, n);
    _write(1, (char *)"\n", 1);
    return 0;
}
