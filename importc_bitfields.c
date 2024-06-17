
struct T0  { char x:1; };
struct T1  { short x:1; };
struct T2  { int x:1; };
struct T3  { char a,b,c,d; long long x:1; };
struct T4  { char a,b,c,d,e,f,g,h; long long x:1; };
struct T5  { char a,b,c,d,e,f,g; long long x:1; };
struct S1  { long long int f:1; };
struct S2  { int x:1; int y:1; };
struct S3  { short c; int x:1; unsigned y:1; };
struct S4  { int x:1; short y:1; };
struct S5  { short x:1; int y:1; };
struct S6  { short x:1; short y:1; };
struct S7  { short x:1; int y:1; long long z:1; };
struct S8  { char a; char b:1; short c:2; };
struct S8A { char b:1; short c:2; };
struct S8B { char a; short b:1; char c:2; };
struct S8C { char a; int b:1; };
struct S9  { char a; char b:2; short c:9; };
//struct S10 { };
//struct S11 { int :0; };
struct S12 { int :0; int x; };
struct S13 { unsigned x:12; unsigned x1:1; unsigned x2:1; unsigned x3:1; unsigned x4:1; int w; };
struct S14 { char a; char b:4; int c:30; };
struct S15 { char a; char b:2; int c:9; };
struct S16 { int :32; };
struct S17 { int a:32; };
struct S18 { char a; long long :0; char b; };
struct A0  { int a; long long b:34, c:4; };
struct A1  { int a; unsigned b:11; int c; };
struct A2  { int a; unsigned b:11, c:5, d:16;
             int e; };
struct A3  { int a; unsigned b:11, c:5, :0, d:16;
             int e; };
struct A4  { int a:8; short b:7;
             unsigned int c:29; };
struct A5  { char a:7, b:2; };
struct A6  { char a:7; short b:2; };
struct A7  { short a:8; long b:16; int c;
             char d:7; };
struct A8  { short a:8; long b:16; int :0;
             char c:7; };
struct A9  { unsigned short a:8; long b:16;
             unsigned long c:29; long long d:9;
             unsigned long e:2, f:31; };
struct A10 { unsigned short a:8; char b; };
struct A11 { char a; int b:5, c:11, :0, d:8;
             struct { int ee:8; } e; };
struct Issue24592a { unsigned long long a:20, b:20, c:24; };
struct Issue24592b { unsigned int x; unsigned long long a:20, b:20, c:24; };
struct Issue24592c { unsigned long long a:20, b:32, c:32, d:32, e:32, f:32; };
struct Issue24592d { unsigned long long a:10, b:16, c:16, d:16, e:16, f:16; };
struct Issue24613a { unsigned long long a:64, b:64, c:64, d: 64, e: 64, f: 64; };
struct Issue24613b { unsigned long long a:20, b:64, c:64, d: 64, e: 64, f: 64; };
struct Issue24613c { unsigned long long a:20, b:63, c:63, d: 63, e: 63, f: 63; };

struct perf_event_mmap_page {
	union {
		unsigned long long	capabilities;
		struct {
			unsigned long long	cap_bit0		: 1, /* Always 0, deprecated, see commit 860f085b74e9 */
				cap_bit0_is_deprecated	: 1, /* Always 1, signals that bit 0 is zero */

				cap_user_rdpmc		: 1, /* The RDPMC instruction can be used to read counts */
				cap_user_time		: 1, /* The time_{shift,mult,offset} fields are used */
				cap_user_time_zero	: 1, /* The time_zero field is used */
				cap_user_time_short	: 1, /* the time_{cycle,mask} fields are used */
				cap_____res		: 58;
		};
	};

	unsigned long long	pmc_width;
};
union perf_mem_data_src {
	unsigned long long val;
	struct {
		unsigned long long   mem_op:5,	/* type of opcode */
			mem_lvl:14,	/* memory hierarchy level */
			mem_snoop:5,	/* snoop mode */
			mem_lock:2,	/* lock instr */
			mem_dtlb:7,	/* tlb access */
			mem_lvl_num:4,	/* memory hierarchy level number */
			mem_remote:1,   /* remote */
			mem_snoopx:2,	/* snoop mode, ext */
			mem_blk:3,	/* access blocked */
			mem_hops:3,	/* hop level */
			mem_rsvd:18;
	};
};
struct perf_branch_entry {
	unsigned long long	from;
	unsigned long long	to;
	unsigned long long	mispred:1,  /* target mispredicted */
		predicted:1,/* target predicted */
		in_tx:1,    /* in transaction */
		abort:1,    /* transaction abort */
		cycles:16,  /* cycle count to last branch */
		type:4,     /* branch type */
		spec:2,     /* branch speculation info */
		new_type:4, /* additional branch type */
		priv:3,     /* privilege level */
		reserved:31;
};
