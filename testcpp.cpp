extern "C"
{
#include "importc_bitfields.c"
}

#include <stdio.h>
#include <string.h>

template<typename T>
size_t getStructSize();
template<typename T>
size_t getStructAlign();
template<typename T>
void resetBitfield(T &data, const char *member);

#define BEGIN_STRUCT(S) \
    template<> \
    size_t getStructSize<S>() \
    { \
        return sizeof(S); \
    } \
    template<> \
    size_t getStructAlign<S>() \
    { \
        return alignof(S); \
    } \
    template<> \
    void resetBitfield<S>(S &data, const char *member) \
    {

#define FIELD(name) if (strcmp(member, #name) == 0) data.name = 0;
#define END_STRUCT }


// cat importc_bitfields.c | sed "s/struct \([a-zA-Z0-9]*\)\s*{\s*/BEGIN_STRUCT(\1) /g" | sed "s/[^;,()]* \([a-zA-Z0-9]*\)\s*\(:\s*[0-9]*\)\?\s*[,;]/ FIELD(\1)/g" | sed "s/ FIELD()//g" | sed "s/};/END_STRUCT/g"

BEGIN_STRUCT(T0) FIELD(x) END_STRUCT
BEGIN_STRUCT(T1) FIELD(x) END_STRUCT
BEGIN_STRUCT(T2) FIELD(x) END_STRUCT
BEGIN_STRUCT(T3) FIELD(a) FIELD(b) FIELD(c) FIELD(d) FIELD(x) END_STRUCT
BEGIN_STRUCT(T4) FIELD(a) FIELD(b) FIELD(c) FIELD(d) FIELD(e) FIELD(f) FIELD(g) FIELD(h) FIELD(x) END_STRUCT
BEGIN_STRUCT(T5) FIELD(a) FIELD(b) FIELD(c) FIELD(d) FIELD(e) FIELD(f) FIELD(g) FIELD(x) END_STRUCT
BEGIN_STRUCT(S1) FIELD(f) END_STRUCT
BEGIN_STRUCT(S2) FIELD(x) FIELD(y) END_STRUCT
BEGIN_STRUCT(S3) FIELD(c) FIELD(x) FIELD(y) END_STRUCT
BEGIN_STRUCT(S4) FIELD(x) FIELD(y) END_STRUCT
BEGIN_STRUCT(S5) FIELD(x) FIELD(y) END_STRUCT
BEGIN_STRUCT(S6) FIELD(x) FIELD(y) END_STRUCT
BEGIN_STRUCT(S7) FIELD(x) FIELD(y) FIELD(z) END_STRUCT
BEGIN_STRUCT(S8) FIELD(a) FIELD(b) FIELD(c) END_STRUCT
BEGIN_STRUCT(S8A) FIELD(b) FIELD(c) END_STRUCT
BEGIN_STRUCT(S8B) FIELD(a) FIELD(b) FIELD(c) END_STRUCT
BEGIN_STRUCT(S8C) FIELD(a) FIELD(b) END_STRUCT
BEGIN_STRUCT(S9) FIELD(a) FIELD(b) FIELD(c) END_STRUCT
//BEGIN_STRUCT(S10) END_STRUCT
//BEGIN_STRUCT(S11) END_STRUCT
BEGIN_STRUCT(S12) FIELD(x) END_STRUCT
BEGIN_STRUCT(S13) FIELD(x) FIELD(x1) FIELD(x2) FIELD(x3) FIELD(x4) FIELD(w) END_STRUCT
BEGIN_STRUCT(S14) FIELD(a) FIELD(b) FIELD(c) END_STRUCT
BEGIN_STRUCT(S15) FIELD(a) FIELD(b) FIELD(c) END_STRUCT
BEGIN_STRUCT(S16) END_STRUCT
BEGIN_STRUCT(S17) FIELD(a) END_STRUCT
BEGIN_STRUCT(S18) FIELD(a) FIELD(b) END_STRUCT
BEGIN_STRUCT(A0) FIELD(a) FIELD(b) FIELD(c) END_STRUCT
BEGIN_STRUCT(A1) FIELD(a) FIELD(b) FIELD(c) END_STRUCT
BEGIN_STRUCT(A2) FIELD(a) FIELD(b) FIELD(c) FIELD(d)
 FIELD(e) END_STRUCT
BEGIN_STRUCT(A3) FIELD(a) FIELD(b) FIELD(c) FIELD(d)
 FIELD(e) END_STRUCT
BEGIN_STRUCT(A4) FIELD(a) FIELD(b)
 FIELD(c) END_STRUCT
BEGIN_STRUCT(A5) FIELD(a) FIELD(b) END_STRUCT
BEGIN_STRUCT(A6) FIELD(a) FIELD(b) END_STRUCT
BEGIN_STRUCT(A7) FIELD(a) FIELD(b) FIELD(c)
 FIELD(d) END_STRUCT
BEGIN_STRUCT(A8) FIELD(a) FIELD(b)
 FIELD(c) END_STRUCT
BEGIN_STRUCT(A9) FIELD(a) FIELD(b)
 FIELD(c) FIELD(d)
 FIELD(e) FIELD(f) END_STRUCT
BEGIN_STRUCT(A10) FIELD(a) FIELD(b) END_STRUCT
BEGIN_STRUCT(A11) FIELD(a) FIELD(b) FIELD(c) FIELD(d)
             END_STRUCT
BEGIN_STRUCT(Issue24592a) FIELD(a) FIELD(b) FIELD(c) END_STRUCT
BEGIN_STRUCT(Issue24592b) FIELD(x) FIELD(a) FIELD(b) FIELD(c) END_STRUCT
BEGIN_STRUCT(Issue24592c) FIELD(a) FIELD(b) FIELD(c) FIELD(d) FIELD(e) FIELD(f) END_STRUCT
BEGIN_STRUCT(Issue24592d) FIELD(a) FIELD(b) FIELD(c) FIELD(d) FIELD(e) FIELD(f) END_STRUCT
BEGIN_STRUCT(Issue24613a) FIELD(a) FIELD(b) FIELD(c) FIELD(d) FIELD(e) FIELD(f) END_STRUCT
BEGIN_STRUCT(Issue24613b) FIELD(a) FIELD(b) FIELD(c) FIELD(d) FIELD(e) FIELD(f) END_STRUCT
BEGIN_STRUCT(Issue24613c) FIELD(a) FIELD(b) FIELD(c) FIELD(d) FIELD(e) FIELD(f) END_STRUCT

BEGIN_STRUCT(perf_event_mmap_page) FIELD(capabilities)
FIELD(cap_bit0)
FIELD(cap_bit0_is_deprecated)
FIELD(cap_user_rdpmc)
FIELD(cap_user_time)
FIELD(cap_user_time_zero)
FIELD(cap_user_time_short)
FIELD(cap_____res)
FIELD(pmc_width)
END_STRUCT

BEGIN_STRUCT(perf_mem_data_src) FIELD(val)
FIELD(mem_op)
FIELD(mem_lvl)
FIELD(mem_snoop)
FIELD(mem_lock)
FIELD(mem_dtlb)
FIELD(mem_lvl_num)
FIELD(mem_remote)
FIELD(mem_snoopx)
FIELD(mem_blk)
FIELD(mem_hops)
FIELD(mem_rsvd)
END_STRUCT

BEGIN_STRUCT(perf_branch_entry) FIELD(from)
FIELD(to)
FIELD(mispred)
FIELD(predicted)
FIELD(in_tx)
FIELD(abort)
FIELD(cycles)
FIELD(type)
FIELD(spec)
FIELD(new_type)
FIELD(priv)
FIELD(reserved)
END_STRUCT
